import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;

class BoardUtil {

  
  static Color parseColor(String? hexString, {Color orElse = Colors.black}) {
    if (hexString == null || hexString.isEmpty || !hexString.contains("#")) {
      return orElse;
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<File?> pickImage() async {
    try {
      img_picker.ImagePicker picker = img_picker.ImagePicker();
      img_picker.XFile? pickedFile = await picker.pickImage(
        source: img_picker.ImageSource.gallery,
        maxWidth: 6000,
        maxHeight: 6000,
        imageQuality: 100,
      );
      final file = File(pickedFile!.path!);
      return file;
    } catch (e) {
      return null;
    }
  }
}
