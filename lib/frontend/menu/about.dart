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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Now is the winter of our discontent Made glorious summer by this sun of York; And all the clouds that lour'd upon our house In the deep bosom of the ocean buried. Now are our brows bound with victorious wreaths; Our bruised arms hung up for monuments",
              style: TextStyle(color: AppColors.textColor5, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: RichText(
                text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: 'Created by \n',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.shadowColor1)),
                const TextSpan(
                    text: 'Avinash',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.logout,
                        fontSize: 25)),
              ],
            )),
          ),
        ],
      )),
    );
  }
}
