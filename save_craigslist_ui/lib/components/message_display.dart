import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import '../models/message.dart';
import '../account.dart';

class MessageDisplay extends StatelessWidget {
  final Message message;

  const MessageDisplay({ Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(this.message.sender_id == currentUser.id) {
    
      return Bubble(
        color: Colors.blue,
        margin: BubbleEdges.only(top: 10, left: 40),
        alignment: Alignment.topRight,
        nip: BubbleNip.rightBottom,
        child: Text(message.content),
      );
    }
    else {
      return Bubble(
        color: Colors.grey[300],
        margin: BubbleEdges.only(top: 10, right: 40),
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftBottom,
        child: Text(message.content),
      );
    }

  }
}