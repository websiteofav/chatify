import 'package:chat_app/frontend/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor1,
      appBar: AppBar(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text(
          'About',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            child: const Text(
              'Welcome to Chatify',
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Chatify is a messaging app where people can connect with each other and send text, images, videos, location, documents and audio messages among other things.",
              style: TextStyle(color: AppColors.textColor5, fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: RichText(
                text: const TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: 'Created by \n',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.shadowColor1)),
                TextSpan(
                    text: 'Avinash',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.logout,
                        fontSize: 22)),
              ],
            )),
          ),
          Container(
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            child: const Text('7550169761',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.logout,
                    fontSize: 22)),
          ),
          Container(
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            child: const Text('avinashupadhyay56@gmail.com',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.logout,
                    fontSize: 22)),
          ),
        ],
      )),
    );
  }
}
