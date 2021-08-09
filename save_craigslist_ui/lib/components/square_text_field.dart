import 'package:flutter/material.dart';

class SquareTextField extends StatelessWidget {
  final TextEditingController fieldController;
  final String hintText;
  late final validator;

  SquareTextField({ Key? key, required this.fieldController, required this.hintText, this.validator = null}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: hintText == 'Password',
      controller: fieldController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hintText,
        contentPadding: EdgeInsets.all(10)
      ),
      validator: validator == null 
      ? (value) {
        if (value == null || value.isEmpty){
          return 'Required Field!';
        }
      }
      : validator
    );
  }  
}