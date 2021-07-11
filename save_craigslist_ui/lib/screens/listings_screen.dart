import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../components/item_display.dart';
import '../models/item.dart';

class ListingsScreen extends StatelessWidget {
  const ListingsScreen({ Key? key }) : super(key: key);

  //Right now using global JSON here. I'm converting the JSON into a list of Item objects. 
  //Then I'm using those Item objects to create a list ItemDisplay Widgets. 
  //Then I pass the list of ItemDisplay widgets to ListView
  
  static final List<Item> itemList = convertFromJSONToItemList(JSONItems);
  static final List<ItemDisplay> ItemDisplays = createListOfItemDisplays(itemList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: ItemDisplays)
    );
  }
}

List<Item> convertFromJSONToItemList(List<Map> JSONItems){
  List<Item> items = [];

  for (Map item in JSONItems){
    Item newItem = Item(
      id: item['id'],  
      title: item['title'],
      description: item['description'],
      seller_id: item['seller_id'],
      price: item['price'],
      location: item['location'],
      photos: item['photos']
      );

    items.add(newItem);
  }

  return items;
}

List<ItemDisplay> createListOfItemDisplays(List<Item> items){
  List<ItemDisplay> displayableItems = [];

  for(Item item in items){
    ItemDisplay displayableItem = ItemDisplay(item: item);
    displayableItems.add(displayableItem);
  }

  return displayableItems;
}

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
