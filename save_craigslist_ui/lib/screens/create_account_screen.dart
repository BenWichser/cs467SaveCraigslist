import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/square_text_field.dart';
import '../server_url.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Account')),
      body: Center(child: NewAccountForm())
    );
  }
}

class NewAccountForm extends StatefulWidget {
  const NewAccountForm({ Key? key }) : super(key: key);

  @override
  _NewAccountFormState createState() => _NewAccountFormState();
}

class _NewAccountFormState extends State<NewAccountForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController zipController = TextEditingController();


    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SquareTextField(
              fieldController: usernameController,
              hintText: 'Username'),
            SquareTextField(
              fieldController: passwordController,
              hintText: 'Password'),
            SquareTextField(
              fieldController: emailController,
              hintText: 'Email Address'),
            SquareTextField(
              fieldController: zipController,
              hintText: 'Zip Code'),          
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  if(_formKey.currentState!.validate()){
                    /* ***************************
                    Need to add photos, get seller_id and location from current user

                    ***************************** */
                    createUser(
                      usernameController.text, 
                      passwordController.text, 
                      emailController.text,
                      zipController.text,
                      context);

                    //Reset fields and hide keyboard
                    _formKey.currentState?.reset();
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  }
                },
                child: const Text('Create Account!'),
                )
            )
          ],
        )
      )
    );
  }
}

void createUser(String username, String password, String email, String zip, BuildContext context) async {
    
  //NEED TO ADD PHOTOS
  var newUser = {
    'username': username,
    'password': password,
    'email': email,
    'zip': zip,
  };

  var response = await http.post(Uri.parse('${hostURL}:${port}/users'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(newUser)
  );

  //If success display success message otherwise display error message. 
  if(response.statusCode == 201){
    final successBar = SnackBar(content: Text('Your account has been created!'));
    ScaffoldMessenger.of(context).showSnackBar(successBar);
    Navigator.pop(context);
  }
  else {
    final successBar = SnackBar(content: Text('Error creating account. Please try again.'));
    ScaffoldMessenger.of(context).showSnackBar(successBar);
  };

}