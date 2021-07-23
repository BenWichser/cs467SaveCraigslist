import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/item_display.dart';
import '../models/item.dart';
import '../server_url.dart';

class ListingsScreen extends StatefulWidget {
  final void Function() updateItems;

  const ListingsScreen({ Key? key, required this.updateItems }) : super(key: key);

  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}


class _ListingsScreenState extends State<ListingsScreen> {
  
  @override
  Widget build(BuildContext context) {
    //We get the list of every item in the database as a future. The futurebuilder checks
    //for data, converts the json to a list of Item objects, creates a list of ItemDisplay widgets
    //and returns the list in a Listview.

    return Scaffold(
      body: FutureBuilder(
        future: http.get(Uri.parse('${hostURL}:${port}/items')), 
        builder: (context, snapshot) {
          if (snapshot.hasData){
            dynamic jsonList = snapshot.data;
            //debugPrint(jsonList.body, wrapWidth: 1024);
            List<Item> itemList = convertFromJSONToItemList(jsonDecode(jsonList.body));
            List<ItemDisplay> itemDisplays = createListOfItemDisplays(itemList, widget.updateItems);
            return ListView(children: itemDisplays);
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


List<Item> convertFromJSONToItemList(List<dynamic> JSONItems){
  List<Item> items = [];

  for (Map item in JSONItems){

    if(item.containsKey('photos') && item['photos'].length != 0)
    {
      Item newItem = Item(
      id: item['id'],  
      title: item['title'],
      description: item['description'],
      seller_id: item['seller_id'],
      price: item['price'].toDouble(),
      location: item['location'],
      photos: item['photos']
      );

      items.add(newItem);
    }
    else{
      Item newItem = Item(
      id: item['id'],  
      title: item['title'],
      description: item['description'],
      seller_id: item['seller_id'],
      price: item['price'].toDouble(),
      location: item['location'],
      );

      items.add(newItem);
    }

  }

  return items;
}

List<ItemDisplay> createListOfItemDisplays(List<Item> items, updateItems){
  List<ItemDisplay> displayableItems = [];

  for(Item item in items){
    ItemDisplay displayableItem = ItemDisplay(item: item, updateItems: updateItems);
    displayableItems.add(displayableItem);
  }

  return displayableItems;
}


/*
App is successfully getting items from the database. No longer need this dummy data. Keeping it for now
in case I need it for debugging. 


//DUMMY DATA to be replaced with real JSON
List<Map> JSONItems = [{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
},
{
  'id' : '001',
  'title' : 'This is an item that is for sale',
  'description' : 'This is the description of that item that is for sale',
  'seller_id' : '001',
  'price' : 4000.00,
  'location' : '80205',
  'status' : 'For Sale',
  'photos' : ['url1', 'url2', 'url3'],
}];

List<Map> JSONItems2 = [
  {
    "photos":
      [{"caption":"Front Mug Shot","URL":"savecl-s3-us-east-2.aws.com/frontmugshot.png"},
      {"caption":"Side Mug Shot","URL":"savecl-s3-us-east-2.aws.com/sidemugshot.png"}],
    "location":"02134",
    "seller_id":"mckenzry",
    "description":"Coffee Mug displaying \"World's Best Boss\"",
    "id":"2",
    "price":9.76,
    "title":"Coffee Mug"
  },
  {
    "location":"90210",
    "id":"1",
    "description":"Empty Altoids Tin.  Holds buttons expertly.",
    "price":2,
    "seller_id":"mckenzry",
    "title":"Empty Altoids Tin"
  }];
  */