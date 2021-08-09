import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/square_text_field.dart';
import 'main_tab_controller.dart';
import 'create_account_screen.dart';
import '../account.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector( //Hide keyboard when clicked outside text fields
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        //SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Scaffold(
        appBar: AppBar(title: Center(child: Text('Craigslist++'))),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LogInForm(),
            createAccountButton(context)
          ]
        )
      )
    );
  }

  Widget createAccountButton(BuildContext context){
  return Column(children: [
    Text('OR'),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {createAccountAction(context);},
        child: const Text('Create New Account', style: TextStyle(color: Colors.blue)),
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue[50]))
      )
          )

  ]);
}

  void createAccountAction(BuildContext context){
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.push(
      context,
      MaterialPageRoute<void>(
      builder: (BuildContext context) => CreateAccountScreen(),
      ),
    );
  }

}

class LogInForm extends StatefulWidget {
  const LogInForm({ Key? key }) : super(key: key);

  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SquareTextField(
              fieldController: _usernameController,
              hintText: 'Username'),
            SquareTextField(
              fieldController: _passwordController,
              hintText: 'Password'),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: logInButtonAction,
                child: const Text('Log In!'),
                )
            ),
          ],
        )
      )
    );
  }

  void logInButtonAction() async{
    if(_formKey.currentState!.validate()){

      String loginResponse = await login(_usernameController.text, _passwordController.text);

      //Hide keyboard
      FocusScope.of(context).requestFocus(new FocusNode());
      
      //_formKey.currentState?.reset();
      //SystemChannels.textInput.invokeMethod('TextInput.hide');

      if(loginResponse == 'OK') {
        //Reset Fields
        _usernameController.text = '';
        _passwordController.text = '';
        //Go to main screen 
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MainTabController(),
          ),
        );
      }
      else{
        final successBar = SnackBar(
          content: Text(
            '${loginResponse}. Please try again.', 
            style: TextStyle(color: Colors.red[300])));
        ScaffoldMessenger.of(context).showSnackBar(successBar);
      }
    }
  }

}

