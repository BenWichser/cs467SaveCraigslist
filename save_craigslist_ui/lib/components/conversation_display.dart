import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:save_craigslist_ui/server_url.dart';
import '../models/conversation.dart';
import '../screens/conversation_screen.dart';

class ConversationDisplay extends StatelessWidget {
  final Conversation conversation;
  //final void Function() updateItems;

  const ConversationDisplay({ Key? key, required this.conversation}) : super(key: key);

  //Individual Display for each conversation
  //Will display other user's photo and id, and a snippet of the most recent message

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {  
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => ConversationScreen(conversation: conversation),
          ),
        );
        print('go to conversation screen');
      },
      child: Container( 
        padding: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Colors.black))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              foregroundImage: NetworkImage('${s3UserPrefix}${conversation.receiverPhoto}')
            ),
            Padding(
              padding: EdgeInsets.all(10), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.receiver_id),
                  conversation.mostRecentMessage.content.length > 45 ? 
                    Text('${conversation.mostRecentMessage.content.substring(0,45)}...') :
                    Text(conversation.mostRecentMessage.content)
                ])
            )
          ])
      )
    );
  }
}