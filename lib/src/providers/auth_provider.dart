import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  User? _user;
  User? get user => _user;

  String userEmail = '';
  
  Future<void> signInAnonymously() async {
    UserCredential userCredential = await _auth.signInAnonymously();
    _user = userCredential.user;
    notifyListeners();
  }

  Future<String> uploadProfilePicture(File profilePicture) async {
    final ref = _storage.ref().child('profile_pictures').child('${_user!.uid}.jpg');
    final compressedImage = await _compressImage(profilePicture);

    final uploadTask = ref.putFile(compressedImage);

    await uploadTask;
    return await ref.getDownloadURL();
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

  Future<void> addUser(String firstName, String lastName, String email, String profilePictureUrl) async {
    userEmail = email;
    await _database.ref('Users/${_user!.uid}').set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    });
  }
}
