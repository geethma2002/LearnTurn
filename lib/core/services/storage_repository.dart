import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePhoto(String userId, File file, {bool isTutor = true}) async {
    final path = isTutor ? 'tutors/$userId/avatar' : 'students/$userId/avatar';
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadProfilePhotoFromBytes(String userId, Uint8List bytes, {bool isTutor = true}) async {
    final path = isTutor ? 'tutors/$userId/avatar' : 'students/$userId/avatar';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }
}
