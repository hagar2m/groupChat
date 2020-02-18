import 'package:chatdemo/screens/groupChat.dart';
import 'package:chatdemo/screens/groupCreate.dart';
import 'package:chatdemo/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../models/userModel.dart';
import '../models/auth.dart';

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
    currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
  }

  void finishChoosing(UserModel selectedUser) async {
    var threadId;
    String _threadName = selectedUser.nickname;
    // create thread id //
    if (currentUserId.hashCode <= selectedUser.id.hashCode) {
      threadId = '$currentUserId-${selectedUser.id}';
    } else {
      threadId = '${selectedUser.id}-$currentUserId';
    }

    Firestore.instance.collection('threads').document(threadId).setData({
      'name': _threadName,
      'photoUrl': selectedUser.photoUrl,
      'id': threadId,
      'users': [
        Firestore.instance.collection('users').document(currentUserId),
        Firestore.instance.collection('users').document(selectedUser.id)
      ],
    });

    Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) =>
        GroupChat(
          threadId: threadId, 
          threadName: _threadName, 
          userModel: selectedUser
        )
      )
    );
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
      body: LoadingStack(
          isLoading: isLoading,
          child: Container(
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
                        photoUrl: groupPhoto,
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
      ),
    );
  }
}
