import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wise/config/app.dart';

class ImageHelper {
  static Future<void> pickImage(BuildContext context, ImageSource source,
      Function(File) onImagePicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  static void showImageOptions(
      BuildContext context, Function(String) onOptionSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose an option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.image),
              title: Text('View Image'),
              onTap: () {
                Navigator.pop(context);
                onOptionSelected('view');
              },
            ),
            ListTile(
              leading: Icon(Icons.upload),
              title: Text('Upload New Image'),
              onTap: () {
                Navigator.pop(context);
                onOptionSelected('upload');
              },
            ),
          ],
        ),
      ),
    );
  }

  static void viewImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2, // Maximum zoom level
        ),
      ),
    );
  }

  static Future<bool> fileExists(String url) async {
    try {
      final Reference ref = FirebaseStorage.instance.refFromURL(url);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> uploadImage(
      File? image, TextEditingController controller, String path) async {
    String imageUrl = controller.text; // Default to the existing URL

    // If a new image is provided
    if (image != null) {
      String previousImageUrl = controller.text;

      // Check if the previous image exists before attempting to delete
      if (previousImageUrl.isNotEmpty &&
          previousImageUrl != App.newtWorkImageNotFound &&
          await fileExists(previousImageUrl)) {
        await FirebaseStorage.instance.refFromURL(previousImageUrl).delete();
      }

      // Create a reference for the new image upload
      Reference imageRef = FirebaseStorage.instance
          .ref()
          .child('$path/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the image and get the download URL
      await imageRef.putFile(image).then((taskSnapshot) async {
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      });
    }

    return imageUrl; // Return the resulting image URL
  }

static Future<void> deleteFolderFromStorage(String folderPath) async {
  try {
    Reference folderRef = FirebaseStorage.instance.ref().child(folderPath);

    // List all items in the folder
    ListResult result = await folderRef.listAll();

    if (result.items.isEmpty && result.prefixes.isNotEmpty) {
      // No files found directly in this folder, but there are subfolders
      for (var prefix in result.prefixes) {
        await deleteFolderFromStorage(prefix.fullPath); // Recursively delete contents in each subfolder
      }
    } else {
      // Delete all files in the current folder
      for (var item in result.items) {
        await item.delete();
      }

      // Recursively delete all subfolders
      for (var prefix in result.prefixes) {
        await deleteFolderFromStorage(prefix.fullPath);
      }
    }
  } catch (e) {
    throw Exception('Failed to delete folder from storage');
  }
}
}
