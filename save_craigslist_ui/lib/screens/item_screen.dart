import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/item.dart';
import '../server_url.dart';
import '../account.dart';

class ItemScreen extends StatelessWidget {
  final Item item;
  final void Function() updateItems;

  ItemScreen({ Key? key, required this.item, required this.updateItems}) : super(key: key);

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

            //Either the seller info, or a delete button if the current user is the seller
            item.seller_id != currentUser.id ? sellerSection(item) : deleteButton(item.id, context)
          ]
        )
      )
    );
  }

  Widget deleteButton(itemId, context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) => confirmDelete(itemId, context)),
        child: Text('Delete Item')
      )
    );
  }

  Widget confirmDelete(itemId, context){
    return AlertDialog(
      content: Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(
          onPressed: () {deleteItem(itemId, context);}, 
          child: Text('Yes'),),
        TextButton(
          onPressed: () {Navigator.pop(context);},
          child: Text('No')
        )
      ]  
    );
  }

  void deleteItem(itemId, context) async {
    var response = await http.delete(Uri.parse('${hostURL}:${port}/items/${itemId}'));
    if(response.statusCode == 204){
      final successBar = SnackBar(content: Text('Your item has been deleted.'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    }
    else {
      final successBar = SnackBar(content: Text('Error deleting item. Please try again.'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    };
    
    updateItems();
    Navigator.pop(context);
    Navigator.pop(context);
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
            future: http.get(Uri.parse('${hostURL}:${port}/items/${item.id}')),
            builder: (context, snapshot) {
              if (snapshot.hasData){
                dynamic sellerJSONString = snapshot.data;
                Map sellerJSON = jsonDecode(sellerJSONString.body);

                //debugPrint('${sellerJSON}', wrapWidth: 1024);

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


