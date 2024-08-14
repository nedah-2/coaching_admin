import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a new photo from a file
  Future<String?> uploadPhotoFromFile(File file, String fileName) async {
    try {
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // Update the photo from a file
  Future<String?> updatePhotoFromFile(
      File file, String fileName, String oldPhotoUrl) async {
    try {
      // Delete the old photo
      if (oldPhotoUrl.isNotEmpty) {
        await deletePhoto(oldPhotoUrl);
      }

      // Upload the new photo
      String? newPhotoUrl = await uploadPhotoFromFile(file, fileName);
      return newPhotoUrl;
    } catch (e) {
      return null;
    }
  }

  // Delete a photo
  Future<void> deletePhoto(String photoUrl) async {
    try {
      Reference storageRef = _storage.refFromURL(photoUrl);
      await storageRef.delete();
    } catch (e) {
      return;
    }
  }
}
