import 'package:flutter/material.dart';

class SquareTextField extends StatelessWidget {
  final TextEditingController fieldController;
  final String hintText;
  late final validator;

  SquareTextField({ Key? key, required this.fieldController, required this.hintText, this.validator = null}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: TextFormField(
          obscureText: hintText == 'Password',
          controller: fieldController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
          ),
          validator: validator == null 
          ? (value) {
            if (value == null || value.isEmpty){
              return 'Required Field!';
            }
          }
          : validator
        )
      )
    ); 
  }  
}