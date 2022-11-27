import 'package:chat_app/frontend/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class UserCalls extends StatefulWidget {
  const UserCalls({Key? key}) : super(key: key);

  @override
  State<UserCalls> createState() => _UserCallsState();
}

class _UserCallsState extends State<UserCalls> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (((context, index) {
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
                      style: TextStyle(color: AppColors.balck, fontSize: 25),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 20, bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Udit',
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
                            child: RichText(
                              text: TextSpan(
                                children: const [
                                  WidgetSpan(
                                      child: Icon(
                                    Icons.call_received_rounded,
                                    color: AppColors.backgroundColor3,
                                    size: 20,
                                  )),
                                  TextSpan(
                                      text: '24 November 2022',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColor3)),
                                ],
                              ),
                            )
                            // Text(
                            //   'How are you?',
                            //   style: TextStyle(
                            //       color: AppColors.textColor2,
                            //       overflow: TextOverflow.ellipsis,
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w600),
                            // ),
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
        })),
        separatorBuilder: ((context, index) {
          return SizedBox(
            height: 10,
          );
        }),
        itemCount: 20);
  }
}
