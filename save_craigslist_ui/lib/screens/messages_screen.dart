import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:save_craigslist_ui/account.dart';
import 'dart:convert';
import '../server_url.dart';
import '../account.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../components/conversation_display.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({ Key? key }) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: http.get(Uri.parse('${hostURL}:${port}/messages/${currentUser.id}/recents')),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            dynamic jsonList = snapshot.data;

            debugPrint(jsonList.body, wrapWidth: 1024);
            
            
            List<Conversation> conversationList = convertFromJsonToConversationList(jsonDecode(jsonList.body));
            List<ConversationDisplay> conversationDisplays = createListOfConversationDisplays(conversationList);

            return ListView(children: conversationDisplays);
          }
          else if (snapshot.hasError){
            return Text('Error loading messages'); 
          }
          else {
            //Spinny wheel while the data loads
            return Center(child: CircularProgressIndicator()); 
          }
        }
      )
    );
  }

  List<Conversation> convertFromJsonToConversationList(List jsonList){
    List<Conversation> conversations = [];

    for (Map jsonConversation in jsonList){
      final String mostRecentSender = jsonConversation['content']['sender_id'];
      final String mostRecentReceiver = jsonConversation['content']['receiver_id'];
      final String mostRecentMessageContent = jsonConversation['content']['content'];
      final String mostRecentMessageTimestamp = jsonConversation['content']['date_sent'];
      final String mostRecentMessageID = jsonConversation['content']['id'];

      Message mostRecentMessage = Message(
        message_id: mostRecentMessageID,
        sender_id: mostRecentSender, 
        receiver_id: mostRecentReceiver,
        content: mostRecentMessageContent,
        date_sent: mostRecentMessageTimestamp);

      if (jsonConversation.containsKey('id') && jsonConversation.containsKey('photo')){
        final String otherUserId = jsonConversation['id'];
        final String userPhoto = jsonConversation['photo'];

        Conversation newConversation = Conversation(
          receiver_id: otherUserId,
          receiverPhoto: userPhoto,
          mostRecentMessage: mostRecentMessage
        );

        conversations.add(newConversation);

      }
      else {
        Conversation newConversation = Conversation(
          mostRecentMessage: mostRecentMessage
        );

        conversations.add(newConversation);
      }
    }

    return conversations;
  }

  List<ConversationDisplay> createListOfConversationDisplays(List<Conversation> conversations){

    List<ConversationDisplay> displayableConversations = [];

    for(Conversation conversation in conversations){
      ConversationDisplay displayableConversation = ConversationDisplay(conversation: conversation);
      displayableConversations.add(displayableConversation);
    }

    return displayableConversations;
  }

}