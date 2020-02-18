import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './utils/colors.dart';

import './models/auth.dart';
import './screens/allUsers.dart';
import './screens/groupCreate.dart';
import './screens/home.dart';
import './screens/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: AuthProvider(),
          ),
        ],
        child: MyMaterial()
        );
  }
}

class MyMaterial extends StatelessWidget {
  const MyMaterial({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
        title: 'Chat Demo',
        theme: ThemeData(
          primaryColor: primaryColor,
        ),
        home: Provider.of<AuthProvider>(context).isLoggedIn ? HomeScreen() : LoginScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          GroupCreateScreen.routeName: (_) => GroupCreateScreen(),
          AllUsers.routeName: (_) => AllUsers(),
        },
      );
  }
}
