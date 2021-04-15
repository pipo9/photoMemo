import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/screens/add_photo.dart';
import 'package:photomemo/screens/memo_details.dart';
import 'package:photomemo/screens/sign_in.dart';
import 'package:photomemo/screens/sign_up.dart';
import 'package:photomemo/screens/user_home.dart';

import 'models/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PhotoMemoApp());
}

class PhotoMemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.DEV,
      theme: ThemeData.dark().copyWith(
          appBarTheme: AppBarTheme(
        color: Colors.blueAccent,
      )),
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        UserHomeScreen.routeName: (context) => UserHomeScreen(),
        AddPhotoMemoScreen.routeName: (context) => AddPhotoMemoScreen(),
        MemoDetails.routeName: (context) => MemoDetails(),
      },
    );
  }
}
