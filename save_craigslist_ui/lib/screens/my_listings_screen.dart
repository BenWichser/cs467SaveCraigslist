import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'listings_screen.dart';
import '../account.dart';
import '../server_url.dart';
import '../components/item_display.dart';
import '../models/item.dart';


class MyListingsScreen extends StatefulWidget {

  const MyListingsScreen({ Key? key}) : super(key: key);

  @override
  _MyListingsScreenState createState() => _MyListingsScreenState();
}


class _MyListingsScreenState extends State<MyListingsScreen> {
  
  void updateItems() {
    setState( (){} );
  }

  @override
  Widget build(BuildContext context) {
    //We get the list of every item in the database as a future. The futurebuilder checks
    //for data, converts the json to a list of Item objects, creates a list of ItemDisplay widgets
    //and returns the list in a Listview.

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
          CircleAvatar(
            backgroundColor: Colors.black,
            foregroundImage: NetworkImage(currentUser.photo)
            //child: const Text('UN')
          ),
          Padding( 
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(currentUser.id))
          ]
        )
      ),
      body: FutureBuilder(
        future: http.get(Uri.parse('${hostURL}:${port}/items/users/${currentUser.id}')), 
        builder: (context, snapshot) {
          if (snapshot.hasData){

            dynamic jsonList = snapshot.data;
            print('MY LISTINGS');
            debugPrint(jsonList.body, wrapWidth: 1024);

            if (jsonList.body.length == 0){
              return Text('You don\'t have any items listed.');
            }
            else {

              //These function are defined on the listings page
              List<Item> itemList = convertFromJSONToItemList(jsonDecode(jsonList.body));
              List<ItemDisplay> itemDisplays = createListOfItemDisplays(itemList, updateItems);
              return ListView(children: itemDisplays);
            }
          
          }
          else if (snapshot.hasError){
            return Text('Error loading items'); 
          }
          else {
            //Spinny wheel while the data loads
            return Center(child: CircularProgressIndicator()); 
          }
        }
      )
    ); 
  }
}