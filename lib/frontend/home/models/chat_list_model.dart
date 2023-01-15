class ChatListFields {
  static const String username = "username";
  static const String latestMessage = "latest_message";

  static const String numberOfmessage = "number_of_message";

  static const String latestMessageDate = "latest_message_date";
  static const String typeOfMessage = "type_of_message";
  static const String read = "read";
  static const String senderUsername = "sender_username";
  static const String partnerProfilePicURL = "partner_profile_pic_url";
  static const String partnerProfilePicPath = "partner_profile_pic_path";

  static final List<String> values = [
    username,
    latestMessage,
    numberOfmessage,
    latestMessageDate,
    typeOfMessage,
    read,
  ];
}

class ChatListModel {
  final String username;
  final String latestMessage;

  final String numberOfmessage;

  final String latestMessageDate;
  final String typeOfMessage;
  bool read;
  final String senderUsername;
  final String partnerProfilePicURL;
  final String partnerProfilePicPath;

  ChatListModel({
    required this.latestMessage,
    required this.latestMessageDate,
    required this.username,
    required this.numberOfmessage,
    required this.typeOfMessage,
    required this.read,
    required this.senderUsername,
    required this.partnerProfilePicURL,
    required this.partnerProfilePicPath,
  });

  Map<String, Object?> toJson() => {
        ChatListFields.username: username,
        ChatListFields.latestMessage: latestMessage,
        ChatListFields.latestMessageDate: latestMessageDate,
        ChatListFields.numberOfmessage: numberOfmessage,
        ChatListFields.typeOfMessage: typeOfMessage,
        ChatListFields.read: read,
        ChatListFields.senderUsername: senderUsername
      };

  static ChatListModel fromJson(Map<String, Object?> json) => ChatListModel(
        username: json[ChatListFields.username] as String,
        latestMessage: json[ChatListFields.latestMessage] as String,
        numberOfmessage: json[ChatListFields.numberOfmessage] as String,
        latestMessageDate: json[ChatListFields.latestMessageDate] as String,
        typeOfMessage: json[ChatListFields.typeOfMessage] as String,
        read: json[ChatListFields.read] as bool,
        senderUsername: json[ChatListFields.senderUsername] as String,
        partnerProfilePicPath:
            json[ChatListFields.partnerProfilePicPath] as String,
        partnerProfilePicURL:
            json[ChatListFields.partnerProfilePicURL] as String,
      );
}
