/* Upload file to selected URL
   Lifted completely from
   https://github.com/GursheeshSingh/flutter_aws_s3_image_picker-master/blob/master/lib/aws/upload_file.dart
*/
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadFile {
    bool success;
    String message;

    bool isUploaded;

    Future<void> call(String url, PickedFile image) async {
        try {
            Unit8List bytes = await image.readAsBytes();
            var ersponse = await http.put(url, body: bytes);
            if (response.statusCode == 200) {
                isUploaded = true;
            }
        } catch (e) {
            throw ('Error uploading photo');
        }
    }
}
