import 'package:chatdemo/screens/allUsers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import './utils/colors.dart';

import './screens/screens.dart';
import './models/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = false;
  bool isLoggedIn = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() { 
    super.initState();
    readLocal();
  }
  
  readLocal() async {
    setState(() {
      isLoading = true;
    });

    isLoggedIn = await googleSignIn.isSignedIn();
   
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: AuthProvider(),
          ),
        ],
        child:  MaterialApp(
            title: 'Chat Demo',
            theme: ThemeData(
              primaryColor: primaryColor,
            ),

            home: isLoading ? SplashScreen() : isLoggedIn ? HomeScreen() : LoginScreen(),

            debugShowCheckedModeBanner: false,
            routes: {
              GroupCreateScreen.routeName: (_) => GroupCreateScreen(),
              AllUsers.routeName: (_) => AllUsers(),
            },
          )
        );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('......'),
      ),
    );
  }
}
