// ignore_for_file: prefer_const_constructors

import 'package:animations/animations.dart';
import 'package:chat_app/frontend/chat/screens/chat_screen.dart';
import 'package:chat_app/frontend/home/bloc/home_bloc.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/home/screens/chatrooms.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  void initState() {
    BlocProvider.of<UserDetailBloc>(context).add(
      FetchRealTimeDataEvent(),
    );
    super.initState();
  }

  final List<String> _connectedUsernames = [];

  UserPrimaryModel? model;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is UserPrimaryDetailsLoaded) {
          BlocProvider.of<HomeBloc>(context).add(
            CreateUserMessageTableEvent(
                username: state.model.userName.toString()),
          );
        } else if (state is UserMessageTableCreated) {
          if (!_connectedUsernames.contains(state.username)) {
            setState(() {
              _connectedUsernames.add(state.username);
            });
          }
        }
      },
      child: BlocListener<UserDetailBloc, UserDetailState>(
        listener: (context, state) {
          if (state is RealTimeDateFetched) {
            state.snapshot.listen((event) {
              event.docs.map((snapshot) {
                if (snapshot.id == FirebaseAuth.instance.currentUser!.email) {
                  _checkForNewConnection(snapshot, event.docs);
                }
              }).toList();
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: _connectedUsernames.length,
            separatorBuilder: ((context, index) {
              return SizedBox(
                height: 5,
              );
            }),
            shrinkWrap: true,
            itemBuilder: ((context, index) {
              return OpenContainer(
                  openColor: AppColors.backgroundColor1,
                  closedColor: AppColors.backgroundColor1,
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: Duration(milliseconds: 500),
                  openElevation: 15,
                  openBuilder: (context, openWidget) {
                    return ChatScreen(
                      partnerUsername: _connectedUsernames[index],
                    );
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
                                _connectedUsernames[index].substring(0, 1),
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
                                    _connectedUsernames[index],
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
                  });
            }),
          ),
        ),
      ),
    );
  }

  void _checkForNewConnection(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final List _partnerRequest =
        snapshot.get(UserDetailsFields.partnerRequests);

    _partnerRequest.map((e) {
      if (e.values.first.toString() == UserPartnersState.connected.toString() ||
          e.values.first.toString() ==
              OtherUserPartnersState.requestAccepted.toString()) {
        docs.map((doc) {
          if (doc.id == e.keys.first.toString()) {
            final String email = doc.get(UserDetailsFields.email);

            final String username = doc.get(UserDetailsFields.username);
            final String token = doc.get(UserDetailsFields.token);
            final String bio = doc.get(UserDetailsFields.bio);
            final String accountCreationDate =
                doc.get(UserDetailsFields.accountCreationDate);

            final String accountCreationTime =
                doc.get(UserDetailsFields.accountCreationTime);

            model = UserPrimaryModel(
                email: email,
                profileImagePath: '',
                mobileNumber: '',
                notifications: '',
                profileImageURL: '',
                wallpaper: '',
                accountCreationDate: accountCreationDate,
                accountCreationTime: accountCreationTime,
                bio: bio,
                token: token,
                userName: username);

            BlocProvider.of<HomeBloc>(context).add(AddPrimaryDataEvent(
              model: model!,
            ));
          }
        }).toList();
      }
    }).toList();
  }
}
