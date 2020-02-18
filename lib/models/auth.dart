import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _currentUserId = '';

  bool get isLoggedIn {
    return _isLoggedIn ;
  }

 String get currentUserId {
    return _currentUserId;
  }

  Future<void> cheackSignIn() async{
    final GoogleSignIn googleSignIn = GoogleSignIn();
    // SharedPreferences prefs  = await SharedPreferences.getInstance();

    _isLoggedIn = await googleSignIn.isSignedIn();
    print('----------------\n isLoggedIn in cheackSignIn: $isLoggedIn');

    // _currentUserId = prefs.getString('id');
    // print('currentUserId: $currentUserId');
      // notifyListeners();

    notifyListeners();
  }
}