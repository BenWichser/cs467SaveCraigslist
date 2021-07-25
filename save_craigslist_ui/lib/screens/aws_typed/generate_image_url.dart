/* Generates image URL.
   Lifted from:
   https://github.com/GursheeshSingh/flutter_aws_s3_image_picker-master/blob/master/lib/aws/generate_image_url.dart
   */
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../../server_url.dart';

class GenerateImageUrl {
    /* GenerateImageUrl
       Commnicates with Node server, and gets a s3 code from it.
    */
    bool success;
    String message;

    bool isGenerated;
    String uploadUrl;
    String downloadUrl;

    Future<void> call(String fileType) async {
        // send file name to server
        try {
            Map body = {"fileType": fileType};

            var response = await http.post(
                'http://${hostURL}:${port}/generatePredesignedUrl';
                body: body,
                );

            var result = jsonDecode(response.body);

            // check if there is any response from server
            if (result['success'] != null) {
            success = result['success'];
            message = result['message'];

            // if response is positive
            if (response.statusCode == 201) {
                isGenerated = true;
                uploadUrl = result["uploadUrl"];
                downloadUrl = result["downloadUrl"];
                }
            }
        } catch (e) {
            throw ('Error getting url');
        }
    }
}

