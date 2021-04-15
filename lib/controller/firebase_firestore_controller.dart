import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photomemo/models/photomemo.dart';

class FirebaseFirestoreController {
  static FirebaseFirestore firestor = FirebaseFirestore.instance;

  static CollectionReference myMemos = firestor.collection('mymemos');

  static Stream<QuerySnapshot> snapshot = myMemos.snapshots();

  static Future<void> addMemo(String uid, String title, String memo,
      List<dynamic> sharedwith, String imgname, String imgurl, List<dynamic> fileLabels) async {
    return await myMemos
        .add({
          'createdBy': uid,
          'title': title,
          'Memo': memo,
          'sharedwith': sharedwith,
          'imgurl': imgurl,
          'imgname': imgname,
           'photoLabels':fileLabels
        })
        .then((value) => print("photo Added"))
        .catchError((error) => print("Failed to add photo: $error"));
  }

  static Future<void> delete(docId) async {
    await FirebaseFirestore.instance.collection('mymemos').doc(docId).delete();
  }

  static Future<void> update(docId, PhotoMemo newmemo) async {
    await FirebaseFirestore.instance.collection('mymemos').doc(docId).update({
      'createdBy': newmemo.createdBy,
      'title': newmemo.title,
      'Memo': newmemo.memo,
      'sharedwith': newmemo.sharedWith,
      'imgurl': newmemo.photoURL,
      'imgname': newmemo.photoFilename,
      'photoLabels':newmemo.imageLabels
    });
  }
}
