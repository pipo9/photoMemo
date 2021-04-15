import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photomemo/controller/firebase_firestore_controller.dart';
import 'package:photomemo/controller/firebase_storage_controller.dart';
import 'package:photomemo/models/constant.dart';
import 'package:photomemo/models/photomemo.dart';

import 'myview/mydialog.dart';

class AddPhotoMemoScreen extends StatefulWidget {
  static const routeName = '/addPhotoMemoScreen';
  @override
  State<StatefulWidget> createState() {
    return _AddPhotoMemoState();
  }
}

class _AddPhotoMemoState extends State<AddPhotoMemoScreen> {
  _Controller con;
  User user;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File photo;
  String progressMessage;
  bool checked=false;
  TextEditingController textEditingController=new TextEditingController();
  List<String> categories=[];
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);


  @override
  Widget build(BuildContext context) {

    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    return Scaffold(
      appBar: AppBar(
        title: Text('Add PhotoMemo'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: con.save,
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: photo == null
                        ? Icon(
                            Icons.photo,
                            size: 300,
                          )
                        : Image.file(
                            photo,
                            fit: BoxFit.fill,
                          ),
                  ),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: Container(
                      color: Colors.blue[200],
                      child: PopupMenuButton<String>(
                        onSelected: con.getPhoto,
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
              progressMessage == null
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
                      decoration: InputDecoration(
                        labelText: "Title",
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
                      ),
                      autocorrect: true,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      validator: PhotoMemo.validateMemo,
                      onSaved: con.saveTitle,
                    ),
                    SizedBox(height: 13),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Memo",
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
                      ),
                      autocorrect: true,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      validator: PhotoMemo.validateMemo,
                      onSaved: con.saveMemo,
                    ),
                    SizedBox(height: 13),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "SharedWith",
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
                      onSaved: con.saveSharedWith,
                    ),
                    SizedBox(height: 13),
                    CheckboxListTile(
                      title: Text("Label image",style: TextStyle(color: Colors.black),),
                      value: checked,
                      checkColor: Colors.black,
                      onChanged: (newValue) {
                        setState(() {
                          checked = newValue;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    SizedBox(height: 13),
                    TextFormField(
                      enabled: checked,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        labelText: "photo label",
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
                        hintText: 'photo labels',
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      maxLines: null,
                      onSaved: con.saveLabels,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _AddPhotoMemoState state;
  _Controller(this.state);
  PhotoMemo tempMemo = PhotoMemo("", {});

  void save() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();
    MyDialog.circularProgressStart(state.context);
    if (state.photo != null) {
      try {
        FirebaseStorageController  firebaseStorageController=new FirebaseStorageController();
        Map photoInfo = await firebaseStorageController.uploadPhotoFile(
          photo: state.photo,
          uid: state.user.uid,
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
        String photourl = photoInfo[Constant.ARG_DOWNLOADURL];
        String filename = photoInfo[Constant.ARG_FILENAME];
        await FirebaseFirestoreController.addMemo(
                state.user.uid,
                tempMemo.title,
                tempMemo.memo,
                tempMemo.sharedWith,
                filename,
                photourl,
                tempMemo.imageLabels)
            .then((value) {
          MyDialog.circularProgressStop(state.context);
          Navigator.pop(state.context);
          MyDialog.info(
              context: state.context,
              title: "Success",
              content: "The memo has beeen succesfully addes");
        });
      } catch (e) {
        print('==========$e');
      }
    } else {
      await FirebaseFirestoreController.addMemo(state.user.uid, tempMemo.title,
          tempMemo.memo, tempMemo.sharedWith, "", "",[]);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
      MyDialog.info(
          context: state.context,
          title: "Success",
          content: "The memo has beeen succesfully addes");
    }
  }

  void getPhoto(String src) async {
    try {
      PickedFile _imageFile;
      var _picker = ImagePicker();
      if (src == Constant.SRC_CAMERA) {
        _imageFile = await _picker.getImage(source: ImageSource.camera);
      } else {
        _imageFile = await _picker.getImage(source: ImageSource.gallery);
      }
      if (_imageFile == null) return;
      state.render(() => state.photo = File(_imageFile.path));
      FirebaseStorageController  firebaseStorageController=new FirebaseStorageController();
      List<String> cat=await firebaseStorageController.labelimage(state.photo);
      String catString=loadCategories(cat);
      state.render((){
        state.categories=cat;
        state.textEditingController.text=catString;
       });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Failed to get picture',
        content: '$e',
      );
    }
  }

  void saveTitle(String value) {
    tempMemo.title = value;
  }

  void saveMemo(String value) {
    tempMemo.memo = value;
  }

  void saveSharedWith(String value) {
    if (value.trim().length != 0) {
      tempMemo.sharedWith =
          value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    }
  }
  void saveLabels(String value) {
    if (value.trim().length != 0) {
      tempMemo.imageLabels =
          value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
      state.categories=tempMemo.imageLabels ;
    }
    print(tempMemo.imageLabels);
  }
 String loadCategories(List categories){
    String listToString = "";
    for (var i = 0; i < categories.length; i++) {
      listToString += categories[i].toString();
      if (i != categories.length - 1) {
        listToString += ", ";
      }
    }
    return listToString;
  }



}
