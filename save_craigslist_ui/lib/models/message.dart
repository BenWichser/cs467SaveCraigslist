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

  Message.nullMessage({
    this.message_id = 'null', 
    this.sender_id = 'null', 
    this.receiver_id = 'null', 
    this.date_sent = 'null', 
    this.content = 'null'
  });
}