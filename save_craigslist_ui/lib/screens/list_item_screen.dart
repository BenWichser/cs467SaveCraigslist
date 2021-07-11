import 'package:flutter/material.dart';

class ListItemScreen extends StatelessWidget {
  const ListItemScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List an Item')),
      body: Text('This is the list an item screen')
    );
  }
}