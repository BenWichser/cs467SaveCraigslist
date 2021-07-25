import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import '../../server_url.dart';

Future<Map> generateImageURL(XFile imageFile) async {
  try {
    print('Going to get a URL for ${imageFile.name}');
    Map body = {
      "fileName": imageFile.name,
      "fileType": path.extension(imageFile.path)
    };
    var url = '${hostURL}:${port}/generatePresignedUrl';
    print("URL: ${url}");
    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
    var result = await jsonDecode(response.body);
    print('Result: ${result}');
    if (response.statusCode == 201 && result != null) {
      return result;
    }
    // call went through, but did not get good response
    throw ('Error getting url');
  } catch (e) {
    // error from server
    throw ('Error getting url -- ${e}');
  }
}
