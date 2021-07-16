import 'models/user.dart';

User currentUser = User(
    email: testUser['email']!,
    id: testUser['id']!,
    password: testUser['password']!,
    photo: testUser['photo']!,
    zip: testUser['zip']!
  );

bool isLoggedIn(){
  if (currentUser.id == 'Null'){
    return false;
  }
  else{
    return true;
  }
}

void login(String username, String password){
  //This should send POST with username and password, get user data back,
  //Create user with that data and assign it to currentUser

  currentUser = User(
    email: testUser['email']!,
    id: testUser['id']!,
    password: testUser['password']!,
    photo: testUser['photo']!,
    zip: testUser['zip']!
  );
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

