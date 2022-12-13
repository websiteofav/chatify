import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
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
        UserDetailsFields.bio: bio,
        UserDetailsFields.activities: [],
        UserDetailsFields.partners: [],
        UserDetailsFields.accountCreationDate: currentDate,
        UserDetailsFields.accountCreationTime: currentTime,
        UserDetailsFields.mobileNumber: '',
        UserDetailsFields.profilePic: '',
        UserDetailsFields.token: token,
        UserDetailsFields.totalPartners: '',
        UserDetailsFields.username: username,
        UserDetailsFields.partnerRequests: [],
        UserDetailsFields.email: email
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

  Future<Map<String, dynamic>> getFirebaseToken(email) async {
    try {
      final user = await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$email')
          .get();

      final Map<String, dynamic> data = Map<String, dynamic>();

      data["token"] = user.data()!["token"];
      data["creation_date"] = user.data()!["creation_date"];

      data["creation_time"] = user.data()!["creation_time"];

      return data;
    } catch (e) {
      e.toString();
      rethrow;
    }
  }

  Future<List<UserDetailsModel>> getAllUsers() async {
    try {
      final users = await FirebaseFirestore.instance
          .collection(Constants.userDetailCollectionName)
          .get();

      List<UserDetailsModel> model = [];

      debugPrint(users.docs.toString());

      users.docs.map((e) {
        if (e.id != FirebaseAuth.instance.currentUser!.email.toString()) {
          model.add(UserDetailsModel.fromJson(e.data()));
        }
      }).toList();

      return model;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> _getCurrentUserData({required email}) async {
    try {
      final currentUserData = await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$email')
          .get();

      return currentUserData.data();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List> currentUserPartners({
    required email,
  }) async {
    try {
      final currentUserData = await _getCurrentUserData(email: email);
      final List paretnerRequests = currentUserData["partner_requests"];

      return paretnerRequests;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List> changePartnerStatus({
    required partnerEmail,
    required userEmail,
    required partnerUpdateStatus,
    required List userPartnerUpdateList,
  }) async {
    try {
      final docs = await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$partnerEmail')
          .get();

      final docSnap = docs.data();
      final partnerRequests = docSnap!["partner_requests"];
      int index = -1;

      partnerRequests.map(
        ((e) {
          if (e.keys.first.toString() == userEmail) {
            index = partnerRequests.indexOf(e);
          }
        }),
      ).toList();

      // docSnap["partner_requests"] = paretnerRequests;

      if (index > -1) {
        partnerRequests.removeAt(index);
      }
      partnerRequests.add({userEmail: partnerUpdateStatus.toString()});

      docSnap["partner_requests"] = partnerRequests;
      await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$partnerEmail')
          .update(docSnap);

      final userDocSnap = await _getCurrentUserData(email: userEmail);

      userDocSnap["partner_requests"] = userPartnerUpdateList;

      await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$userEmail')
          .update(userDocSnap);

      return userDocSnap["partner_requests"];
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
