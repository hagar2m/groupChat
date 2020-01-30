import 'package:cloud_firestore/cloud_firestore.dart';

class ApiServices {
  static Future<List> getThreads(String currentUserId) async {
    List<dynamic> myThreads = [];
    QuerySnapshot snapshot =
        await Firestore.instance.collection('threads').getDocuments();
    if (snapshot.documents != null) {
      List threads = snapshot.documents;
      threads.map((item) {
        List<dynamic> usersRef = item.data['users'];
        List exists =
            usersRef.where((u) => u.documentID == currentUserId).toList();
        if (exists != null && exists.length > 0) {
          myThreads.add(item);
        }
      }).toList();
    }
    return myThreads;
  }
}


// DocumentReference lastMsgRef = threads[index].data['lastMessage'];
// usersRef.map((item) {
//   item.get().then((v) {
//     print('content ${v.data['id']}');

//   });
// }).toList();
