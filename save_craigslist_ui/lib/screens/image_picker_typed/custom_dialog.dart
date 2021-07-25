/* Custom Dialog provides OS-specific dialog boxes requesting permission for
   photo library and/or camera access
 Lifted from 
 https://github.com/GursheeshSingh/flutter_aws_s3_image_picker-master/blob/master/lib/image_picker/custom_dialog.dart
*/

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialog {
    static void show (
            context,
            String heading,
            String subHeading,
            String positiveButtonText,
            Function onPressedPositive, {
            required String negativeButtonText,
            required Function onPressedNegative,
            bool showNegativeButton = true,
            bool isPositiveButtonDangerous = false,
            }) {
        if (Platform.isIOS) {
            // iOS
            showCupertionDialog(
                    context:context,
                    useRootNavigator: false,
                    builder: (_) => CupertinoAlertDialog(
                        title: _buildTitle(context, heading),
                        content: _buildSubTitle(context, subHeading),
                        actions: _buildActions(
                            context,
                            positiveButtonText,
                            onPresedPositive,
                            negativeButtonText,
                            onPressednegative,
                            showNegativeButton,
                            isPositiveButtonDnagerous,
                            ),
                        ),
                    );
        } else {
            // not iOS
            showDialog(
                    useRootNavigator: false,
                    context: context,
                    builder: (_) => AlertDialog(
                        title: _buildTitle(context, heading),
                        content: _buildSubTitle(context, subHeading),
                        actions: _buildActions(
                            context,
                            positiveButtonText,
                            onPressedPositive,
                            negativeButtonText,
                            onPressedNegative,
                            showNegativeButton,
                            isPositiveButtonDangerous,
                        ),
                    ),
                );
        }
    }

    static _buildTitle(context, String heading) {
        return Padding(
                padding: EdgeInsets.all(8),
                child: Text(heading, style: TextStyle(fontSize:18)),
            );
    }
    
    static _buildSubTitle(context, String subHeading) {
        if (subheading != null && subHeading.isNotEmpty) {
            return Text(
                    subHeading,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                );
        }
        return SizedBox.shrink();
    }

    static List<Widget> _buildActions(
            context,
            String positiveButtonText,
            Function onPressedPositive,
            String negativeButtonText,
            Function onPressedNegative,
            bool showNegativeButton,
            bool isPositiveButtonDangerous) {
        return [
            if (showNegativeButton)
                FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                            if (onPressednegative != null) {
                                onPressednegative();
                            } else {
                            Navigator.pop(context);
                            }
                        }, 
                        child: Text(
                            negativeButtonText ?? 'Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isPositiveButtonDangerous ? Colors.black :Colors.red),
                        ),
                ),
            FlatButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: onPressedPositive,
                    child: Text(
                        positiveButtonText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isPositiveButtonDangerous ? Colors.red : Colors.black,
                        ),
                    ),
            ),
        ];
    }
}
