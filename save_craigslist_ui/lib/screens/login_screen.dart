import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/text_field.dart';
import 'main_tab_controller.dart';
import '../account.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Gurt\'s List'))),
      body: LogInForm()
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SquareTextField(
            fieldController: _usernameController,
            hintText: 'Username'),
          SquareTextField(
            fieldController: _passwordController,
            hintText: 'Password'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: logInButtonAction,
              child: const Text('Log In!'),
              )
          )
        ],
      )
    );
  }

  void logInButtonAction(){
    if(_formKey.currentState!.validate()){

      login(_usernameController.text, _passwordController.text);

      //Reset fields and hide keyboard
      _formKey.currentState?.reset();
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      //Go to main screen 
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => MainTabController(),
        ),
      );
    }
  }

}
