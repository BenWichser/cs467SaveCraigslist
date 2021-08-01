import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/item_display.dart';
import '../models/item.dart';
import '../server_url.dart';
import '../account.dart';

class ListingsScreen extends StatefulWidget {
  final void Function() updateItems;

  const ListingsScreen({ Key? key, required this.updateItems }) : super(key: key);

  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}


class _ListingsScreenState extends State<ListingsScreen> {
  var searchLocation = currentUser.zip;
  var radius = 5;
  var searchTerms = '';
  var minPrice = 0.0;
  var maxPrice = double.infinity;

  var sortBy = 'DATE';
  
  @override
  Widget build(BuildContext context) {
    //We get the list of every item in the database as a future. The futurebuilder checks
    //for data, converts the json to a list of Item objects, creates a list of ItemDisplay widgets
    //and returns the list in a Listview.
    var appBarHeight = AppBar().preferredSize.height * .8;
    var appBarWidth = AppBar().preferredSize.width;

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: SizedBox(
            height: appBarHeight, 
            width: appBarWidth,
            child: filters(),
          )
      ),
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

  Widget filters(){
    //This widget is a monstrosity. Break this up for the love of god. 

    TextEditingController zipController = TextEditingController();
    zipController.text = searchLocation;

    TextEditingController minPriceController = TextEditingController();
    if(minPrice != 0.0){
      minPriceController.text = minPrice.toStringAsFixed(2);
    }

    TextEditingController maxPriceController = TextEditingController();
    if(maxPrice != double.infinity){
      maxPriceController.text = maxPrice.toStringAsFixed(2);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
          PopupMenuButton(
            child: Row(children: [Icon(Icons.add_location), Text('${searchLocation} - ${radius} Miles')]),
            itemBuilder: (BuildContext context) => [
              //Zip Code Field
              PopupMenuItem(
                height: 50,
                child: Container(
                  width: MediaQuery.of(context).size.width * .7, 
                  child: TextFormField(
                    controller: zipController, 
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.add_location),
                      border: OutlineInputBorder()),
                    onFieldSubmitted: (value) {
                      if(value != ''){ //Need to verify if this is actually a zip code
                        setState(() {
                          searchLocation = value;
                        });
                        Navigator.pop(context);
                      }
                    }
                 )
                )
              ),
              //Radius drop down
              PopupMenuItem(
                height: 50,
                child: Container(
                  width: MediaQuery.of(context).size.width * .7,
                  child: DropdownButtonFormField<int>(
                    items: [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('1 Mile')
                      ),
                      DropdownMenuItem<int>(
                        value: 5,
                        child: Text('5 Miles')
                      ),
                      DropdownMenuItem<int>(
                        value: 10,
                        child: Text('10 Miles')
                      ),
                      DropdownMenuItem<int>(
                        value: 25,
                        child: Text('25 Miles')
                      ),
                      DropdownMenuItem<int>(
                        value: 50,
                        child: Text('50 miles')
                      )
                    ],
                    onSaved: (value) {radius = value!;},
                    onChanged: (value) {
                      setState((){radius = value!;});
                    },
                    decoration: InputDecoration(hintText: '${radius} miles', border: OutlineInputBorder())
                  )
                )
              )
            ]
          ),
          Row(children: [
            //Sort button
            PopupMenuButton<String>(
              icon: Icon(Icons.sort, size: 25),
              onSelected: (selection) {setState((){sortBy = selection;});},
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: Text('Sort by:', style: TextStyle(color: Colors.black)),
                  enabled: false,
                  
                ),
                CheckedPopupMenuItem(
                  checked: sortBy == 'DATE',
                  value: 'DATE',
                  child: Text('Date')
                ),
                CheckedPopupMenuItem(
                  checked: sortBy == 'PRICE',
                  value: 'PRICE',
                  child: Text('Price')
                ),
                CheckedPopupMenuItem(
                  checked: sortBy == 'RELEVANCE',
                  value: 'RELEVANCE',
                  child: Text('Relevance')
                )
              ], 
            ),
            //Filters button
            PopupMenuButton(
              icon: Icon(Icons.tune_sharp, size: 25),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: Container(
                    width: MediaQuery.of(context).size.width * .7,
                    height: 100,
                    child: Column(children: [
                      Text('Price Range'),
                      Row(children: [
                        //Min Price Field
                        Expanded(
                          child: TextFormField(
                            controller: minPriceController,
                            decoration: InputDecoration(
                              hintText: 'min',
                              border: OutlineInputBorder()
                            ),
                            onFieldSubmitted: (value) {
                              setState((){
                              minPrice = double.parse(minPriceController.text);
                              maxPrice = double.parse(maxPriceController.text);                    
                              });
                              Navigator.pop(context);
                            },
                          )
                        ),
                        Text(' to '),
                        //Max Price Field
                        Expanded(
                          child: TextFormField(
                            controller: maxPriceController,
                            decoration: InputDecoration(
                              hintText: 'max',
                              border: OutlineInputBorder()
                            ),
                            onFieldSubmitted: (value) {
                              setState((){
                              minPrice = double.parse(minPriceController.text);
                              maxPrice = double.parse(maxPriceController.text);
                              });
                              Navigator.pop(context);
                            },
                          )
                        ),
                      ])
                    ])
                  )
                )
              ], 
            )
          ])
    ]);
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