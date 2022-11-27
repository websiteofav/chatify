import 'package:chat_app/frontend/utils/constants.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<EmailSignupResults> signup({required email, required password}) async {
    try {
      final authUser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (authUser.user!.email != null) {
        await authUser.user!.sendEmailVerification();

        return EmailSignupResults.signupCompleted;
      } else {
        return EmailSignupResults.problemInSignup;
      }
    } catch (e) {
      debugPrint(e.toString());
      return EmailSignupResults.emailAlreadyPresent;
    }
  }

  Future<EmailLoginResults> login({required email, required password}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final authUser = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (authUser.user!.emailVerified) {
        await prefs.setString('loginType', 'email');

        return EmailLoginResults.loginCompleted;
      } else {
        final bool logoutUser = await logout();
        if (logoutUser) {
          return EmailLoginResults.emailNotVerified;
        } else {
          return EmailLoginResults.genericeError;
        }
      }
    } catch (e) {
      debugPrint(e.toString());

      return EmailLoginResults.emailAndPasswordInvalid;
    }
  }

  Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      return true;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }

  Future<GoogleSigninResults> googleSignIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (await _googleSignIn.isSignedIn()) {
        googleSignOut();
      }
      final GoogleSignInAccount? authUser = await _googleSignIn.signIn();

      if (authUser == null) {
        debugPrint("Google SignIn not completed");
        return GoogleSigninResults.loginFailure;
      } else {
        final GoogleSignInAuthentication signedInAuthUser =
            await authUser.authentication;

        OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
          accessToken: signedInAuthUser.accessToken,
          idToken: signedInAuthUser.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(oAuthCredential);

        if (userCredential.user!.email != null) {
          await prefs.setString('loginType', 'google');

          return GoogleSigninResults.loginCompleted;
        } else {
          return GoogleSigninResults.loginFailure;
        }
      }
    } catch (e) {
      debugPrint(e.toString());

      return GoogleSigninResults.loginFailure;
    }
  }

  Future<bool> googleSignOut() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }
}
