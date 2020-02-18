import 'dart:async';
import 'dart:io';
import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../widgets/widgets.dart';
import '../models/menuChoice.dart';
import '../models/userModel.dart';
import '../models/thread.dart';
import '../models/auth.dart';
import '../services/notificationSettings.dart';
import '../screens/allUsers.dart';
import '../screens/groupChat.dart';
import '../screens/groupCreate.dart';
import '../screens/login.dart';
import '../screens/settings.dart';

List<Choice> choices = const <Choice>[
  const Choice(title: 'Settings', icon: Icons.settings),
  const Choice(title: 'Log out', icon: Icons.exit_to_app),
  const Choice(title: 'New group', icon: Icons.group_add),
];

class HomeScreen extends StatefulWidget {
  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {


  bool isLoading = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String currentUserId;
  var _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setupNotification();
    
  }
  void setupNotification () async {
      currentUserId = Provider.of<AuthProvider>(context).currentUserId;
      // print('currentUserId in home: $currentUserId \n----------');

    if (currentUserId != '' && _isInit== true) {
      _isInit = false;
      NotificationSettings notificationSettings = NotificationSettings(
        context: context, 
        currentUserId: currentUserId
      );

      notificationSettings.registerNotification();
      notificationSettings.configLocalNotification();
    }
    
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else if (choice.title == 'New group') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => GroupCreateScreen()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Settings()));
    }
  }

  Future<bool> openDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: primaryColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, true);
                  exit(1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

  Future<Null> handleSignOut() async {
    // this.setState(() {
    //   isLoading = true;
    // });

    // await FirebaseAuth.instance.signOut();
    // await googleSignIn.disconnect();
    // await googleSignIn.signOut();

    // this.setState(() {
    //   isLoading = false;
    // });

    Provider.of<AuthProvider>(context, listen: false).signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: thirdColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: primaryColor,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: openDialog,
        child: LoadingStack(
          isLoading: isLoading,
          child: Container(
            child: StreamBuilder(
              stream: Firestore.instance.collection('threads').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                } else {
                  // get my threads
                  List threads = (snapshot.data.documents as List).where((t) {
                    return t.data['users']
                        .any((u) => u.documentID == currentUserId);
                  }).toList();

                  return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        return ThreadItem(
                            key: UniqueKey(),
                            thread: threads[index],
                            currentUserId: currentUserId);
                      });
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: Icon(Icons.message),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => AllUsers()));
        },
      ),
    );
  }
}

class ThreadItem extends StatefulWidget {
  final DocumentSnapshot thread;
  final String currentUserId;

  ThreadItem({this.thread, this.currentUserId, Key key}) : super(key: key);

  @override
  _ThreadItemState createState() => _ThreadItemState();
}

class _ThreadItemState extends State<ThreadItem> with AfterLayoutMixin {
  ThreadModel threadData;
  UserModel userModel;

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      setState(() {
        threadData = ThreadModel.fromJson(widget.thread.data);
      });
    }
    // get name and photo of second user
    if ((widget.thread.data["users"] as List).length == 2) {
      DocumentReference userRef = (widget.thread.data["users"] as List)
          .firstWhere((u) => u.documentID != widget.currentUserId);
      userRef.get().then((snap) {
        if (mounted) {
          setState(() {
            threadData.name = snap.data['nickname'];
            threadData.photoUrl = snap.data['photoUrl'];
            userModel = UserModel.fromJson(snap.data);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      child: FlatButton(
        child: Row(
          children: <Widget>[
            threadData != null
                ? ImageAvatar(imgUrl: threadData.photoUrl)
                : SizedBox(),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        threadData != null ? threadData.name : "",
                        style: TextStyle(color: textColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                    Container(
                      child: Text(
                        threadData != null ? threadData.lastMessage : "",
                        style: TextStyle(color: textColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        onPressed: _onPressed,
        color: thirdColor,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  void _onPressed() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroupChat(
                threadId: threadData.id,
                threadName: threadData.name,
                userModel: userModel)));
  }
}
