import 'models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../server_url.dart';

User currentUser = User.nullUser();

bool isLoggedIn(){
  if (currentUser.id == 'Null'){
    return false;
  }
  else{
    return true;
  }
}

Future<String> login(String username, String password) async{
  //This should send POST with username and password, get user data back,
  //Create user with that data and assign it to currentUser

  var body = {
    'username': username,
    'password': password
  };

  var response = await http.post(Uri.parse('${hostURL}:${port}/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body)
  );

  //If success complete login, otherwise display error message 
  if(response.statusCode == 200){
    print(response.body);
    var newUser = jsonDecode(response.body);

    //Update current user
    if (newUser.containsKey('photo')){
      currentUser = User(
        email: newUser['email']!,
        id: newUser['id']!,
        zip: newUser['zip'],
        photo: 'https://savecraigslistusers.s3.us-east-2.amazonaws.com/${newUser['photo']!}'
      );
    }
    else{
      currentUser = User(
        email: newUser['email']!,
        id: newUser['id']!,
        zip: newUser['zip'],
      );
    }

    print('print photo: ');
    print(currentUser.photo);
    return 'OK';
  }
  else {
    print (response.body);
    return (jsonDecode(response.body)['error']);
  }
}

void logout(){
  currentUser = User.nullUser();
}



/* ******************
Dummy data
******************* */

const Map<String, String> testUser = {
  'email' : 'jbutt@gmail.com',
  'id' : 'jbutt',
  'password' : 'Password1',
  'photo' : 'https://savecraigslistusers.s3.us-east-2.amazonaws.com/jamesbutt.jpg',
  'zip' : '70116'
};

