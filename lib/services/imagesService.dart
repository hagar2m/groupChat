import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/models.dart';

class ImageServices {
  String threadId;
  UserModel selectedUser;
  String currentUserId;
  String currentUserName;
  String currentUserPhoto;
  ImageServices({ 
    @required this.threadId, 
    @required this.selectedUser, 
    @required this.currentUserId,
    @required this.currentUserName,
    @required this.currentUserPhoto
  });

  Future<List> getImages() async {
    requestPermission();
    List<Asset> resultList;
    // String error;
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
      );
    } on Exception catch (e) {
      print('error: ${e.toString()}');
      // error = e.toString();
    } catch (e) {
      print('error  one: ${e.toString()}');
      throw(e.toString()); 
      // error = e.toString();
    }

    return resultList;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;

    // if (error == null) {
    //   // setState(() {
    //     // isLoading = true;
    //     uploadFile(resultList);
    //     //  error = 'No Error Dectected';
    //   // });
    // }
  }

  Future<void> requestPermission() async {
    final List<PermissionGroup> iosPermissions = [
      PermissionGroup.camera,
      PermissionGroup.mediaLibrary,
      PermissionGroup.photos
    ];
    final List<PermissionGroup> androidPermissions = [
      PermissionGroup.camera,
      PermissionGroup.storage
    ];
    if (Platform.isIOS) {
      await PermissionHandler().requestPermissions(iosPermissions);
    } else {
      await PermissionHandler().requestPermissions(androidPermissions);
    }
  }
  
  // Future<List> uploadFile(List resultList) async {
  //   List images = await uploadIamges(resultList);
  //   return images;
  // }

  Future<List> uploadIamges(List resultList) async {
    List _images = List();

    for (var img in resultList) {
      ByteData byteData = await img.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = reference.putData(imageData);
      String url = await (await uploadTask.onComplete).ref.getDownloadURL();
      print('DownLoad url $url');
      _images.add(url);
    }
      // setState(() {
      //   isLoading = false;
      // });
    return _images;
  }

  void onSendMessage(var content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker, 3 = record
    if (type != 1 && content.trim() == '') {
      Fluttertoast.showToast(msg: 'Nothing to send');
    } else {
      // textEditingController.clear();
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(threadId)
          .collection(threadId)
          .document(timeStamp);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'threadId': threadId,
            'idFrom': currentUserId,
            'idTo': selectedUser != null ? selectedUser.id : '',
            'timestamp': timeStamp,
            'content': type == 1 ? '' : content,
            'images': type == 1 ? content : [],
            'type': type,
            'nameFrom': currentUserName,
            'photoFrom': currentUserPhoto,
          },
        );
      });

      Firestore.instance
          .collection('threads')
          .document(threadId)
          .updateData({
        'lastMessage': type == 0
            ? content
            : type == 1 ? 'photo' : type == 2 ? 'sticker' : 'audio',
        'lastMessageTime': timeStamp
        //Firestore.instance.collection('messages').document(widget.threadId).collection(widget.threadId).document(timeStamp)
      });

      // listScrollController.animateTo(0.0,
      //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  
 
}