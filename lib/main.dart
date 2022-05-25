import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:messenger/views/home.dart';

import 'package:messenger/views/sign_in.dart';
import 'package:messenger/services/auth.dart';

void main() async {
  /* Initialize our application with firebase. */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const SignInScreen();
          }
        },
      ),
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        SignInScreen.routeName: (context) => const SignInScreen(),
      },
    ),
  );
}
