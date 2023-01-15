import 'dart:io';

import 'package:chat_app/frontend/chat/models/chat_model.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/home/repository/repository.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/utils/constants.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:chat_app/frontend/utils/send_notification_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final _localDB = HomeRepository();
  final SendNotifications _sendNotifications = SendNotifications();
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
        UserDetailsFields.partners: {},
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

  Future<dynamic> getCurrentUserData(
      {required email, bool parse = false}) async {
    try {
      final currentUserData = await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$email')
          .get();

      if (parse) {
        final UserDetailsModel firebaseModel = UserDetailsModel.fromJson(
            currentUserData.data() as Map<String, dynamic>);

        return firebaseModel;
      } else {
        return currentUserData.data();
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List> currentUserPartners({
    required email,
  }) async {
    try {
      final currentUserData = await getCurrentUserData(email: email);
      final List paretnerRequests =
          currentUserData[UserDetailsFields.partnerRequests];

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

      final userDocSnap = await getCurrentUserData(email: userEmail);

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

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      fetchRealTimeDataFromFirestore() async {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> snapshot = FirebaseFirestore
          .instance
          .collection(Constants.userDetailCollectionName)
          .snapshots();

      debugPrint(snapshot.toString());

      return snapshot;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>>
      fetchRealTimeMessageFromFirestore() async {
    try {
      Stream<
          DocumentSnapshot<
              Map<String, dynamic>>> snapshot = FirebaseFirestore.instance
          .doc(
              '${Constants.userDetailCollectionName}/${FirebaseAuth.instance.currentUser!.email}')
          .snapshots();

      debugPrint(snapshot.toString());

      return snapshot;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<bool> sendMessageToPartner(
      partnerUsername, ChatMessageModel model) async {
    try {
      final String userEmail =
          FirebaseAuth.instance.currentUser!.email.toString();

      final String partnerEmail = await _localDB.getImportantData(
          partnerUsername, UserPrimaryFields.email);

      final String partnerToken = await _localDB.getImportantData(
          partnerUsername, UserPrimaryFields.token);

      final UserPrimaryModel userPrimaryModel =
          await _localDB.getUserPrimarytData();

      model.messageHolder = userPrimaryModel.userName;

      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$partnerEmail')
          .get();

      final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      List? oldMessages = data[UserDetailsFields.partners][userEmail];
      oldMessages ??= [];

      oldMessages.add(model.toJson());

      data[UserDetailsFields.partners][userEmail] = oldMessages;

      await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$partnerEmail')
          .update(
              {UserDetailsFields.partners: data[UserDetailsFields.partners]});
      ChatMessageTypes messageType;
      if (model.typeOfMessage == ChatMessageTypes.text.toString()) {
        messageType = ChatMessageTypes.text;
      } else if (model.typeOfMessage == ChatMessageTypes.video.toString()) {
        messageType = ChatMessageTypes.video;
      } else if (model.typeOfMessage == ChatMessageTypes.audio.toString()) {
        messageType = ChatMessageTypes.audio;
      } else if (model.typeOfMessage == ChatMessageTypes.document.toString()) {
        messageType = ChatMessageTypes.document;
      } else if (model.typeOfMessage == ChatMessageTypes.image.toString()) {
        messageType = ChatMessageTypes.image;
      } else if (model.typeOfMessage == ChatMessageTypes.location.toString()) {
        messageType = ChatMessageTypes.location;
      } else {
        messageType = ChatMessageTypes.none;
      }

      await _sendNotifications.messageNotifcationsClassifier(
          chatMessageTypes: messageType,
          message: model.message,
          token: partnerToken,
          currentUsername: userPrimaryModel.userName.toString());

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> removeOldMessages(String partnerEmail) async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;

      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$userEmail')
          .get();

      final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      data[UserDetailsFields.partners][partnerEmail] = [];

      await FirebaseFirestore.instance
          .doc('${Constants.userDetailCollectionName}/$userEmail')
          .update(
              {UserDetailsFields.partners: data[UserDetailsFields.partners]});
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<String?> uploadMediaToFirebaseStorage(File filePath, reference) async {
    try {
      String? url;

      final String fileName =
          '${FirebaseAuth.instance.currentUser!.uid}${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}';

      final Reference fbStoragereference =
          FirebaseStorage.instance.ref(reference).child(fileName);

      final UploadTask uploadTask = fbStoragereference.putFile(filePath);

      await uploadTask.whenComplete(
          () async => url = await fbStoragereference.getDownloadURL());

      return url!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<bool> updateProfileImageUrl(String profilePicUrl) async {
    try {
      final String? token = await FirebaseMessaging.instance.getToken();
      final String currentDate =
          DateFormat('dd-MM-yyyy').format(DateTime.now());
      final String currentTime = DateFormat('hh:mm:ss').format(DateTime.now());

      await FirebaseFirestore.instance
          .doc(
              '${Constants.userDetailCollectionName}/${FirebaseAuth.instance.currentUser!.email.toString()}')
          .update({
        UserDetailsFields.profilePic: profilePicUrl,
      });

      return true;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
