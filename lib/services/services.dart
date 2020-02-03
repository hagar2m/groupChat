import 'package:chatdemo/models/thread.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiServices {
  static Future<List> getThreads(String currentUserId) async {
    List<ThreadModel> myThreads = [];
    // QuerySnapshot snapshot =
    Firestore.instance.collection('threads').getDocuments().then((snapshot) {
      if (snapshot.documents != null) {
        List threads = snapshot.documents;
        threads.map((item) {
          List<dynamic> usersRef = item.data['users']; // get users of this thread
          List exists = usersRef.where((u) => u.documentID == currentUserId).toList();

          if (exists != null && exists.length > 0 && usersRef.length == 2) {
            // if currentUser is found in users array
            // if this thread is a chat
            usersRef.map((item) {
              item.get().then((user) {
                if (user.data['id'] != currentUserId) {
                  ThreadModel thread = ThreadModel();
                  thread.name = user.data['nickname'];
                  thread.photoUrl = user.data['photoUrl'];
                  print('thread.name ${thread.name}');
                  myThreads.add(thread);
                }
              });
            }).toList();
          }
        }).toList();
      }
    });
    print('${myThreads.length}');
    return myThreads;
  }
}