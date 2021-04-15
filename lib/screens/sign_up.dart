import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebase_auth_controller.dart';
import 'package:photomemo/models/constant.dart';
import 'package:photomemo/screens/sign_in.dart';
import 'package:photomemo/screens/user_home.dart';

import 'myview/mydialog.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  _Controller con;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign up'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15),
              Text(
                'Photo Memo',
                style: TextStyle(fontFamily: 'Pacifico', fontSize: 40),
              ),
              SizedBox(height: 15),
              Text(
                'Welcome',
                style: TextStyle(fontSize: 17),
              ),
              Text(
                'Create a new account',
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 30),
              Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                      child: TextFormField(
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        validator: con.validateEmail,
                        onSaved: con.saveEmail,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                      child: TextFormField(
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: true,
                        autocorrect: false,
                        onChanged: con.onchanged,
                        validator: con.validatePassword,
                        onSaved: con.savePassword,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                      child: TextFormField(
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Confirm password',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: true,
                        autocorrect: false,
                        validator: con.validateConfirmPassword,
                      ),
                    ),
                    SizedBox(height: 15),
                    RaisedButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      onPressed: con.signUp,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 20),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text('Already have an account ?'),
              SizedBox(height: 10),
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                onPressed: con.signIn,
                child: Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
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
  _SignUpScreenState state;
  _Controller(this.state);
  String email;
  String password;

  String validateEmail(String value) {
    if (value.contains('@') && value.contains('.'))
      return null;
    else
      return 'invalid email address';
  }

  void saveEmail(String value) {
    email = value;
  }

  String validatePassword(String value) {
    if (value.length < 6)
      return 'too short';
    else
      return null;
  }

  void onchanged(String value) {
    password = value;
  }

  void savePassword(String value) {
    password = value;
  }

  String validateConfirmPassword(String value) {
    if (value != password)
      return 'password and confirmation must be the same';
    else
      return null;
  }

  void signUp() async {
    if (!state.formkey.currentState.validate()) return;
    state.formkey.currentState.save();
    User user;
    MyDialog.circularProgressStart(state.context);
    try {
      user = await FirebaseAuthController.signUp(email, password);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Sign Up Error',
        content: e.toString(),
      );
      return;
    }
    MyDialog.circularProgressStop(state.context);
    Navigator.pushNamed(state.context, UserHomeScreen.routeName,
        arguments: {Constant.ARG_USER: user});
  }

  signIn() {
    Navigator.pushReplacementNamed(state.context, SignInScreen.routeName);
  }
}
