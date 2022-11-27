import 'package:chat_app/frontend/utils/constants.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserDetailsResults> checkUserAlreadyExists({userName}) async {
    try {
      final user = await FirebaseFirestore.instance
          .collection(Constants.userDetailCollectionName)
          .where('username', isEqualTo: userName)
          .get();

      if (user.docs.isNotEmpty) {
        return UserDetailsResults.userFound;
      } else {
        return UserDetailsResults.userNotFound;
      }
    } catch (e) {
      debugPrint(e.toString());
      return UserDetailsResults.genericeError;
    }
  }

  Future<UserDetailsAddedResults> registerUserDetails(
      {required username, required bio, required email}) async {
    try {
      final String? token = await FirebaseMessaging.instance.getToken();
      final String currentDate =
          DateFormat('dd-MM-yyyy').format(DateTime.now());
      final String currentTime = DateFormat('hh:mm:ss').format(DateTime.now());

      await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$email')
          .set({
        "bio": bio,
        "activities": [],
        "partners": [],
        'creation_date': currentDate,
        'creation_time': currentTime,
        'mobile_number': '',
        'profile_pic': '',
        'token': token,
        'total_partners': '',
        'username': username
      });

      return UserDetailsAddedResults.detailAdded;
    } catch (e) {
      debugPrint(e.toString());
      return UserDetailsAddedResults.detailsNotAdded;
    }
  }

  Future<UserDetailsRecordsResults> searchUserRecords() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return UserDetailsRecordsResults.userNotFound;
      } else {
        String? email = FirebaseAuth.instance.currentUser!.email;
        final DocumentSnapshot<Map<String, dynamic>> records =
            await FirebaseFirestore.instance
                .doc('${Constants.userDetailCollectionName}/$email')
                .get();
        return records.exists
            ? UserDetailsRecordsResults.detailFound
            : UserDetailsRecordsResults.detailsNotFound;
      }
    } catch (e) {
      debugPrint(e.toString());
      return UserDetailsRecordsResults.genericeError;
    }
  }
}
