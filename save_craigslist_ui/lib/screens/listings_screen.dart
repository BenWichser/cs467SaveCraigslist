import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/item_display.dart';
import '../models/item.dart';
import '../server_url.dart';
import '../account.dart';

class ListingsScreen extends StatefulWidget {
  final void Function() updateItems;
  final String searchTerms;

  const ListingsScreen({ Key? key, required this.updateItems,  required this.searchTerms}) : super(key: key);

  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}


class _ListingsScreenState extends State<ListingsScreen> {
  var searchLocation = currentUser.zip;
  var radius = 5;
  var minPrice = 0.0;
  var maxPrice = double.infinity;

  var sortBy = 'RELEVANCE';
  
  @override
  Widget build(BuildContext context) {
    //We get the list of every item in the database as a future. The futurebuilder checks
    //for data, converts the json to a list of Item objects, creates a list of ItemDisplay widgets
    //and returns the list in a Listview.
    String searchTerms = widget.searchTerms;

    var appBarHeight = AppBar().preferredSize.height * .8;
    var appBarWidth = AppBar().preferredSize.width;

    //Create qurey string based on filter terms provided by user
    String queryParams = '?user_id=${currentUser.id}&location=${searchLocation}&radius=${radius}';

    if (searchTerms != ''){
      queryParams += '&tags=${searchTerms}';
    }

    if(minPrice != 0.0){
      queryParams += '&minPrice=${minPrice}';
    }

    if(maxPrice != double.infinity){
      queryParams += '&maxPrice=${maxPrice}';
    }

    print(queryParams);


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
        future: http.get(Uri.parse('${hostURL}:${port}/items/${queryParams}')), 
        builder: (context, snapshot) {
          if (snapshot.hasData){
            dynamic jsonList = snapshot.data;
            jsonList = jsonDecode(jsonList.body);
            debugPrint(jsonEncode(jsonList), wrapWidth: 1024);

            sortItems(sortBy, jsonList);
            List<Item> itemList = convertFromJSONToItemList(jsonList);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        zipAndRadiusDropdown(),
        Row(children: [
          sortDropdown(),
          priceRangeFilters()
        ])
    ]);
  }

  Widget zipAndRadiusDropdown(){
    return PopupMenuButton(
      child: Row(children: [
        Icon(Icons.location_pin), 
        Text(radius > 1 ? '${searchLocation} - ${radius} Miles' : '${searchLocation} - ${radius} Mile')
      ]),
      itemBuilder: (BuildContext context) => [
        zipField(),
        radiusDropdown()
      ]
    );
  }

  PopupMenuItem zipField(){
    TextEditingController zipController = TextEditingController();
    zipController.text = searchLocation;

    final GlobalKey<FormState> _zipKey = GlobalKey<FormState>();

    return PopupMenuItem(
      height: 50,
      child: Container(
        width: MediaQuery.of(context).size.width * .7, 
        child: Form(
          key: _zipKey,
          child: TextFormField(
            controller: zipController, 
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_pin),
              border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a zip code.';
              }
              if (!isValidZip(value)) {
                return 'Please enter a valid zip code.';
              }
            },
            onFieldSubmitted: (value) {
              if (_zipKey.currentState!.validate()){
                setState(() {
                  searchLocation = value;
                });
                Navigator.pop(context);
              }
            }
        )
        )
      )
    );
  }

  PopupMenuItem radiusDropdown(){
    return PopupMenuItem(
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
    );
  }

  Widget sortDropdown(){
    return PopupMenuButton<String>(
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
        ),
        CheckedPopupMenuItem(
          checked: sortBy == 'DISTANCE',
          value: 'DISTANCE',
          child: Text('Distance')
        )
      ], 
    );
  }

  Widget priceRangeFilters(){

    TextEditingController minPriceController = TextEditingController();
    if(minPrice != 0.0){
      minPriceController.text = minPrice.toStringAsFixed(2);
    }

    TextEditingController maxPriceController = TextEditingController();
    if(maxPrice != double.infinity){
      maxPriceController.text = maxPrice.toStringAsFixed(2);
    }

    final GlobalKey<FormState> _priceRangeKey = GlobalKey<FormState>();

    return PopupMenuButton(
      icon: Icon(Icons.tune_sharp, size: 25),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          child: Container(
            width: MediaQuery.of(context).size.width * .7,
            height: 100,
            child: Column(children: [
              Text('Price Range'),
              Form(
                key: _priceRangeKey,
                child: Row(children: [
                  //Min Price Field
                  Expanded(
                    child: TextFormField(
                      controller: minPriceController,
                      decoration: InputDecoration(
                        hintText: 'min',
                        border: OutlineInputBorder()
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty ) {
                          return 'Please enter a minimum price.';
                        }
                        if (!isValidPrice(value)) {
                          return 'Please enter a valid price.';
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (_priceRangeKey.currentState!.validate()){
                          setState((){
                          minPrice = double.parse(minPriceController.text);
                          maxPrice = double.parse(maxPriceController.text);                    
                          });
                          Navigator.pop(context);
                        }
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
                      validator: (value) {
                        if (value == null || value.isEmpty ) {
                          return 'Please enter a maximum price.';
                        }
                        if (!isValidPrice(value)) {
                          return 'Please enter a valid price.';
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (_priceRangeKey.currentState!.validate()){
                          setState((){
                          minPrice = double.parse(minPriceController.text);
                          maxPrice = double.parse(maxPriceController.text);                    
                          });
                          Navigator.pop(context);
                        }
                      },
                    )
                  )
                ])
              )
            ])
          )
        )
      ], 
    );
  }

}

void sortItems(sortBy, List<dynamic> JSONItems){
  if (sortBy == 'DATE'){
    JSONItems.sort((b, a) => a['date_added'].compareTo(b['date_added']));
  }
  else if (sortBy == 'PRICE'){
    JSONItems.sort((a, b) => a['price'].compareTo(b['price']));
  }
  else if (sortBy == 'RELEVANCE'){
    JSONItems.sort((a, b) => a['num_matching_tags'].compareTo(b['num_matching_tags']));
  }
  else if (sortBy == 'DISTANCE'){
    JSONItems.sort((a, b) => a['distance'].compareTo(b['distance']));
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
      date_added: DateTime.fromMillisecondsSinceEpoch(int.parse(item['date_added'])),
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
      date_added: DateTime.fromMillisecondsSinceEpoch(int.parse(item['date_added'])),
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

bool isValidZip(zip){
  try {
    int.parse(zip);
  } 
  on FormatException {
    return false;
  }

  if (zip.length == 5){
    return true;
  }
  else {
    return false;
  }
}

bool isValidPrice(String value) {
  try {
    double.parse(value);
  } 
  on FormatException {
    return false;
  }

  if (double.parse(value) >= 0){
    return true;
  }
  else {
    return false;
  }
}