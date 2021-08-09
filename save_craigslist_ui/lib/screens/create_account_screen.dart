import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "dart:io";
import '../components/square_text_field.dart';
import '../server_url.dart';
import './aws/generate_image_url.dart';
import './aws/upload_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Create New Account')),
        body: Center(child: NewAccountForm()));
  }
}

class NewAccountForm extends StatefulWidget {
  const NewAccountForm({Key? key}) : super(key: key);

  @override
  _NewAccountFormState createState() => _NewAccountFormState();
}

class _NewAccountFormState extends State<NewAccountForm> {
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
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController zipController = TextEditingController();

    return SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  GetPhoto(),
                  SquareTextField(
                      fieldController: usernameController, hintText: 'Username'),
                  SquareTextField(
                      fieldController: passwordController, hintText: 'Password'),
                  SquareTextField(
                      fieldController: emailController,
                      hintText: 'Email Address'),
                  SquareTextField(
                      fieldController: zipController, hintText: 'Zip Code'),
                  Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createUser(
                                usernameController.text,
                                passwordController.text,
                                emailController.text,
                                zipController.text,
                                imagePath,
                                context);

                            //Reset fields and hide keyboard
                            _formKey.currentState?.reset();
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                          }
                        },
                        child: const Text('Create Account!'),
                      )
                    )
                ],
              )
            )
          )
        );
  }

  Widget GetPhoto() {
    return AspectRatio(
      aspectRatio: 1,
      // Start with no photo, so we display two buttons
      child: imageFile == null
      ? AspectRatio(
        aspectRatio: 1,
        child:
        Container(child:
          Stack(
            children: [
            //Image
            Container(
              padding: EdgeInsets.zero,
              child: Image.asset('assets/images/blank_profile_picture.png')
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
    : Container(
        // if a photo is selected, we display it instead
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      ));
  }

  _getFromGallery() async {
    // Gets photo from photo library / gallery
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

void createUser(String username, String password, String email, String zip,
    var imagePath, BuildContext context) async {
  var newUser = {
    'username': username,
    'password': password,
    'email': email,
    'zip': zip,
  };
  try {
    if (imagePath != null) {
      // Get s3 location for image
      Map urlInfo = await generateImageURL(XFile(imagePath), "users", fileName:'');
      // send file to s3 location
      await uploadFile(urlInfo['uploadUrl'], XFile(imagePath));
      newUser['photo'] = urlInfo['fileName'];
    }
    var response = await http.post(Uri.parse('${hostURL}:${port}/users'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newUser));
    //If success display success message otherwise display error message.
    if (response.statusCode == 201) {
      final successBar =
          SnackBar(content: Text('Your account has been created!'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
      Navigator.pop(context);
    } else {
      final successBar =
          SnackBar(content: Text('Error creating account. Please try again.'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    }
  } catch (e) {
    print('Error creating user ${username} -- ${e}');
    final successBar =
        SnackBar(content: Text('Error creating account.  Please try again.'));
    ScaffoldMessenger.of(context).showSnackBar(successBar);
  }
}
