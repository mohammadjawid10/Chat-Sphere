import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:messenger/views/home.dart';

import 'package:messenger/views/sign_in.dart';

void main() async {
  /* Initialize our application with firebase. */
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignInScreen(),
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
    ),
  );
}