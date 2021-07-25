import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<bool> uploadFile(String url, XFile imageFile) async {
  try {
    Uint8List bytes = await imageFile.readAsBytes();
    var response = await http.put(Uri.parse(url), body: bytes);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    throw ('Error uploading photo');
  }
}
