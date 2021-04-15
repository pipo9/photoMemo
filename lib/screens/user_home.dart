import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebase_auth_controller.dart';
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
  _Controller con;
  User user;
  String searched = '';
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
                onChanged: (value){

                  setState(() {
                    searched=value;
                  });

                },
                cursorColor: Colors.white,
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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {},
                      child: Text(
                        'My memos',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {},
                      child: Text(
                        'Shared with me',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      color: Colors.white,
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
                        memos.removeWhere((memo) =>
                            memo.data()['createdBy'].compareTo(user.uid) != 0);
                        memos.removeWhere((memo) {
                          String categories =
                              con.loadCategories(memo.data()['photoLabels']).toLowerCase();
                          return !categories.contains(searched);
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
              ),
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
}
