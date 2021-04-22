import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photomemo/controller/firebase_firestore_controller.dart';
import 'package:photomemo/controller/firebase_storage_controller.dart';
import 'package:photomemo/models/constant.dart';
import 'package:photomemo/models/photomemo.dart';
import 'package:photomemo/screens/myview/mydialog.dart';

class MemoDetails extends StatefulWidget {
  static const routeName = '/memoDetail';

  @override
  _MemoDetailsState createState() => _MemoDetailsState();
}

class _MemoDetailsState extends State<MemoDetails> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  _Controller con;
  File updatedPhoto;
  String progressMessage;
  User user;
  bool checked = false;
  String categories;
  String commentText;
  TextEditingController textEditingController = new TextEditingController();
  TextEditingController textCommentController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  bool enabeled = false;
  bool edit = false;

  void render(fn) => setState(fn);
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    PhotoMemo memo = args['memoItem'];
    user ??= args[Constant.ARG_USER];
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('PhotoMemo details'),
          actions: memo.createdBy == con.currentUser()
              ? [
                  IconButton(
                    icon: enabeled == false
                        ? Icon(Icons.edit)
                        : Icon(Icons.check),
                    onPressed: () {
                      if (enabeled) {
                        con.updateMemo(memo);
                      }
                      setState(() {
                        enabeled = !enabeled;
                      });
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      MyDialog.alert(
                          context: context,
                          title: "Are you sure you want to delete this memo ?",
                          action: () {
                            con.delete(memo, context);
                          });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ]
              : [],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: (memo.photoURL == "" && updatedPhoto == null)
                          ? Icon(
                              Icons.photo,
                              size: 300,
                            )
                          : updatedPhoto == null
                              ? Image.network(
                                  memo.photoURL,
                                  fit: BoxFit.fill,
                                )
                              : Image.file(
                                  updatedPhoto,
                                  fit: BoxFit.fill,
                                ),
                    ),
                    if (enabeled)
                      Positioned(
                        right: 0.0,
                        bottom: 0.0,
                        child: Container(
                          color: Colors.blue[200],
                          child: PopupMenuButton<String>(
                            onSelected: con.updatePhoto,
                            itemBuilder: (context) => <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                value: Constant.SRC_CAMERA,
                                child: Row(
                                  children: [
                                    Icon(Icons.photo_camera),
                                    Text(Constant.SRC_CAMERA),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: Constant.SRC_GALLERY,
                                child: Row(
                                  children: [
                                    Icon(Icons.photo_album),
                                    Text(Constant.SRC_GALLERY),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
                (progressMessage == null)
                    ? SizedBox(
                        height: 1.0,
                      )
                    : Text(
                        progressMessage,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                SizedBox(height: 13),
                Container(
                  padding: EdgeInsets.all(20),
                  color: Color(0xffD6D9F0),
                  child: Column(
                    children: [
                      TextFormField(
                        enabled: enabeled,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        autocorrect: true,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        initialValue: memo.title,
                        validator: PhotoMemo.validateMemo,
                        onSaved: (String value) {
                          con.saveTitle(memo, value);
                        },
                      ),
                      SizedBox(height: 13),
                      TextFormField(
                        enabled: enabeled,
                        initialValue: memo.memo,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        autocorrect: true,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        validator: PhotoMemo.validateMemo,
                        onSaved: (String value) {
                          con.saveMemo(memo, value);
                        },
                      ),
                      SizedBox(height: 13),
                      TextFormField(
                        initialValue: con.loadSharedWith(memo.sharedWith),
                        decoration: InputDecoration(
                          enabled: enabeled,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          hintText: 'SharedWith (comma seperated email list)',
                          hintStyle: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        maxLines: 2,
                        validator: PhotoMemo.validateShareWith,
                        onSaved: (String value) {
                          con.saveSharedWith(memo, value);
                        },
                      ),
                      memo.createdBy == con.currentUser()
                          ? CheckboxListTile(
                              title: Text(
                                "Label image",
                                style: TextStyle(color: Colors.black),
                              ),
                              value: checked,
                              checkColor: Colors.black,
                              onChanged: (newValue) {
                                setState(() {
                                  if (enabeled == true) checked = newValue;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            )
                          : SizedBox(),
                      SizedBox(height: 13),
                      TextFormField(
                        enabled: checked,
                        controller: textEditingController,
                        decoration: InputDecoration(
                          labelText: 'photo labels',
                          labelStyle: TextStyle(
                            color: Colors.grey[800],
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          hintText: categories ??
                              con.loadCategories(memo.imageLabels),
                          hintStyle: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        maxLines: null,
                        onSaved: (String value) {
                          con.saveLabels(memo, value);
                        },
                      ),
                      SizedBox(height: 26),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Comment Section",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: textCommentController,
                              decoration: InputDecoration(
                                labelText: 'comment',
                                labelStyle: TextStyle(
                                  color: Colors.grey[800],
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: 'type something ...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              maxLines: null,
                              onChanged: (value) {
                                setState(() {
                                  commentText = value;
                                });
                              },
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                MyDialog.alert(
                                    context: context,
                                    title: "the comment will be anonymous\nOnly post owner can delete comments",
                                    action: () {
                                      setState(() {
                                        con.saveComment(memo, commentText);
                                      });
                                      Navigator.pop(context);
                                      textCommentController.clear();
                                    });


                              },
                              icon: Icon(
                                Icons.send,
                                color: Colors.black,
                              ))
                        ],
                      ),
                      SizedBox(height: 13),
                      Column(
                        children: [
                          for (var index=0;index<memo.comments.length;index++)
                            Container(
                                margin: EdgeInsets.only(bottom: 13),
                                width: width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text(
                                        memo.comments[index],
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15),
                                      ),
                                      memo.createdBy == con.currentUser()
                                          ? GestureDetector(
                                              onTap: () {
                                                MyDialog.alert(
                                                    context: context,
                                                    title: "want to delete this comment ?",
                                                    action: () {
                                                      setState(() {
                                                        con.deleteComment(memo,index);
                                                      });
                                                      Navigator.pop(context);
                                                    });
                                              },
                                              child: Text(
                                                "X",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15),
                                              ),
                                            )
                                          : SizedBox(),
                                    ]),
                                    Padding(
                                      padding: EdgeInsets.only(top: 13),
                                      child: Container(
                                        height: 0.3,
                                        width: width,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                )),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _MemoDetailsState state;
  _Controller(this.state);

  void updateMemo(PhotoMemo memo) async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();
    MyDialog.circularProgressStart(state.context);
    if (state.updatedPhoto != null) {
      FirebaseStorageController firebaseStorageController =
          new FirebaseStorageController();
      Map photoInfo = await firebaseStorageController.uploadPhotoFile(
        photo: state.updatedPhoto,
        uid: memo.createdBy,
        listener: (double progress) {
          state.render(() {
            if (progress == null)
              state.progressMessage = null;
            else {
              progress *= 100;
              state.progressMessage =
                  'Uploading:' + progress.toStringAsFixed(1) + '%';
            }
          });
        },
      );
      String photoUrl = photoInfo[Constant.ARG_DOWNLOADURL];
      String filename = photoInfo[Constant.ARG_FILENAME];

      memo.photoURL = photoUrl;
      memo.photoFilename = filename;
    }

    FirebaseFirestoreController.update(memo.docID, memo).then((value) {
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
      MyDialog.info(
          context: state.context,
          title: "Success",
          content: "The memo has beeen succesfully addes");
    });
  }

  void saveTitle(PhotoMemo memo, String value) {
    memo.title = value;
  }

  void saveMemo(PhotoMemo memo, String value) {
    memo.memo = value;
  }

  void saveSharedWith(PhotoMemo memo, String value) {
    if (value.trim().length != 0) {
      memo.sharedWith =
          value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    }
  }

  String loadSharedWith(List sharedWith) {
    String listToString = "";
    for (var i = 0; i < sharedWith.length; i++) {
      listToString += sharedWith[i].toString();
      if (i != sharedWith.length - 1) {
        listToString += ", ";
      }
    }
    return listToString;
  }

  void saveLabels(PhotoMemo memo, String value) {
    if (value.trim().length != 0) {
      memo.imageLabels =
          value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    }
  }

  void saveComment(PhotoMemo memo, String value) async {
    if (value.trim().length != 0) {
      memo.comments.add(value);
      await FirebaseFirestoreController.updateComments(memo.docID, memo);
    }
  }
  void deleteComment(PhotoMemo memo, i) async {
      memo.comments.removeAt(i);
      await FirebaseFirestoreController.updateComments(memo.docID, memo);
  }

  String loadCategories(List categories) {
    String listToString = "";
    for (var i = 0; i < categories.length; i++) {
      listToString += categories[i].toString();
      if (i != categories.length - 1) {
        listToString += ", ";
      }
    }
    state.render(() {
      state.textEditingController.text = listToString;
    });
    return listToString;
  }

  void delete(PhotoMemo memo, context) {
    try {
      FirebaseFirestoreController.delete(memo.docID).then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    } catch (e) {
      print('#################### $e');
    }
  }

  currentUser() {
    return FirebaseAuth.instance.currentUser.uid;
  }

  void updatePhoto(String src) async {
    try {
      PickedFile _imageFile;
      var _picker = ImagePicker();
      if (src == Constant.SRC_CAMERA) {
        _imageFile = await _picker.getImage(source: ImageSource.camera);
      } else {
        _imageFile = await _picker.getImage(source: ImageSource.gallery);
      }
      if (_imageFile == null) return;
      state.render(() => state.updatedPhoto = File(_imageFile.path));
      FirebaseStorageController firebaseStorageController =
          new FirebaseStorageController();
      List<String> cat =
          await firebaseStorageController.labelimage(state.updatedPhoto);
      state.render(() {
        state.categories = loadCategories(cat);
        state.textEditingController.text = state.categories;
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Failed to get picture',
        content: '$e',
      );
    }
  }
}
