import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger/helper/shared_prefs_helper.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() {
    return auth.currentUser;
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

    UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    
    User user =  userCredential.user!;

    SharedPreferencesHelper().saveUserId(user.uid);
    SharedPreferencesHelper().saveUserEmail(user.email!);
    SharedPreferencesHelper().saveDisplayName(user.displayName!);
    SharedPreferencesHelper().saveUserProfileUrl(user.photoURL!);

  }
}
