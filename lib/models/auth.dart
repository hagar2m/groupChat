import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _currentUserId = '';
  final GoogleSignIn googleSignIn = GoogleSignIn();

  AuthProvider() {
    cheackSignIn();
  }

  bool get isLoggedIn {
    return _isLoggedIn;
  }

  String get currentUserId {
    return _currentUserId;
  }

  Future<void> cheackSignIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _isLoggedIn = await googleSignIn.isSignedIn();
    // print('----------------\n isLoggedIn in cheackSignIn: $isLoggedIn');

    _currentUserId = prefs.getString('id');
    // print('currentUserId in cheackSignIn: $currentUserId');

    notifyListeners();
  }

  Future<void> signOut() async {
   
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    _isLoggedIn = false;
    // print('----------------\n isLoggedIn in cheackSignIn: $isLoggedIn');

    _currentUserId = '';
    // print('currentUserId: $currentUserId');

    notifyListeners();
  }

}
