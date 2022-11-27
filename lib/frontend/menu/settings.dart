import 'package:chat_app/frontend/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor1,
      appBar: AppBar(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text(
          'Settings',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  _settingsItem(Icons.notification_add, 'Notifications',
                      'Customize your notification settings'),
                  _settingsItem(Icons.wallpaper, 'Chat Wallpaper',
                      'Change your walpaper'),
                  _settingsItem(Icons.call_made_rounded, 'Call Settings',
                      'Add mobile numbers for calling functionalities'),
                  _settingsItem(Icons.chat_bubble_outline_rounded,
                      'Chat History', 'See your chat history'),
                  _settingsItem(
                      Icons.storage_rounded, 'Storage', 'Storage settings'),
                ],
              ))),
    );
  }

  Widget _settingsItem(IconData icon, title, subtitle) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 100,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor1,
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.backgroundColor3,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: AppColors.logout, fontSize: 25)),
                Expanded(
                  child: Text(
                    subtitle,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                        color: AppColors.backgroundColor2, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
