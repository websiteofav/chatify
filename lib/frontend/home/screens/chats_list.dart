// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:chat_app/frontend/chat/models/chat_model.dart';
import 'package:chat_app/frontend/chat/screens/chat_screen.dart';
import 'package:chat_app/frontend/home/bloc/home_bloc.dart';
import 'package:chat_app/frontend/home/models/chat_list_model.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/home/repository/repository.dart';
import 'package:chat_app/frontend/home/screens/chatrooms.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
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

import 'package:timeago/timeago.dart' as timeago;

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

  final _localDB = HomeRepository();

  String selectedPartnerUnsername = '';
  List<ChatListModel> chatListModel = [];

  final List<String> _connectedUsernames = [];

  // Map LatestMe

  List docs = [];

  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _streamSubscription;

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
        } else if (state is PartnerMessageFetched) {
          ChatListModel latestMessageModel;

          if (state.model.isNotEmpty) {
            latestMessageModel = ChatListModel(
                latestMessage: state.model.last.message,
                latestMessageDate: state.model.last.date.toString(),
                username: state.uername,
                numberOfmessage: '0',
                typeOfMessage: state.model.last.typeOfMessage,
                read: true,
                senderUsername: state.model.last.messageHolder.toString());
          } else {
            latestMessageModel = ChatListModel(
                latestMessage: 'Start Chatting',
                latestMessageDate: '',
                username: state.uername,
                numberOfmessage: '0',
                typeOfMessage: ChatMessageTypes.text.toString(),
                read: true,
                senderUsername: '');
          }

          docs.map((snapshot) {
            final String partnerName = snapshot.get(UserDetailsFields.username);
            if (partnerName == state.uername) {
              Map<String, dynamic>? messages =
                  snapshot.get(UserDetailsFields.partners);

              List? sentMessages = messages![
                  FirebaseAuth.instance.currentUser!.email.toString()];
              sentMessages = sentMessages ?? [];
              latestMessageModel.read = sentMessages.isEmpty;
            }
          }).toList();

          int index = -1;
          chatListModel.map((element) {
            if (element.username == latestMessageModel.username) {
              index = chatListModel.indexOf(element);
            }
          }).toList();
          if (index > -1) {
            chatListModel.removeAt(index);
            chatListModel.insert(index, latestMessageModel);
          } else {
            chatListModel.add(latestMessageModel);
          }
          setState(() {});
        }
      },
      child: BlocListener<UserDetailBloc, UserDetailState>(
        listener: (context, state) {
          if (state is RealTimeDateFetched) {
            _streamSubscription = state.snapshot.listen((event) {
              event.docs.map((snapshot) {
                docs.add(snapshot);
                if (snapshot.id == FirebaseAuth.instance.currentUser!.email) {
                  _checkForNewConnection(snapshot, event.docs);
                  // _checkForLatestMessage(snapshot, event.docs);
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
            itemCount: chatListModel.length,
            separatorBuilder: ((context, index) {
              return SizedBox(
                height: 5,
              );
            }),
            shrinkWrap: true,
            itemBuilder: ((context, index) {
              String timeaAgo = '';

              if (chatListModel[index].latestMessageDate.isNotEmpty) {
                final date =
                    DateTime.parse(chatListModel[index].latestMessageDate);
                timeaAgo = timeago.format(date);
              }

              return OpenContainer(
                  openColor: AppColors.backgroundColor1,
                  closedColor: AppColors.backgroundColor1,
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: Duration(milliseconds: 500),
                  openElevation: 15,
                  openBuilder: (context, openWidget) {
                    selectedPartnerUnsername = chatListModel[index].username;
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            lazy: false,
                            create: (context) =>
                                UserDetailBloc(repository: UserRepository())),
                        BlocProvider(
                            lazy: false,
                            create: (context) =>
                                HomeBloc(repository: HomeRepository())),
                      ],
                      child: ChatScreen(
                        partnerUsername: chatListModel[index].username,
                      ),
                    );
                  },
                  onClosed: (value) {
                    BlocProvider.of<HomeBloc>(context).add(
                      FetchUserPartnerMessageEvent(
                          username: selectedPartnerUnsername),
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
                                chatListModel[index].username.substring(0, 1),
                                style: TextStyle(
                                    color: AppColors.black, fontSize: 25),
                              ),
                            ),
                            if (chatListModel.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, left: 20, bottom: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatListModel[index].username,
                                      style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (chatListModel[index].username !=
                                                chatListModel[index]
                                                    .senderUsername &&
                                            chatListModel[index]
                                                .senderUsername
                                                .isNotEmpty)
                                          Icon(
                                            Icons.done_all,
                                            size: 16,
                                            color: chatListModel[index].read
                                                ? AppColors.backgroundColor4
                                                : AppColors.white,
                                          ),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            chatListModel[index]
                                                        .typeOfMessage ==
                                                    ChatMessageTypes.text
                                                        .toString()
                                                ? chatListModel[index]
                                                    .latestMessage
                                                : chatListModel[index]
                                                            .typeOfMessage ==
                                                        ChatMessageTypes.video
                                                            .toString()
                                                    ? 'Video'
                                                    : chatListModel[index]
                                                                .typeOfMessage ==
                                                            ChatMessageTypes
                                                                .audio
                                                                .toString()
                                                        ? 'Audio'
                                                        : chatListModel[index]
                                                                    .typeOfMessage ==
                                                                ChatMessageTypes
                                                                    .image
                                                                    .toString()
                                                            ? 'Image'
                                                            : chatListModel[index]
                                                                        .typeOfMessage ==
                                                                    ChatMessageTypes
                                                                        .document
                                                                        .toString()
                                                                ? 'Document'
                                                                : chatListModel[index]
                                                                            .typeOfMessage ==
                                                                        ChatMessageTypes
                                                                            .location
                                                                            .toString()
                                                                    ? 'Location'
                                                                    : '',
                                            style: TextStyle(
                                                color: chatListModel[index].read
                                                    ? AppColors.textColor2
                                                    : AppColors.white,
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (chatListModel[index].numberOfmessage != '0')
                              Container(
                                // height: 50,
                                padding: EdgeInsets.all(6),
                                margin: EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColor5,
                                  shape: BoxShape.circle,
                                  // borderRadius: BorderRadius.circular(15)
                                ),
                                child: Text(
                                  chatListModel[index].numberOfmessage,
                                  style: TextStyle(
                                      color: AppColors.white, fontSize: 12),
                                ),
                              ),
                            Spacer(),
                            Column(
                              children: [
                                // Icon(
                                //   Icons.notifications,
                                //   color: AppColors.white,
                                // ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 18),
                                  child: Text(
                                    timeaAgo,
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
    final List partnerRequest = snapshot.get(UserDetailsFields.partnerRequests);
    Map<String, dynamic>? messages = snapshot.get(UserDetailsFields.partners);
    messages = messages ?? {};
    String username = '';

    partnerRequest.map((e) {
      if (e.values.first.toString() == UserPartnersState.connected.toString() ||
          e.values.first.toString() ==
              OtherUserPartnersState.requestAccepted.toString()) {
        docs.map((doc) async {
          if (doc.id == e.keys.first.toString()) {
            final String email = doc.get(UserDetailsFields.email);

            username = doc.get(UserDetailsFields.username);
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
            ChatListModel latestMessageModel;

            if (messages!.isNotEmpty) {
              if (messages[email] != null && messages[email].isNotEmpty) {
                final latestMessage = messages[email].last;

                latestMessageModel = ChatListModel(
                    latestMessage: latestMessage[ChatMessageFields.message],
                    latestMessageDate: latestMessage[ChatMessageFields.date],
                    username: username,
                    numberOfmessage: messages[email].length.toString(),
                    typeOfMessage:
                        latestMessage[ChatMessageFields.typeOfMessage],
                    read: false,
                    senderUsername:
                        latestMessage[ChatMessageFields.messageHolder]);

                int index = -1;
                chatListModel.map((element) {
                  if (element.username == latestMessageModel.username) {
                    index = chatListModel.indexOf(element);
                  }
                }).toList();
                if (index > -1) {
                  chatListModel.removeAt(index);
                  chatListModel.insert(index, latestMessageModel);
                } else {
                  chatListModel.add(latestMessageModel);
                }
                setState(() {});
              } else {
                BlocProvider.of<HomeBloc>(context).add(
                  FetchUserPartnerMessageEvent(username: username),
                );
              }

              // messages.values.map((value) {
              //   if (value.isNotEmpty) {
              //     final latestMessage = value.last;

              //   }
              // });
            } else {
              // BlocProvider.of<HomeBloc>(context).add(
              //   FetchUserPartnerMessageEvent(username: username),
              // );
              String error = username;

              while (error.contains(username)) {
                try {
                  List<dynamic> model =
                      await _localDB.queryMessageInUserTable(username);

                  if (model.isNotEmpty) {
                    latestMessageModel = ChatListModel(
                        latestMessage: model.last.message,
                        latestMessageDate: model.last.date.toString(),
                        username: username,
                        numberOfmessage: '0',
                        typeOfMessage: model.last.typeOfMessage,
                        read: true,
                        senderUsername: model.last.messageHolder.toString());
                  } else {
                    latestMessageModel = ChatListModel(
                        latestMessage: 'Start Chatting',
                        latestMessageDate: '',
                        username: username,
                        numberOfmessage: '0',
                        typeOfMessage: ChatMessageTypes.text.toString(),
                        read: true,
                        senderUsername: '');
                  }

                  setState(() {
                    chatListModel.add(latestMessageModel);
                  });

                  error = '';
                } catch (e) {
                  if (e.toString().contains('username')) {
                    error = username;
                  }
                }
              }
            }
          }
        }).toList();
      }
    }).toList();
  }
}
