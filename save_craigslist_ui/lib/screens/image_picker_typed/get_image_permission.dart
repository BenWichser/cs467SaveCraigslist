/* Goes through permission checks for photo library and camera access.
   Lifted directly from:
   https://github.com/GursheeshSingh/flutter_aws_s3_image_picker-master/blob/master/lib/image_picker/get_image_permission.dart
*/

import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import 'custom_dialog.dart';

class GetImagePermission {
    bool granted = false;

    Permission _permission;
    final String subHeading;

    GetImagePermission.gallery(
            {this.subHeading = "Photos permission is needed to select photos"}){
        if (Platform.isIOS) {
            _permission = Permission.photos;
        } else {
            _permission = Permission.storage;
        }
    }

    GetImagePermission.camera(
            {this.subHeading = "Camera permission is needed to click photos"}) {
        _permission = Permission.camera;
    }

    Future<void> getPermission(context) async {
        PermissionStatus permissionStatus = await _permission.status;

        if (permissionStatus == PermissionStatus.restricted) {
            _showOpenAppSettingsDialog(context, subHeading);

            permissionStatus = await _permission.status;

            if (permissionStatus != PermissionStatus.granted) {
                // we do not continue if not granted
                return;
            }
        }

        if (permissionStatus == PermissionStatus.permanantlyDenied) {
            _showOpenAppSettingsDialog(context, subHeading);

            permissionStatus = await _permission.status;

            if (permissionStatus != PermissionStatus.granted) {
                // again, do not continue if not granted
                return;
            }
        }

        if (permissionStatus == PermissionStatus.undetermined) {
            permissionStatus = await_permission.request();

            if (permissionStatus != PermissionStatus.granted) {
                // yet again, do not continue if not granted
                return;
            }
        }

        if (permissionStatus == PermissionStatus.denied) {
            if (Platform.isIOS) {
                _showOpenAppSettingsDialog(context, subHeading);
            } else {
                permissionsStatus = await_permisssion.request();
            }
            if (PermissionStatus != PermissionStatus.granted) {
                // only continue if granted
                return;
            }
        }

        if (permissionStatus == PermissionStatus.granted) {
            granted = true;
            return;
        }
    }

    _showOpenAppSettingsDialog(context, String subHeading) {
        return CustomDialog.show(
                context,
                'Permission needed',
                subHeading,
                'Open settings',
                openAppSettings,
        );
    }
}
