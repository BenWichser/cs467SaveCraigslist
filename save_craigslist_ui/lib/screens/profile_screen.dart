import 'dart:math';
import '../models/user.dart';
import 'package:flutter/material.dart';
import 'package:save_craigslist_ui/components/square_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import "dart:io";
import 'dart:convert';
import '../account.dart';
import '../server_url.dart';
import './aws/generate_image_url.dart';
import './aws/upload_file.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController emailController =
      TextEditingController(text: currentUser.email);
  TextEditingController zipController =
      TextEditingController(text: currentUser.zip);

  bool editMode = false;
  final picker = ImagePicker();
  var imageFile = null;
  var imagePath = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: SingleChildScrollView(
            child: Column(children: [
          profilePhoto(),
          username(),
          email(),
          zip(),
          editProfileButton()
        ])));
  }

  Widget profilePhoto() {
    print(currentUser.photo);
    return Container(
        padding: EdgeInsets.all(20),
        child: AspectRatio(
            aspectRatio: 1,
            child: !editMode
                ?
                // if not edit mode, we show image
                Image.network('${currentUser.photo}',
                    key: ValueKey(new Random().nextInt(100)))
                :
                // if edit mode, we show image with button above
                Stack(children: <Widget>[
                    new Container(
                        padding: EdgeInsets.zero,
                        child: imagePath == null
                            // if image hasn't changed yet, show old photo
                            ? Image(
                                image: NetworkImage('${currentUser.photo}'),
                                fit: BoxFit.fitWidth)
                            // if image has changed, show new photo
                            : Image.file(File(imagePath),
                                fit: BoxFit.fitWidth)),
                    Container(
                        alignment: Alignment.bottomLeft,
                        child: new ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green)),
                            onPressed: () {
                              _getFromGallery();
                            },
                            child: Text("PICK FROM \n PHOTOS"))),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: new ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green)),
                          onPressed: () {
                            _getFromCamera();
                          },
                          child: Text("TAKE PHOTO \n WITH CAMERA")),
                    )
                  ])));
  }

  Widget username() {
    return Container(
        padding: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 1.0, color: Colors.black))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Username:'), Text(currentUser.id)]));
  }

  Widget email() {
    return Container(
        padding: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 1.0, color: Colors.black))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Email:'),
          !editMode
              ? Text(currentUser.email)
              : SquareTextField(
                  fieldController: emailController, hintText: 'email')
        ]));
  }

  Widget zip() {
    return Container(
        padding: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 1.0, color: Colors.black))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Zip Code:'),
          !editMode
              ? Text(currentUser.zip)
              : SquareTextField(
                  fieldController: zipController, hintText: 'zip code')
        ]));
  }

  Widget editProfileButton() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: editMode
            ? ElevatedButton(
                onPressed: () {
                  updateUserInfo(emailController.text, zipController.text);
                  setState(() {
                    // editMode = !editMode;
                  });
                },
                child: const Text('Save'),
              )
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    editMode = !editMode;
                  });
                },
                child: const Text('Edit Profile'),
              ));
  }

  void updateUserInfo(email, zip) async {
    editMode = !editMode;
    var userInfo = {
      'email': email,
      'zip': zip,
    };
    // if image was selected, get a URL from s3 and upload to s3
    if (imagePath != null) {
      try {
        var fileName = currentUser.photo != currentUser.defaultPhoto
            ? currentUser.photo
            : '';
        Map urlInfo = await generateImageURL(XFile(imagePath), "users",
            fileName: fileName);
        print(urlInfo);
        userInfo['photo'] = urlInfo['fileName'];
        await uploadFile(urlInfo['uploadUrl'], XFile(imagePath));
      } catch (e) {
        final photoErrorBar =
            SnackBar(content: Text('Error uploading new photo'));
        ScaffoldMessenger.of(context).showSnackBar(photoErrorBar);
        Navigator.pop(context);
        return;
      }
    }
    var response = await http.patch(
        Uri.parse('${hostURL}:${port}/users/${currentUser.id}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userInfo));
    print(response.statusCode);
    //If success display success message otherwise display error message.
    if (response.statusCode == 200) {
      //Update current user
      var userInfo = jsonDecode(response.body);
      if (userInfo.containsKey('photo')) {
        currentUser = User(
            email: userInfo['email']!,
            id: userInfo['id']!,
            zip: userInfo['zip'],
            photo:
                'https://savecraigslistusers.s3.us-east-2.amazonaws.com/${userInfo['photo']!}');
      } else {
        currentUser = User(
          email: userInfo['email']!,
          id: userInfo['id']!,
          zip: userInfo['zip'],
        );
      }
      imageCache?.clear();
      imageCache?.clearLiveImages();
      setState(() {});

      final successBar =
          SnackBar(content: Text('Your account details have been updated!'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    } else {
      final successBar = SnackBar(
          content: Text('Error updating account details. Please try again.'));
      ScaffoldMessenger.of(context).showSnackBar(successBar);
    }
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
