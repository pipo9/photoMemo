import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/models/constant.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:photomemo/models/photomemo.dart';
class FirebaseStorageController {
  FirebaseVisionImage visionImage;
  List<String>_category=[];
 Future<Map<String, String>> uploadPhotoFile({
    @required File photo,
    String filename,
    @required String uid,
    @required Function listener,
  }) async {
    filename ??= '${Constant.PHOTOIMAGE_FOLDER}/$uid/${DateTime.now()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      double progress = event.bytesTransferred / event.totalBytes;
      if (event.bytesTransferred == event.totalBytes) progress = null;
      listener(progress);
    });
    await task;
    String downloadURL =
        await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return <String, String>{
      Constant.ARG_DOWNLOADURL: downloadURL,
      Constant.ARG_FILENAME: filename,
    };
  }


  Future labelimage(_image)async{
    visionImage= FirebaseVisionImage.fromFile(_image);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    await labeler.processImage(visionImage).then((labels){
      for (ImageLabel label in labels) {
        _category.add(label.text);
      }
    }).catchError((error){
      print(error.message.toString());
    });
   return _category;
  }
}
