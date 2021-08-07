import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:save_craigslist_ui/components/square_text_field.dart';
import 'dart:convert';
import '../models/item.dart';
import '../server_url.dart';
import '../account.dart';
import 'conversation_screen.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../functions/readable_date.dart';

class ItemScreen extends StatefulWidget {
  final Item item;
  final void Function() updateItems;

  ItemScreen({ Key? key, required this.item, required this.updateItems}) : super(key: key);

  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  bool editMode = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.item.title;
    priceController.text = widget.item.price.toStringAsFixed(2);
    descriptionController.text = widget.item.description!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            itemPhotos(widget.item),
            itemInfo(widget.item),
            itemDescription(widget.item),

            //Either the seller info, or a edit and delete buttons if the current user is the seller
            widget.item.seller_id != currentUser.id 
              ? sellerSection(widget.item, context) 
              : Column(children: [
                  editButton(widget.item, context), 
                  deleteButton(widget.item.id, context)
                ]),


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
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) => confirmDelete(itemId, context)),
        child: Text('Delete Item')
      )
    );
  }

  Widget editButton(item, context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: !editMode ? ElevatedButton(
        onPressed: () {
          setState((){
            editMode = !editMode;
          });
        },
        child: Text('Edit Item')
      )
      : ElevatedButton(
        onPressed: () {
          updateItem(item, titleController.text, priceController.text, descriptionController.text);
          setState((){
            editMode = !editMode;
          });
        },
        child: Text('Save')
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
    
    widget.updateItems();
    Navigator.pop(context);
    Navigator.pop(context);
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
          title(item),
          Text(readableDate(item.date_added)),
          price(item)
        ]
      )
    ); 
  }

  Widget title(item){
    return !editMode 
      ? Text(item.title, style: TextStyle(fontWeight: FontWeight.bold))
      : SquareTextField(fieldController: titleController, hintText: 'title');
  }

  Widget price(item){
    return !editMode
      ? Text('\$${item.price.toStringAsFixed(2)}')
      : SquareTextField(fieldController: priceController, hintText: 'price');
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
            !editMode 
              ? Text(item.description)
              : SquareTextField(fieldController: descriptionController, hintText: 'description')
          ]
        )
      )
    ); 
  }


  Widget sellerSection(item, BuildContext context){
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
            sellerInfo(item, context)
          ]
        )
      )
    ); 
  }

  Widget sellerInfo(item, BuildContext context) {
    return FutureBuilder(
      future: http.get(Uri.parse('${hostURL}:${port}/items/${item.id}')),
      builder: (context, snapshot) { 
        if (snapshot.hasData){
          dynamic sellerJSONString = snapshot.data;
          Map sellerJSON = jsonDecode(sellerJSONString.body);

          print('Getting seller info from item route:');
          debugPrint('${sellerJSON}', wrapWidth: 1024);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      foregroundImage: NetworkImage('${s3UserPrefix}${sellerJSON['photo']}')
                    )
                  ), 
                  Text(item.seller_id)]
              ),
              ElevatedButton(
                onPressed: () {
                  Conversation conversation = Conversation(
                  receiver_id: sellerJSON['seller_id'],
                  receiverPhoto: sellerJSON['photo'],
                  mostRecentMessage: Message.nullMessage()
                  );
                  Navigator.push<void>(
                    context,  
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => ConversationScreen
                        (conversation: conversation, 
                        updateConversations : (){}
                      )
                    )
                  );
                },
              child: const Text('Message'),
              )  
          ]);
        }
        else if (snapshot.hasError){
          return Text('Error loading seller'); 
        }
        else {
          //Spinny wheel while the data loads
          return Center(child: CircularProgressIndicator()); 
        }
      }
    );
  }

  void updateItem(item, title, price, description) async {
    var itemInfo = {
      'title': title,
      'price': double.parse(price),
      'description': description,

      //These attributes are currently not editable, but are required on the backend.
      'seller_id': item.seller_id,
      'location': item.location,
      'status': item.status,
    };

    print('Updating with this info:');
    print(itemInfo);

    var response = await http.put(
      Uri.parse('${hostURL}:${port}/items/${item.id}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(itemInfo)
    );

    //If success display success message otherwise display error message.
    if (response.statusCode == 200) {
      final successBar = SnackBar(content: Text('Your item has been updated!'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    } 
    else {
      final successBar = SnackBar(content: Text('Error updating item. Please try again.'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    }
  }
}

