class ChatMessageFields {
  static const String message = "message";
  static const String time = "time";

  static const String thumbnailPath = "thumbnail_path";

  static const String fileName = "file_name";
  static const String typeOfMessage = "type_of_message";
  static const String recievedMessage = "recieved_message";

  static const String messageHolder = "message_holder";
  static const String date = "date";

  static final List<String> values = [
    message,
    time,
    thumbnailPath,
    fileName,
    typeOfMessage,
    recievedMessage,
    date,
    messageHolder
  ];
}

class ChatMessageModel {
  final String message;
  final String time;
  String? thumbnailPath;
  String? fileName;
  final String typeOfMessage;
  dynamic recievedMessage;
  final String? date;
  String? messageHolder;

  ChatMessageModel(
      {required this.message,
      required this.time,
      this.thumbnailPath,
      this.fileName,
      required this.typeOfMessage,
      required this.recievedMessage,
      this.date,
      this.messageHolder});

  Map<String, Object?> toJson() => {
        ChatMessageFields.message: message,
        ChatMessageFields.time: time,
        ChatMessageFields.thumbnailPath: thumbnailPath,
        ChatMessageFields.fileName: fileName,
        ChatMessageFields.typeOfMessage: typeOfMessage,
        ChatMessageFields.recievedMessage: recievedMessage,
        ChatMessageFields.date: date,
        ChatMessageFields.messageHolder: messageHolder
      };

  static ChatMessageModel fromJson(Map<String, Object?> json) =>
      ChatMessageModel(
        message: json[ChatMessageFields.message] as String,
        time: json[ChatMessageFields.time] as String,
        thumbnailPath: json[ChatMessageFields.thumbnailPath] as dynamic,
        fileName: json[ChatMessageFields.fileName] as dynamic,
        typeOfMessage: json[ChatMessageFields.typeOfMessage] as String,
        recievedMessage: json[ChatMessageFields.recievedMessage] as dynamic,
        date: json[ChatMessageFields.date] as String,
        messageHolder: json[ChatMessageFields.messageHolder] as dynamic,
      );
}
