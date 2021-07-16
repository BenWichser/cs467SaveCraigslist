import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

class App extends StatelessWidget{
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gurt\'s List',
      theme: ThemeData(primaryColor: Colors.white),
      //home: MainTabController()
      home: LogInScreen()
    );
  }
}
