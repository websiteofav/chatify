import 'package:chat_app/frontend/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Support extends StatefulWidget {
  const Support({Key? key}) : super(key: key);

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor1,
      appBar: AppBar(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text(
          'Support',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _supportItem(Icons.report_problem_rounded, 'Report a problem',
                'Crash and bug reports'),
            _supportItem(Icons.update_rounded, 'Request a feature',
                'Give your suggestions for new Ideas'),
            _supportItem(Icons.feedback_rounded, 'Feedback',
                'Rate us and send us your feedback'),
          ],
        ),
      ),
    );
  }

  Widget _supportItem(IconData icon, title, subtitle) {
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
