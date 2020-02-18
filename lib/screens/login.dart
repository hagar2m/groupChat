import 'dart:async';
import 'package:chatdemo/models/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import '../utils/colors.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    // isSignedIn();
  }

  // void isSignedIn() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   prefs = await SharedPreferences.getInstance();

  //   isLoggedIn = await googleSignIn.isSignedIn();
  //   if (isLoggedIn) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: prefs.getString('id'))),
  //     );
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if(googleUser == null) {
      Fluttertoast.showToast(msg: "Sign in fail");
      setState(() {
        isLoading = false;
      });
      return;
    }
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {

      // Check is already sign up
      final QuerySnapshot result =
          await Firestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) { // if new user in our app
        // Update data to server if new user
        Firestore.instance.collection('users').document(firebaseUser.uid).setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
      }

      Provider.of<AuthProvider>(context, listen: false).cheackSignIn();

      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text(
        'Login',
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    ),
    body: LoadingStack(
      isLoading: isLoading,
      child: Center(
        child: FlatButton(
            onPressed: handleSignIn,
            child: Text(
              'SIGN IN WITH GOOGLE',
              style: TextStyle(fontSize: 16.0),
            ),
            color: Color(0xffdd4b39),
            highlightColor: Color(0xffff7f7f),
            splashColor: Colors.transparent,
            textColor: Colors.white,
            padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
      ),
    ));
  }
}
