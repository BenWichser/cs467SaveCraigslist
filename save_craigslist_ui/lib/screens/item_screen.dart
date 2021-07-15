import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemScreen extends StatelessWidget {
  final Item item;

  ItemScreen({ Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          itemPhotos(),
          itemInfo(item),
          itemDescription(item),
          sellerSection()
        ]
      )
    );
  }
}

Widget itemPhotos(){
  return Padding(padding: EdgeInsets.all(20), 
    child: AspectRatio(
      aspectRatio: 1, 
      //This needs to be replaced with the main item photo
      child: Placeholder()
      //eventually add more photos to be displayed below
    )
  ); 
}

Widget itemInfo(item){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),  
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title, 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        Text(
          '\$${item.price}'
        )
      ]
    )
  ); 
}

Widget itemDescription(item){
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10), 
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.black),
          bottom: BorderSide(width: 1.0, color: Colors.black))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10), 
            child: Text('Description', style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 20)
            )
          ),
          Text(item.description)
        ]
      )
    )
  ); 
}

Widget sellerSection(){
  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Seller', style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 20)
            )
          ),
          sellerInfo()
        ]
      )
    )
  ); 
}

Widget sellerInfo() {
//This needs to eventually take the seller information as a parameter

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      sellerPhotoAndName(),
      ElevatedButton(
        onPressed: () {print('Messaging Seller');},
        child: const Text('Message'),
      )
    ]
  );
}

Widget sellerPhotoAndName() {
//This needs to eventually take the seller information as a parameter
  return Row(
    children: [
      Padding(
        padding: EdgeInsets.only(right: 5),
        child: CircleAvatar(
        backgroundColor: Colors.black,
        child: const Text('SE')
      )), 
      Text('name')]
  );
}