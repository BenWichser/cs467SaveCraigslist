import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:save_craigslist_ui/account.dart';
import 'dart:convert';
import '../server_url.dart';
import '../account.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../components/message_display.dart';

class ConversationScreen extends StatefulWidget {
  final Conversation conversation;
  final void Function() updateConversations;

  const ConversationScreen({ Key? key, required this.conversation, required this.updateConversations}) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  @override
  Widget build(BuildContext context) {
    print('${s3UserPrefix}/${widget.conversation.receiverPhoto}');

    return GestureDetector(
      onTap: () {SystemChannels.textInput.invokeMethod('TextInput.hide');},
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            title: Row(children: [
          CircleAvatar(
              backgroundColor: Colors.black,
              foregroundImage: NetworkImage('${s3UserPrefix}${widget.conversation.receiverPhoto}')
              ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(widget.conversation.receiver_id))
            ]
          )
        ),
        body: previousMessages(),
        bottomNavigationBar: Transform.translate(
          offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
          child: BottomAppBar(child: newMessageField()
          )
        )
      )
    );

  }

  Widget newMessageField() {
    TextEditingController messageController = TextEditingController();

    return BottomAppBar(
      child: 
      Padding(
        padding: EdgeInsets.all(5), 
        child : 
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: messageController, 
                decoration: InputDecoration(border: OutlineInputBorder()),
                onFieldSubmitted: (value) {
                    if(value != ''){
                      sendMessage(value);
                    }
                }
              )
            ),
            ElevatedButton(
              child: Text('Send'),
              onPressed: (){
                if(messageController.text != ''){
                  sendMessage(messageController.text);
                  messageController.clear();
                }
              }
            )
        ]))
    );
  }

  void sendMessage(String messageContent) async {
    print('sending message:');
    

    var newMessage = {
      'content': messageContent,
    };

    print(newMessage);

    var response = await http.post(Uri.parse('${hostURL}:${port}/messages/${currentUser.id}/${widget.conversation.receiver_id}'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(newMessage));

    if(response.statusCode == 201){
      print('success!');
      setState((){});
      widget.updateConversations();
    }
    else {
      print('ERROR!');
    }
  }

  Widget previousMessages(){
    return FutureBuilder(
      future: http.get(Uri.parse('${hostURL}:${port}/messages/${currentUser.id}/${widget.conversation.receiver_id}')),
      builder: (context, snapshot) {
        if (snapshot.hasData){
          dynamic jsonList = snapshot.data;
          debugPrint(jsonList.body, wrapWidth: 1024);
            
          processMessages(jsonDecode(jsonList.body));
          List<MessageDisplay> messageDisplays = createListOfMessageDisplays();

          return ListView(children: messageDisplays);

        }
        else if (snapshot.hasError){
          return Text('Error loading conversation'); 
        }
        else {
          //Spinny wheel while the data loads
          return Center(child: CircularProgressIndicator()); 
        }
      }
    );
  }

  void processMessages(jsonList){
    widget.conversation.clearMessages();

    for (Map jsonMessage in jsonList){
      Message newMessage = Message(
        message_id: jsonMessage['id'],
        sender_id: jsonMessage['sender_id'],
        receiver_id: jsonMessage['receiver_id'],
        content: jsonMessage['content'],
        date_sent: jsonMessage['date_sent']
      );

      widget.conversation.addMessage(newMessage);
    }

    widget.conversation.sortMessages();
  }

  List<MessageDisplay> createListOfMessageDisplays(){

    List<MessageDisplay> messageDisplays = [];

    for (Message message in widget.conversation.messages!){
      MessageDisplay newMessageDisplay = MessageDisplay(message: message);
      messageDisplays.add(newMessageDisplay);
    }

    return messageDisplays;
  }

}