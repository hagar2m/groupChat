import 'package:chatdemo/screens/groupChat.dart';
import 'package:chatdemo/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../utils/colors.dart';
import '../models/userModel.dart';
import '../models/auth.dart';
import '../widgets/widgets.dart';

class GroupCreateScreen extends StatefulWidget {
  static String routeName = '/GroupCreateScreen';
  @override
  State createState() => GroupCreateScreenState();
}

class GroupCreateScreenState extends State<GroupCreateScreen> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final TextEditingController textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String currentUserId = '';
  List<UserModel> _selectedUsers = List();
  UserModel curentUserModel;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  readLocal() async {
    currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
  }

  void createGroup() async {
    _selectedUsers.add(curentUserModel);

    var threadId =
        currentUserId + DateTime.now().millisecondsSinceEpoch.toString();
    
    firebaseMessaging.subscribeToTopic(threadId);

    Firestore.instance.collection('threads').document(threadId).setData({
      'name': textEditingController.text,
      'photoUrl': groupPhoto,
      'id': threadId,
      'users': _selectedUsers
          .map((item) =>
              Firestore.instance.collection('users').document(item.id))
          .toList(),
      'lastMessage': ''
    });

    _clearState();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => GroupChat(
          threadId: threadId, 
          threadName: textEditingController.text,
        )));
  }

  void _clearState() {
    _selectedUsers.clear();
    textEditingController.clear();
  }

  onAlertWithCustomContentPressed(context) {
    Alert(
        context: context,
        closeFunction: () {},
        title: "Group Name",
        content: Form(
          key: _formKey,
          autovalidate: true,
          child: TextFormField(
            controller: textEditingController,
            decoration: InputDecoration(
              icon: Icon(Icons.group_work),
              labelText: 'group name',
            ),
            validator: (value) {
              if (textEditingController.text.trim() == '') {
                return 'Enter Group name';
              }
              return null;
            },
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context);
                createGroup();
              }
            },
            child: Text(
              "Create",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Group',
          style: TextStyle(color: thirdColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LoadingStack(
        isLoading: isLoading,
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
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  UserModel user = UserModel.fromJson(
                      snapshot.data.documents[index].data);
                  if (user.id == currentUserId) {
                    curentUserModel = user;
                    return SizedBox();
                  }

                  UserModel filteritem = _selectedUsers.firstWhere(
                      (item) => item.id == user.id,
                      orElse: () => null);

                  return CheckboxListTile(
                    value: filteritem != null,
                    title: UserItem(user: user, onPressed: null),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedUsers.add(user);
                        } else {
                          _selectedUsers
                              .removeWhere((item) => item.id == user.id);
                        }
                      });
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () => onAlertWithCustomContentPressed(context),
        backgroundColor: accentColor,
      ),
    );
  }
}
