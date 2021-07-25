class Message {
  final String message_id;
  final String sender_id;
  final String receiver_id;
  final String date_sent;
  final String content;

  //Constructor with required named parameters
  Message({required this.message_id, 
    required this.sender_id, 
    required this.receiver_id, 
    required this.date_sent, 
    required this.content,
  });
}