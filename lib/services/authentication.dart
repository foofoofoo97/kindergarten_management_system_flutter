import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<bool> signIn(String email, String password);

  Future<bool> signInWithGoogle();

  Future<bool> resetPassword(String email);

  Future<bool> signUp(String email, String password);

  Future<User> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //NEED REDO
  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
      return true;
    }
    catch(e){
      return false;
    }
  }
  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    }catch(e){
      return false;
    }

  }

  Future<bool> signUp(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    }catch(e){
      return false;
    }
  }

  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    User user =  _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    User user =  _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    }
    catch(e){
      return false;
    }
  }
}
