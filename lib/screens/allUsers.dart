import 'package:chatdemo/screens/chat.dart';
import 'package:chatdemo/screens/groupCreate.dart';
import 'package:chatdemo/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/colors.dart';
import '../models/userModel.dart';

class AllUsers extends StatefulWidget {
  static String routeName = '/allusers';
  @override
  State createState() => AllUsersState();
}

class AllUsersState extends State<AllUsers> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  bool isLoading = false;
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  readLocal() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('id');
    });
  }

  void finishChoosing(UserModel selectedUser) async {
    //   // type: 0 = text, 1 = image, 2 = sticker
    var threadId;

     if (currentUserId.hashCode <= selectedUser.id.hashCode) {
      threadId = '$currentUserId-${selectedUser.id}';
    } else {
      threadId = '${selectedUser.id}-$currentUserId';
    }

    Firestore.instance.collection('threads').document(threadId).setData({
      'name': selectedUser.nickname,
      'photoUrl': selectedUser.photoUrl,
      'id': threadId,
      'users': [
        Firestore.instance.collection('users').document(currentUserId),
        Firestore.instance.collection('users').document(selectedUser.id)
      ],
      'lastMessage': '',
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch.toString()
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Chat(threadId: threadId, user: selectedUser)));

    // List users;
    // users.contains((DocumentReference u) => u.documentID == "")
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select one',
          style: TextStyle(color: thirdColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          // List
          Container(
            child: StreamBuilder(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: snapshot.data.documents.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        UserModel fakeuserModel = UserModel(
                          nickname: 'Create Group',
                          photoUrl:
                              'https://www.pngitem.com/pimgs/m/144-1447051_transparent-group-icon-png-png-download-customer-icon.png',
                        );
                        return UserItem(
                            user: fakeuserModel,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => GroupCreateScreen()));
                            });
                      } else {
                        UserModel user = UserModel.fromJson(
                            snapshot.data.documents[index - 1].data);
                        if (user.id == currentUserId) {
                          return SizedBox();
                        }
                        return UserItem(
                            user: user, onPressed: () => finishChoosing(user));
                      }
                    },
                  );
                }
              },
            ),
          ),

          // Loading
          Positioned(
            child: isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor)),
                    ),
                    color: Colors.white.withOpacity(0.8),
                  )
                : Container(),
          )
        ],
      ),
    );
  }
}
