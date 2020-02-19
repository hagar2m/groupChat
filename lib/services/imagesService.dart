import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/userModel.dart';

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

  Future<List> getImages({bool cameraEnable}) async {
    requestPermission();
    List<Asset> resultList;
    // String error;
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: cameraEnable ?? false
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

 

  
 
}