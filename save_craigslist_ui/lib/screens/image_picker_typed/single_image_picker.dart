/* Single Image Picker uses photo library or camera, with permission, to 
    select a single image.
   Lifted from:
    https://github.com/GursheeshSingh/flutter_aws_s3_image_picker-master/blob/master/lib/image_picker/single_image_picker.dart
    */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../main.dart';
import '../aws/upload_file.dart';
import '../aws/generate_image_url.dart';
import './add_attachment_sheet.dart';
import './get_image_permission.dart';

typedef Future<bool> OnSaveImage(String url);

enum Source {GALLERY, CAMERA, NONE }

class SingleImagePicker {
    final ImageSource pickImageSource;
    final Function(String path) onImagePicked;
    final Function(String downloadUrl) onImageSuccessfullySaved;
    final OnSaveImage onSaveImage;
    final Function(String message) onImageUploadFailed;

    SingleImagePicker({
            this.pickImageSource = PickImageSource.both,
            required this.onImagePicked,
            required this.onSaveImage,
            required this.onImageSuccessfullySaved,
            required this.onImageUploadFailed,
    });

    final ImagePicker imagePicker = ImagePicker();

    Future<void> pickImage(context) async {
        try {
            ImageSource imageSource;

            if (pickImageSource == PickImageSource.both) {
                Size size = MediaQuery.of(context).size;
                var sheet = AddAttachmentModalSheet(size);
                await showModalBottomSheet(
                        context: context,
                        builder: (context) => sheet,
                        isScrollControlled: true,
                );

                if (sheet.source == Source.CAMERA) {
                    imageSource = ImageSource.camera;
                } else if (sheet.source == Source.GALLERY) {
                    imageSource = ImageSource.gallery;
                } else {
                    return;
                }
            } else if (pickImageSource == PickImageSource.camera) {
                imageSource = ImageSource.camera;

                GetImagePermission getPermission = GetImagePermission.camera();
                await getPermission.getPermission(context);

                if (getPermission.granted == false) {
                    return;
                }
            } else if (pickImageSource == PickImageSource.gallery) {
                imageSource = ImageSource.gallery;

                GetImagePermission getPermission = GetImagePermission.gallery();
                await getPermission.getPermission(context);

                if (getPermission.granted == false) {
                    return;
                }
            } else {
                // not sure why we would be here, but we should just return
                return;
            }

            PickedFile image = await imagePicker.getImage(source:imageSource);

            // we have an image.  Generate URL
            if (image != null) {
                onImagePicked?.call(image.path);
                String fileExtension = path.extension(image.path);
                GenerateImageUrl generateImageUrl = GemnerateImageUrl();
                await generateImageUrl.call(fileExtension);

                String uploadUrl;
                // we have a URL for s3.  Send file
                if (generateImageUrl.isGenerated != null &&
                        generateImageUrl.isGenerated) {
                    uploadUrl = generateImageUrl.uploadUrl;
                } else {
                    throw generateImageUrl.message;
                }

                UploadFile uploadFile = UploadFile();
                await uploadFile.call(uploadUrl, image);

                if (uploadFile.isUploaded != null && uploadFile.isUploaded) {
                    bool isSaved = await onSaveImage(generaetImageUrl.downloadUrl);
                    if (isSaved) {
                        onImageSuccessfullySaved(generateImageUrl.downloadUrl);
                    } else {
                        throw "Failed to save image";
                    }
                } else {
                    throw uploadFile.message;
                }
            }
        } catch (e) {
            onImageUploadFailed(e.toString());
        }
    }
}

                

