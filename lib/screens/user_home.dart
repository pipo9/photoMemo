import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebase_auth_controller.dart';
import 'package:photomemo/controller/speech_controller.dart';
import 'package:photomemo/controller/firebase_firestore_controller.dart';
import 'package:photomemo/models/constant.dart';
import 'package:photomemo/models/photomemo.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'add_photo.dart';
import 'myview/memo_item.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  final AiController aiController = new AiController();
  TextEditingController textEditingController = new TextEditingController();
  int myMemos = 0;
  int sharedMemos = 1;
  List<Color> boxColors = [Colors.transparent, Colors.white];
  List<Color> textColors = [Colors.white, Colors.black];
  _Controller con;
  User user;
  String searched = '';
  bool listen = false;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            width: width * 0.7,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 2,
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searched = value;
                  });
                },
                cursorColor: Colors.white,
                controller: textEditingController,
                style: TextStyle(color: Colors.white),
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.only(top: 20, left: width * 0.05),
                  hintText: 'search',
                  hintStyle: new TextStyle(color: Colors.white),
                  border: new OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: new BorderSide(color: Colors.white)),
                  focusedBorder: new OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: new BorderSide(color: Colors.white)),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            listen == false
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        listen=true;
                      });
                      con.listen();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        listen=false;
                      });
                      con.stop();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Icon(
                        Icons.stop_circle_outlined,
                        color: Colors.redAccent,
                      ),
                    ),
                  )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user.displayName ?? 'N/A'),
                accountEmail: Text(user.email),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.add, color: Colors.white),
          onPressed: con.addButton,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        setState(() {
                          myMemos = 0;
                          sharedMemos = 1;
                        });
                      },
                      child: Text(
                        'My memos',
                        style: TextStyle(
                          color: textColors[myMemos],
                          fontSize: 15,
                        ),
                      ),
                      color: boxColors[myMemos],
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        setState(() {
                          myMemos = 1;
                          sharedMemos = 0;
                        });
                      },
                      child: Text(
                        'Shared with me',
                        style: TextStyle(
                          color: textColors[sharedMemos],
                          fontSize: 15,
                        ),
                      ),
                      color: boxColors[sharedMemos],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                height: 500,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestoreController.snapshot,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        List memos = snapshot.data.docs;
                        //TODO : where is the uid ?

                        if (myMemos == 0)
                          memos.removeWhere((memo) =>
                              memo.data()['createdBy'].compareTo(user.uid) !=
                              0);

                        if (myMemos == 1)
                          memos.removeWhere((memo) => !memo
                              .data()['sharedwith']
                              .contains(user.email.toString()));

                        memos.removeWhere((memo) {
                          String categories = con
                              .loadCategories(memo.data()['photoLabels'])
                              .toLowerCase();
                          return !categories.contains(searched.toLowerCase());
                        });
                        return ListView.builder(
                          itemCount: memos.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot memo = memos[index];
                            PhotoMemo photomemo =
                                PhotoMemo(memo.id, memo.data());
                            return Slidable(
                              child: MemoItem(
                                width: width,
                                memoItem: photomemo,
                              ),
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () =>
                                      FirebaseFirestoreController.delete(
                                          memo.id),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return Text('loading');
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  _Controller(this.state);

  List<PhotoMemo> memosList = [];
  int listLen;

  void addButton() async {
    await Navigator.pushNamed(state.context, AddPhotoMemoScreen.routeName,
        arguments: {Constant.ARG_USER: state.user});
  }

  String loadCategories(List categories) {
    String listToString = "";
    for (var i = 0; i < categories.length; i++) {
      listToString += categories[i].toString();
      if (i != categories.length - 1) {
        listToString += ", ";
      }
    }
    return listToString;
  }

  void signOut() async {
    try {
      await FirebaseAuthController.signOut();
    } catch (e) {
      //do nothing
    }
    Navigator.of(state.context).pop();
    Navigator.of(state.context).pop();
  }

  void listen() async {
      bool available = await state.aiController.initSpeechState();
      if (available) {
          state.aiController.speech.listen(
            listenFor: Duration(minutes:1),
            onResult: (val) =>
                state.render(() {
                  state.aiController.text = val.recognizedWords;
                  state.searched = val.recognizedWords;
                  state.textEditingController.text = val.recognizedWords;
                  print(val.recognizedWords);
                }),
          );

    }
  }
  void stop(){
    state.aiController.speech.stop();
  }
}
