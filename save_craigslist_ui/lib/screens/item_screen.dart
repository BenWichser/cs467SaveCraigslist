import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/item.dart';
import '../server_url.dart';

class ItemScreen extends StatelessWidget {
  final Item item;

  ItemScreen({ Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            itemPhotos(item),
            itemInfo(item),
            itemDescription(item),
            sellerSection(item)
          ]
        )
      )
    );
  }
}

Widget itemPhotos(Item item){
  return Padding(padding: EdgeInsets.all(20), 
    child: AspectRatio(
      aspectRatio: 1, 
      child: Image(
        image: NetworkImage('${s3ItemPrefix}${item.photos![0]['URL']}')
      )
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

Widget sellerSection(item){
  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.only(right: 20, left: 20, bottom: 20),
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
          sellerInfo(item)
        ]
      )
    )
  ); 
}

Widget sellerInfo(item) {
//This needs to eventually take the seller information as a parameter

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      sellerPhotoAndName(item),
      ElevatedButton(
        onPressed: () {print('Messaging Seller');},
        child: const Text('Message'),
      )
    ]
  );
}

Widget sellerPhotoAndName(item) {
//This needs to eventually take the seller information as a parameter
  return Row(
    children: [
      Padding(
        padding: EdgeInsets.only(right: 5),
        child: FutureBuilder(
            future: http.get(Uri.parse('${hostURL}:${port}/users/${item.seller_id}')),
            builder: (context, snapshot) {
              if (snapshot.hasData){
                dynamic sellerJSONString = snapshot.data;
                Map sellerJSON = jsonDecode(sellerJSONString.body);

                print("HERHERHERHERE");
                debugPrint('${sellerJSON}', wrapWidth: 1024);

                return CircleAvatar(
                  backgroundColor: Colors.black,
                  foregroundImage: NetworkImage('${s3UserPrefix}${sellerJSON['photo']}')
                );

              }
              else if (snapshot.hasError){
                return Text('Error loading seller'); 
              }
              else {
                //Spinny wheel while the data loads
                return Center(child: CircularProgressIndicator()); 
              }
            }        
      )
    ), 
    Text(item.seller_id)]
  );
}