import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future getCurrentUser() async {
    return auth.currentUser;
  }

  Future signOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }


  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? _googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleSignInAuthentication =
        await _googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: _googleSignInAuthentication.idToken,
      accessToken: _googleSignInAuthentication.accessToken,
    );

    UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    User user = userCredential.user!;

    SharedPreferencesHelper().saveUserId(user.uid);
    SharedPreferencesHelper().saveUserEmail(user.email!);
    SharedPreferencesHelper().saveUserName(user.email!.replaceAll('@gmail.com', ''));
    SharedPreferencesHelper().saveDisplayName(user.displayName!);
    SharedPreferencesHelper().saveUserProfileUrl(user.photoURL!);

    Map<String, dynamic> userInfoMap = {
      'email': user.email,
      'username': user.email!.replaceAll('@gmail.com', ''),
      'name': user.displayName,
      'imageUrl': user.photoURL,
    };

    DatabaseMethods().addUserInfoToDatabase(user.uid, userInfoMap).then((_) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    });
  }
}
