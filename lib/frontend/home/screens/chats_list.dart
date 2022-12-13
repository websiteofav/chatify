// ignore_for_file: prefer_const_constructors

import 'package:animations/animations.dart';
import 'package:chat_app/frontend/chat/screens/chat_screen.dart';
import 'package:chat_app/frontend/home/screens/chatrooms.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 20,
        separatorBuilder: ((context, index) {
          return SizedBox(
            height: 5,
          );
        }),
        shrinkWrap: true,
        itemBuilder: ((context, index) {
          return InkWell(
            onTap: (() => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                )),
            child: OpenContainer(
                openColor: AppColors.backgroundColor1,
                closedColor: AppColors.backgroundColor1,
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: Duration(milliseconds: 500),
                openElevation: 15,
                openBuilder: (context, openWidget) {
                  return ChatScreen();
                },
                closedBuilder: (context, closedWidget) {
                  return Card(
                    color: AppColors.backgroundColor1,
                    elevation: 12,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            // height: 50,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.textColor4,
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.circular(15)
                            ),
                            child: Text(
                              'A',
                              style: TextStyle(
                                  color: AppColors.black, fontSize: 25),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 20, bottom: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shivam',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Text(
                                    'How are you?',
                                    style: TextStyle(
                                        color: AppColors.textColor2,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: AppColors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 18),
                                child: Text(
                                  '10h',
                                  style: TextStyle(
                                      color: AppColors.textColor2,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          );
        }),
      ),
    );
  }
}
