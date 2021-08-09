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
    return ItemForm(updateItems: updateItems);
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
    TextEditingController tagsController = TextEditingController();

    return SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  GetPhoto(),
                  SquareTextField(
                    fieldController: titleController, 
                    hintText: 'Title',
                    validator: (value) {
                      if (value == null || value.isEmpty){
                        return 'Required Field!';
                      }
                      if (value.length > 40){
                        return 'Too many characters';
                      }
                    }
                  ),
                  SquareTextField(
                    fieldController: priceController,
                    hintText: 'Price',
                    validator: (value) {
                      if (value == null || value.isEmpty ) {
                        return 'Required Field';
                      }
                      if (!isValidPrice(value)) {
                        return 'Please enter a valid price.';
                      }
                    }
                  ),
                  SquareTextField(
                      fieldController: descriptionController,
                      hintText: 'Description (optional)',
                      validator: (value) {}
                  ),
                  SquareTextField(
                    fieldController: tagsController, 
                    hintText: 'Tags (optional)',
                    validator: (value) {}
                  ),
                  Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            postItem(titleController.text, priceController.text, descriptionController.text, tagsController.text, imagePath, widget.updateItems, context);

                            //Reset fields and hide keyboard
                            _formKey.currentState?.reset();
                            SystemChannels.textInput.invokeMethod('TextInput.hide');

                            //Clear photo
                            setState((){
                              imageFile = null;
                            });
                          }
                        },
                        child: const Text('Post Item!'),
                      )
                  ),
                ],
              )
            )
        )
    );
  }

  Widget GetPhoto() {
    return imageFile == null
          ? AspectRatio(
              aspectRatio: 1,
              child:
              Container(child:
                Stack(
                  children: [
                  //Image
                  Container(
                    padding: EdgeInsets.zero,
                    child: Image.asset('assets/images/placeholder_image.png')
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10), 
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle
                        ),
                        child: PopupMenuButton<Widget>(
                        icon: Icon(Icons.photo_camera, size: 30, color: Colors.white),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {
                                _getFromGallery();
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.insert_photo_outlined), 
                                  SizedBox(width: 5),
                                  Text('Select Photo')
                                ]
                              ) 
                            )
                          ),
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {
                                _getFromCamera();
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.photo_camera_outlined), 
                                  SizedBox(width: 5),
                                  Text('Take Photo')
                                ]
                              ) 
                            )
                          )],
                        )
                      )
                    )
                  ),
                ]
              )
            )
          )
      : AspectRatio(
          aspectRatio: 1, 
          child: Container(
            // if a photo is selected, we display it instead
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
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

void postItem(String title, String price, String description, String tags, var imagePath, updateItems, BuildContext context) async {
  var photoslist = [];
  try {
    if (imagePath != null) {
      // Get s3 location for image
      Map urlInfo = await generateImageURL(XFile(imagePath), "items");
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
      'photos': photoslist,
      'tags': tags
    };

    var response = await http.post(
        Uri.parse('${hostURL}:${port}/items'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newItem)
    );

    //If success display success message otherwise display error message.
    if (response.statusCode == 201) {
      final successBar = SnackBar(content: Text('Thank you for posting this item!'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
      updateItems();
    } 
    else {
      final successBar = SnackBar(content: Text('Error posting item. Please try again.'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    }
  } 
  catch (e) {
    print('Error posting item -- ${e}');
    final successBar = SnackBar(content: Text('Error posting item. Please try again.'));
    ScaffoldMessenger.of(context).showSnackBar(successBar);
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
