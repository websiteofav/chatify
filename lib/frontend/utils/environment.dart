import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get firebaseNotificationKey {
    return dotenv.get('NOTIFICATION_KEY', fallback: '');
  }

  static String get testUserEmail {
    return dotenv.get('TEST_USER_EMAIL', fallback: '');
  }

  static String get testUserPassword {
    return dotenv.get('TEST_USER_PASSWORD', fallback: '');
  }
}
