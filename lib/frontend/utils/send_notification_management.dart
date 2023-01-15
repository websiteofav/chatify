import 'dart:convert';

import 'package:chat_app/frontend/utils/apis.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:chat_app/frontend/utils/environment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class SendNotifications {
  Future<void> messageNotifcationsClassifier(
      {required ChatMessageTypes chatMessageTypes,
      required String message,
      required String token,
      required String currentUsername}) async {
    switch (chatMessageTypes) {
      case ChatMessageTypes.none:
        break;
      case ChatMessageTypes.text:
        await sendNotifications(
            token: token,
            title: '$currentUsername sent you a text message',
            body: message);
        break;
      case ChatMessageTypes.location:
        await sendNotifications(
            token: token,
            title: '$currentUsername sent you a location',
            body: message);
        break;
      case ChatMessageTypes.audio:
        await sendNotifications(
            token: token,
            title: '$currentUsername sent you a audio',
            body: message);
        break;
      case ChatMessageTypes.document:
        await sendNotifications(
            token: token,
            title: '$currentUsername sent you a document',
            body: message);
        break;
      case ChatMessageTypes.image:
        await sendNotifications(
            token: token,
            title: '$currentUsername sent you a image',
            body: message);
        break;
      case ChatMessageTypes.video:
        await sendNotifications(
            token: token,
            title: '$currentUsername sent you a video',
            body: message);
        break;
    }
  }

  Future<int> sendNotifications(
      {required String token,
      required String title,
      required String body}) async {
    try {
      String serverKey = Environment.firebaseNotificationKey;

      final http.Response response =
          await http.post(Uri.parse(API.sendNotifications),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "key=$serverKey",
              },
              body: jsonEncode({
                "notification": {"body": body, "title": title},
                "priority": "high",
                "data": {
                  "click": "FLUTTER_NOTIFICATION_CLICK",
                  "id": "1",
                  "status": "done",
                  "collapse_key": "type_a",
                },
                "to": token,
              }));

      debugPrint('Response: ${response.statusCode}; ${response.body} ');
      return response.statusCode;
    } catch (e) {
      debugPrint(e.toString());
      return 500;
    }
  }
}

// fmRzWoOQSOyRWidKDpYIgW:APA91bEJjSChM-VM-4IwvSB4reqSRmiSN25zT1X_3PTZe8DUozq2-W8u6dofxnJcQ5YPfCrfIRuXBEAz4ETSWANuDyIWPt_Hw0KprKrFJ14y8dFUekk7rvm_MrHKOYkLXwvGq_hN2Sm5
