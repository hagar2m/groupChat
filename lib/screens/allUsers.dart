import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatdemo/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/colors.dart';

class AllUsers extends StatefulWidget {
  static String routeName = '/allusers';
  @override
  State createState() => AllUsersState();
}

class AllUsersState extends State<AllUsers> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  bool isLoading = false;
  bool showSelect = false;
  String currentUserId = '';
  // List _selecteItems = List();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  readLocal() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('id');
      // _selecteItems.add(currentUserId);
    });
  }

  void finishChoosing(DocumentSnapshot item) async {
    //   // type: 0 = text, 1 = image, 2 = sticker
    var threadId =
        item['id'] + DateTime.now().millisecondsSinceEpoch.toString();

    var prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('nickname') ?? '';
    Firestore.instance.collection('threads').document(threadId).setData({
      'name': item['nickname'],
      'photoUrl': item['photoUrl'],
      'id': threadId,
      'users': [
        Firestore.instance.collection('users').document(currentUserId),
        Firestore.instance.collection('users').document(item['id'])
      ],
      'lastMessage': {}
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Chat(peerId: threadId, peerAvatar: item['photoUrl'])));

    // List users;
    // users.contains((DocumentReference u) => u.documentID == "")

    //   Firestore.instance.collection('users').document(item).updateData({
    //     'groups': FieldValue.arrayUnion([
    //       {
    //         'groupId': groupId,
    //         'groupName': "$name - $currentUserId",
    //         'photoUrl':
    //             'https://www.pngitem.com/pimgs/m/144-1447051_transparent-group-icon-png-png-download-customer-icon.png',
    //         'adminId': currentUserId,
    //         'members': _selecteItems,
    //         'recentMessage': {
    //           'idFrom': currentUserId,
    //           'content': "$name create this group",
    //           'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    //           'type': 0,
    //         },
    //       }
    //     ])
    //   });

    // subscribe on this group topic to get notification//
    // firebaseMessaging.subscribeToTopic(groupId);
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select one',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      print(snapshot.data.documents[index]['nickname']);
                      if (snapshot.data.documents[index]['id'] ==
                          currentUserId) {
                        return SizedBox();
                      }
                      return buildItem(context, snapshot.data.documents[index]);
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
                              AlwaysStoppedAnimation<Color>(themeColor)),
                    ),
                    color: Colors.white.withOpacity(0.8),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return InkWell(
      onTap: () => finishChoosing(document),
      child: Container(
        child: Row(
          children: <Widget>[
            Material(
              child: document['photoUrl'] != null
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(15.0),
                      ),
                      imageUrl: document['photoUrl'],
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.account_circle,
                      size: 50.0,
                      color: greyColor,
                    ),
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              clipBehavior: Clip.hardEdge,
            ),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${document['nickname']}',
                        style: TextStyle(color: primaryColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(left: 20.0),
              ),
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      ),
    );
  }
}
