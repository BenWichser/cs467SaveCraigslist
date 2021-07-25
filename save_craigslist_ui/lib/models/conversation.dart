import 'message.dart';

class Conversation {
  final String receiver_id;
  final String receiverPhoto;
  List<Message>? messages = [];
  final Message mostRecentMessage;

  //Constructor with required named parameters
  Conversation({
    this.receiver_id = '[Deleted User]', 
    this.receiverPhoto = 'blank_profile_picture.png', 
    required this.mostRecentMessage, 
  });

  void addMessage(Message newMessage){
    messages!.add(newMessage);
  }

  void sortMessages(){
      messages!.sort((a, b) => a.date_sent.compareTo(b.date_sent));
  }

  void clearMessages(){
    messages = [];
  }

}