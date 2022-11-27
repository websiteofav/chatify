// ignore_for_file: prefer_const_constructors

import 'package:chat_app/frontend/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatroomsList extends StatefulWidget {
  const ChatroomsList({Key? key}) : super(key: key);

  @override
  State<ChatroomsList> createState() => _ChatroomsListState();
}

class _ChatroomsListState extends State<ChatroomsList> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundColor1,
      elevation: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Text('Chatrooms',
                style: TextStyle(fontSize: 35, color: AppColors.textColor5)),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20, top: 15),
            height: 150,
            child: ListView.builder(
                // separatorBuilder: (context, index) {
                //   return SizedBox(
                //     width: 15,
                //   );
                // },
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (ctx, index) {
                  return Container(
                    alignment: Alignment.bottomLeft,
                    margin: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    padding: EdgeInsets.all(10),
                    width: 80,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor1,
                          blurRadius: 5.0,
                        ),
                      ],
                      gradient: LinearGradient(colors: [
                        AppColors.backgroundColor5,
                        AppColors.backgroundColor4
                      ]),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Flutter',
                            style: TextStyle(
                                color: AppColors.white, fontSize: 20)),
                        // Spacer(),
                        Text(
                          'Rahul',
                          style: TextStyle(color: AppColors.textColor2),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
