import 'dart:convert';
import "dart:io";

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../account.dart';
import '../components/square_text_field.dart';
import '../server_url.dart';
import './aws/generate_image_url.dart';
import './aws/upload_file.dart';

class ListItemScreen extends StatelessWidget {

  final void Function() updateItems;

  const ListItemScreen({ Key? key, required this.updateItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(children: [
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
      body: ItemForm(updateItems: updateItems),
    );
  }
}

class ItemForm extends StatefulWidget {
  final void Function() updateItems;

  const ItemForm({ Key? key, required this.updateItems }) : super(key: key);

  @override
  _ItemFormState createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  final picker = ImagePicker();
  var imagePath = null;
  var imageFile = null;


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
                GetPhoto(),
                SquareTextField(
                    fieldController: titleController, hintText: 'Title'),
                PriceField(priceController),
                SquareTextField(
                    fieldController: descriptionController,
                    hintText: 'Description'),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          /* ***************************
                    Need to add photos, get seller_id and location from current user

                    ***************************** */

                          postItem(titleController.text, priceController.text,
                              descriptionController.text, imagePath, context);

                          //Reset fields and hide keyboard
                          _formKey.currentState?.reset();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                        }
                      },
                      child: const Text('Post Item!'),
                    ))
              ],
            )
        )
    );
  }

  Widget GetPhoto() {
    return Padding(
        padding: EdgeInsets.all(20),
        child: AspectRatio(
            aspectRatio: 1,
            // Start with no photo, so we display two buttons
            child: imageFile == null
                ? Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green)),
                          onPressed: () {
                            _getFromGallery();
                          },
                          child: Text("PICK FROM PHOTOS"),
                        ),
                        Container(
                          height: 40.0,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green)),
                          onPressed: () {
                            _getFromCamera();
                          },
                          child: Text("TAKE PHOTO WITH CAMERA"),
                        )
                      ],
                    ),
                  )
                : Container(
                    // if a photo is selected, we display it instead
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  )
        )
    );
  }

  _getFromGallery() async {
    // Gets photo from photo library / gallery
    final picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,

    );
    print('-Path: ${pickedFile?.path}');
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
        imagePath = pickedFile.path;
      });
    }
  }

  _getFromCamera() async {
    // Gets photo from camera
    XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
        imagePath = pickedFile.path;
      });
    }
  }
}

Widget PriceField(TextEditingController priceController) {
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
                if (value == null || value.isEmpty) {
                  return 'Please enter a price.';
                }
                if (!isValidPrice(value)) {
                  return 'Please enter a valid price.';
                }
              })));
}


void postItem(String title, String price, String description, var imagePath, updateItems
    BuildContext context) async {
  var photoslist = [];
  try {
    if (imagePath != null) {
      // Get s3 location for image
      Map urlInfo = await generateImageURL(XFile(imagePath));
      // Send file to s3 location
      await uploadFile(urlInfo['uploadUrl'], XFile(imagePath));
      // create photos entry
      photoslist = [
        {'caption': 'No Caption', 'URL': urlInfo['fileName']}
      ];
    }
    // create entire post json
    var newItem = {
      'title': title,
      'price': double.parse(price),
      'description': description,
      'seller_id': currentUser.id,
      'location': currentUser.zip,
      'status': 'For Sale',
      'photos': photoslist
    };
    var response = await http.post(Uri.parse('${hostURL}:${port}/items'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newItem));
    //If success display success message otherwise display error message.
    if (response.statusCode == 201) {
      final successBar =
          SnackBar(content: Text('Thank you for posting this item!'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    } else {
      final successBar =
          SnackBar(content: Text('Error posting item. Please try again.'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    }
  } catch (e) {
    print('Error posting item -- ${e}');
    final successBar =
        SnackBar(content: Text('Error posting item. Please try again.'));
  }
}

  updateItems();
  //If success display success message otherwise display error message. 
  if(response.statusCode == 201){
    final successBar = SnackBar(content: Text('Thank you for posting this item!'));
    ScaffoldMessenger.of(context).showSnackBar(successBar);
  }
}

bool isValidPrice(String value) {
  try {
    double.parse(value);
  } on FormatException {
    return false;
  }

  return true;
}
