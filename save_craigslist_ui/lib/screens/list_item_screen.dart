import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../server_url.dart';
import '../account.dart';
import '../components/square_text_field.dart';


class ListItemScreen extends StatelessWidget {
  const ListItemScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: ItemForm(),
    );
  }
}


class ItemForm extends StatefulWidget {
  const ItemForm({ Key? key }) : super(key: key);

  @override
  _ItemFormState createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();


    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            UploadPhotos(),
            SquareTextField(
              fieldController: titleController,
              hintText: 'Title'),
            PriceField(priceController),
            SquareTextField(
              fieldController: descriptionController,
              hintText: 'Description'),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  if(_formKey.currentState!.validate()){
                    /* ***************************
                    Need to add photos, get seller_id and location from current user

                    ***************************** */
                    postItem(
                      titleController.text, 
                      priceController.text, 
                      descriptionController.text,
                      context);

                    //Reset fields and hide keyboard
                    _formKey.currentState?.reset();
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  }
                },
                child: const Text('Post Item!'),
                )
            )
          ],
        )
      )
    );
  }
}

Widget UploadPhotos(){
  return Padding(padding: EdgeInsets.all(20), 
    child: AspectRatio(
      aspectRatio: 1, 
      //This needs to be replaced with the main item photo
      child: Placeholder()
      //eventually add more photos to be displayed below
    )
  ); 
}

Widget PriceField(TextEditingController priceController){
  return Padding(
    padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
    child: Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: TextFormField(
        controller: priceController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Price',
        ),
      validator: (value) {
        if (value == null || value.isEmpty){
          return 'Please enter a price.';
        }
        if (!isValidPrice(value)){
          return 'Please enter a valid price.';
        }
      }
      )
    )
  );   
}

void postItem(String title, String price, String description, BuildContext context) async {
    
  //NEED TO ADD PHOTOS AND LOCATION
  var newItem = {
    'title': title,
    'price': double.parse(price),
    'description': description,
    'seller_id': currentUser.id,
    'location': currentUser.zip,
    'status': 'For Sale'
  };

  var response = await http.post(Uri.parse('${hostURL}:${port}/items'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(newItem)
  );

  //If success display success message otherwise display error message. 
  if(response.statusCode == 201){
    final successBar = SnackBar(content: Text('Thank you for posting this item!'));
    ScaffoldMessenger.of(context).showSnackBar(successBar);
  }
  else {
    final successBar = SnackBar(content: Text('Error posting item. Please try again.'));
    ScaffoldMessenger.of(context).showSnackBar(successBar);
  };

}

bool isValidPrice(String value){
  try{
    double.parse(value);
  }
  on FormatException{
    return false;
  }

  return true;
}