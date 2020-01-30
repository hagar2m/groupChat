import 'package:chatdemo/models/thread.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiServices {
  static Future<List> getThreads(String currentUserId) async {
    List<ThreadModel> myThreads = [];
    QuerySnapshot snapshot =
        await Firestore.instance.collection('threads').getDocuments();
    if (snapshot.documents != null) {
      List threads = snapshot.documents;
      threads.map((item) {
        List<dynamic> usersRef = item.data['users']; // get users of this thread
        List exists =
            usersRef.where((u) => u.documentID == currentUserId).toList();
        if (exists != null && exists.length > 0) {
          // if currentUser is found in users array
          ThreadModel thread = ThreadModel.fromJson(item.data);
          if (usersRef.length == 2) {
            // if this thread is a chat
            usersRef.map((item) {
              item.get().then((user) {
                if (user.data['id'] != currentUserId) {
                  thread.name = user.data['nickname'];
                  thread.photoUrl = user.data['photoUrl'];
                }
              });
            }).toList();
          }
          myThreads.add(thread);
        }
      }).toList();
    }
    return myThreads;
  }
}

/*
String name = '';
    String photoUrl = ''; 
    List<dynamic> usersRef = document['users'];
    if (usersRef.length == 2){
    usersRef.map((item) {
      item.get().then((v) {
        print('object before');
        if (v.data['id'] != currentUserId) {
          
        print('object after ${v.data}');
          name = v.data['nickname'];
          photoUrl = v.data['photoUrl'];
        }
      });
    }).toList();
    }else{
      name = document['nickname'];
      photoUrl = document['photoUrl'];
    }
 */
