import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> addUser(String uid, String firstName, String lastName,
      String email, String profilePictureUrl) async {
    await _database.ref('Users/$uid').set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    });
  }

  Future<File> _compressImage(File file) async {
    final compressedImage = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 85,
    );
    return File(file.path)..writeAsBytesSync(compressedImage!);
  }

  Future<String> uploadProfilePicture(String uid, File profilePicture) async {
    final ref = _storage.ref().child('profile_pictures').child('$uid.jpg');
    final compressedImage = await _compressImage(profilePicture);

    final uploadTask = ref.putFile(compressedImage);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      switch (snapshot.state) {
        case TaskState.running:
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print("Upload is $progress% complete.");
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.success:
          print("Upload was successful.");
          break;
        case TaskState.canceled:
          print("Upload was canceled.");
          break;
        case TaskState.error:
          print("Upload failed.");
          break;
      }
    });

    await uploadTask;
    return await ref.getDownloadURL();
  }

  Future<User?> signInAnonymously() async {
    UserCredential userCredential = await _auth.signInAnonymously();
    return userCredential.user;
  }
}
