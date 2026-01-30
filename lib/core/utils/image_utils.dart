import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  static Future<String?> saveImagePermanently(File imageFile) async {
    try {
      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create a unique filename
      final String fileName = '${const Uuid().v4()}.jpg';
      final String permanentPath = '${appDir.path}/$fileName';

      // Copy the file to permanent location
      await imageFile.copy(permanentPath);

      return permanentPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving image permanently: $e');
      }
      return null;
    }
  }
}
