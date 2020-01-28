import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/colors.dart';

class GroupCreateScreen extends StatefulWidget {
  static String routeName = '/groupchat';
  final isGroup;
  GroupCreateScreen({ this.isGroup = false });

  @override
  State createState() => GroupCreateScreenState();
}

class GroupCreateScreenState extends State<GroupCreateScreen> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  bool isLoading = false;
  bool showSelect = false;
  String currentUserId = '';
  List _selecteItems = List();

  @override
  void initState() {
    super.initState();
    readLocal();
  }
  readLocal()async{
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('id');
      _selecteItems.add(currentUserId);
    });
  }
  void finishChoosing() async {
    // type: 0 = text, 1 = image, 2 = sticker
    var groupId =
        currentUserId + DateTime.now().millisecondsSinceEpoch.toString();

    var prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('nickname') ?? '';
    for (var item in _selecteItems) {
      Firestore.instance.collection('users').document(item).updateData({
        'groups': FieldValue.arrayUnion([
          {
            'groupId': groupId,
            'groupName': "$name - $currentUserId",
            'photoUrl':
                'https://www.pngitem.com/pimgs/m/144-1447051_transparent-group-icon-png-png-download-customer-icon.png',
            'adminId': currentUserId,
            'members': _selecteItems,
            'recentMessage': {
              'idFrom': currentUserId,
              'content': "$name create this group",
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              'type': 0,
            },
          }
        ])
      });
    }
    // subscribe on this group topic to get notification//
    firebaseMessaging.subscribeToTopic(groupId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isGroup ? 'Create group' : 'Select one',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child: Text('Done'),
            onPressed: finishChoosing,
          )
        ],
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
                    itemBuilder: (context, index) {
                      print(snapshot.data.documents[index]['nickname']);
                      if (snapshot.data.documents[index]['id'] == currentUserId) {
                        return SizedBox();
                      }
                      return CheckboxListTile(
                        value: _selecteItems
                            .contains(snapshot.data.documents[index]['id']),
                        title:
                            buildItem(context, snapshot.data.documents[index]),
                        onChanged: (value) {
                          print('value: $value');
                          setState(() {
                            if (value == true) {
                              if (widget.isGroup == true ||( _selecteItems.length < 2)) {
                                _selecteItems
                                .add(snapshot.data.documents[index]['id']);
                              }
                            } else {
                              _selecteItems
                                  .remove(snapshot.data.documents[index]['id']);
                            }
                          });
                        },
                      );
                    },
                    itemCount: snapshot.data.documents.length,
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
    return Container(
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
    );
  }
}
