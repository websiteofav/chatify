import 'package:intl/intl.dart';

class ChatMessageFields {
  static const String message = "message";
  static const String time = "time";

  static final List<String> values = [message, time];
}

class ChatMessageModel {
  final String message;
  final String time;

  ChatMessageModel({required this.message, required this.time});

  Map<String, Object?> toJson() => {
        ChatMessageFields.message: message,
        ChatMessageFields.time: time,
      };

  static ChatMessageModel fromJson(Map<String, Object?> json) =>
      ChatMessageModel(
        message: json[ChatMessageFields.message] as String,
        time: json[ChatMessageFields.time] as String,
      );
}
