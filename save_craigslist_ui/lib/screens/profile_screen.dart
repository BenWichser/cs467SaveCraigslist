import 'package:flutter/material.dart';
import 'package:save_craigslist_ui/components/square_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../account.dart';
import '../server_url.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({ Key? key }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController usernameController = TextEditingController(text: currentUser.id);
  TextEditingController emailController = TextEditingController(text: currentUser.email);
  TextEditingController zipController = TextEditingController(text: currentUser.zip);

  bool editMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(child: Column(
        children: [
          profilePhoto(),
          username(),
          email(),
          zip(),
          editProfileButton()
        ]
      ))
    );
  }
    
  Widget profilePhoto(){
    print(currentUser.photo);

    return Padding(padding: EdgeInsets.all(20), 
      child: AspectRatio(
        aspectRatio: 1, 
        child: Image(
          image: NetworkImage('${currentUser.photo}')
        )
      )
    ); 
  }

  Widget username() {
    return Container( 
      padding: EdgeInsets.all(15.0),
      width: double.infinity,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Colors.black))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Username:'),
          !editMode ? Text(currentUser.id) : 
          SquareTextField(
            fieldController: usernameController, 
            hintText: 'username')
      ])
    );
  }

  Widget email() {
    return Container( 
      padding: EdgeInsets.all(15.0),
      width: double.infinity,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Colors.black))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email:'),
          !editMode ? Text(currentUser.email) : 
          SquareTextField(
            fieldController: emailController, 
            hintText: 'email')
      ])
    );
  }

  Widget zip() {
    return Container( 
      padding: EdgeInsets.all(15.0),
      width: double.infinity,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Colors.black))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zip Code:'),
          !editMode ? Text(currentUser.zip) : 
          SquareTextField(
            fieldController: zipController, 
            hintText: 'zip code')
      ])
    );
  }

  Widget editProfileButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: editMode ? 
        ElevatedButton(
          onPressed: () {
            updateUserInfo(usernameController.text, emailController.text, zipController.text);
            setState((){
              editMode = !editMode;
            });
          },
          child: const Text('Save'),
        )
        :
        ElevatedButton(
          onPressed: () {
            setState((){
              editMode = !editMode;
            });
          },
          child: const Text('Edit Profile'),
        )    
    );
  }

  void updateUserInfo(username, email, zip) async {
    var userInfo = {
    'username' : username,
    'email': email,
    'zip': zip,
    };

    var response = await http.put(Uri.parse('${hostURL}:${port}/users'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userInfo)
    );

    //If success display success message otherwise display error message. 
    if(response.statusCode == 200){
      final successBar = SnackBar(content: Text('Your account details have been updated!'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    }
    else {
      final successBar = SnackBar(content: Text('Error updating account details. Please try again.'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    };
  }

}