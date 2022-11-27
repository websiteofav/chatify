import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/image_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final dimensions = deviceDimensions(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor1,
      appBar: AppBar(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text(
          'Profile',
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
            SizedBox(
              height: dimensions[0] * 0.4,
              child: Stack(children: [
                Container(
                  height: dimensions[0] * 0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          AppColors.backgroundColor6, BlendMode.dstATop),
                      image: const AssetImage(ImagePaths.coverBackground),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned.fill(
                    top: dimensions[0] * 0.20,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(ImagePaths.google,
                          height: dimensions[0] * 0.1, fit: BoxFit.fill),
                    )),
              ]),
            ),
            Container(
              padding: EdgeInsets.all(20),
              height: 100,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor1,
                    blurRadius: 5.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Username :',
                    style: TextStyle(
                        color: AppColors.backgroundColor2, fontSize: 20),
                  ),
                  Text('Avinash',
                      style: TextStyle(color: AppColors.logout, fontSize: 25))
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              height: 100,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor1,
                    blurRadius: 5.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'About :',
                    style: TextStyle(
                        color: AppColors.backgroundColor2, fontSize: 20),
                  ),
                  Text('Flutter Developer',
                      style: TextStyle(color: AppColors.logout, fontSize: 25))
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              height: 100,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor1,
                    blurRadius: 5.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Date Joined :',
                    style: TextStyle(
                        color: AppColors.backgroundColor2, fontSize: 20),
                  ),
                  Text('22-July-2022',
                      style: TextStyle(color: AppColors.logout, fontSize: 25))
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                ),
              ),
              width: dimensions[1] * 0.8,
              child: ElevatedButton(
                onPressed: null,
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.logout)),
                child: const Text(
                  'Delete My Account',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
