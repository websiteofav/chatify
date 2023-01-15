// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/frontend/chat/models/chat_model.dart';
import 'package:chat_app/frontend/chat/screens/chat_screen.dart';
import 'package:chat_app/frontend/connections/search_connections.dart';
import 'package:chat_app/frontend/home/bloc/home_bloc.dart';
import 'package:chat_app/frontend/home/models/chat_list_model.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/home/repository/repository.dart';
import 'package:chat_app/frontend/home/screens/chatrooms.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/constants.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:timeago/timeago.dart' as timeago;

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final FocusNode _focusNode = FocusNode();
  List dimensions = [];
  final Dio dio = Dio();

  @override
  void initState() {
    BlocProvider.of<UserDetailBloc>(context).add(
      FetchRealTimeDataEvent(),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    dimensions = deviceDimensions(context);

    super.didChangeDependencies();
  }

  final _localDB = HomeRepository();

  String selectedPartnerUnsername = '', selectedPartnerProfilePic = '';
  List<ChatListModel> chatListModel = [];

  final List<String> _connectedUsernames = [];

  // Map LatestMe

  List docs = [];

  final _searchEditingController = TextEditingController();

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
                partnerProfilePicPath: '',
                partnerProfilePicURL: state.profilePicUrl == null
                    ? selectedPartnerProfilePic
                    : state.profilePicUrl.toString(),
                latestMessage: state.model.last.message,
                latestMessageDate: state.model.last.date.toString(),
                username: state.uername,
                numberOfmessage: '0',
                typeOfMessage: state.model.last.typeOfMessage,
                read: true,
                senderUsername: state.model.last.messageHolder.toString());
          } else {
            latestMessageModel = ChatListModel(
                partnerProfilePicURL: state.profilePicUrl == null
                    ? selectedPartnerProfilePic
                    : state.profilePicUrl.toString(),
                partnerProfilePicPath: '',
                latestMessage: 'Start Chatting',
                latestMessageDate: Constants.dummyMessageDate,
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

          chatListModel.sort(
            (a, b) {
              return DateTime.parse(b.latestMessageDate)
                  .compareTo(DateTime.parse(a.latestMessageDate));
            },
          );

          setState(() {});
        }
      },
      child: BlocListener<UserDetailBloc, UserDetailState>(
        listener: (context, state) {
          if (state is RealTimeDateFetched) {
            state.snapshot.listen((event) {
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
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SizedBox(
            height: dimensions[0] - 250 - MediaQuery.of(context).padding.top,
            child: Scaffold(
              backgroundColor: AppColors.backgroundColor1,
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () => _focusNode.requestFocus(),
              //   child: Icon(
              //     Icons.search_rounded,
              //     color: Colors.white,
              //   ),
              // ),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: Container(
                  width: 200,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 80,
                          child: TextField(
                            onChanged: (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {});
                              }
                            },
                            controller: _searchEditingController,
                            style: const TextStyle(color: AppColors.textColor2),
                            decoration: InputDecoration(
                              suffixIcon: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.iconColor1,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.search_rounded,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.textFieldBackgroundColor,
                              hintText: 'Search...',
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[200]),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                  // color: Colors.black,
                                  width: 3.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {},
                          child: Material(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            elevation: 12,
                            child: OpenContainer(
                                openColor: AppColors.backgroundColor1,
                                closedColor: AppColors.backgroundColor1,
                                transitionType:
                                    ContainerTransitionType.fadeThrough,
                                transitionDuration: Duration(milliseconds: 500),
                                openElevation: 15,
                                openBuilder: (context, openWidget) {
                                  return SearchConnections();
                                },

                                // height: 60,
                                // decoration: BoxDecoration(
                                //   color: AppColors.backgroundColor3,
                                //   borderRadius: BorderRadius.all(Radius.circular(12)),
                                // ),
                                closedBuilder: (context, closedWidget) {
                                  return Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor3,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: Icon(Icons.add,
                                        color: AppColors.white, size: 30),
                                  );
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.black),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      child: ListView.separated(
                        // physics: NeverScrollableScrollPhysics(),
                        itemCount: chatListModel.length,
                        separatorBuilder: ((context, index) {
                          return SizedBox(
                            height: 5,
                          );
                        }),
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {
                          String timeaAgo = '';

                          if (chatListModel[index]
                              .latestMessageDate
                              .isNotEmpty) {
                            if (chatListModel[index].latestMessageDate ==
                                Constants.dummyMessageDate) {
                              timeaAgo = '';
                            } else {
                              final date = DateTime.parse(
                                  chatListModel[index].latestMessageDate);
                              timeaAgo = timeago.format(date);
                            }
                          }

                          return OpenContainer(
                              openColor: AppColors.backgroundColor1,
                              closedColor: AppColors.backgroundColor1,
                              transitionType:
                                  ContainerTransitionType.fadeThrough,
                              transitionDuration: Duration(milliseconds: 500),
                              openElevation: 15,
                              openBuilder: (context, openWidget) {
                                selectedPartnerUnsername =
                                    chatListModel[index].username;
                                selectedPartnerProfilePic =
                                    chatListModel[index].partnerProfilePicURL;
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                        lazy: false,
                                        create: (context) => UserDetailBloc(
                                            repository: UserRepository())),
                                    BlocProvider(
                                        lazy: false,
                                        create: (context) => HomeBloc(
                                            repository: HomeRepository())),
                                  ],
                                  child: ChatScreen(
                                    partnerUsername:
                                        chatListModel[index].username,
                                  ),
                                );
                              },
                              onClosed: (value) {
                                BlocProvider.of<HomeBloc>(context).add(
                                  FetchUserPartnerMessageEvent(
                                      username: selectedPartnerUnsername,
                                      profilePicUrl: selectedPartnerProfilePic),
                                );
                              },
                              closedBuilder: (context, closedWidget) {
                                return chatListModel[index].username.contains(
                                        _searchEditingController.text.trim())
                                    ? Card(
                                        color: AppColors.backgroundColor1,
                                        elevation: 12,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              chatListModel[index]
                                                          .partnerProfilePicURL ==
                                                      ''
                                                  ? Container(
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .textColor4,
                                                        shape: BoxShape.circle,
                                                        // borderRadius: BorderRadius.circular(15)
                                                      ),
                                                      child: Text(
                                                        chatListModel[index]
                                                            .username
                                                            .substring(0, 1),
                                                        style: TextStyle(
                                                            color:
                                                                AppColors.black,
                                                            fontSize: 25),
                                                      ))
                                                  : ClipOval(
                                                      child: CachedNetworkImage(
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.fill,
                                                        imageUrl: chatListModel[
                                                                index]
                                                            .partnerProfilePicURL,
                                                        progressIndicatorBuilder: (context,
                                                                url,
                                                                downloadProgress) =>
                                                            CircularProgressIndicator(
                                                                value: downloadProgress
                                                                    .progress),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    ),
                                              // Image.network(
                                              //     chatListModel[index]
                                              //         .partnerProfilePicURL,

                                              //   )),
                                              if (chatListModel.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0,
                                                          left: 20,
                                                          bottom: 20),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        chatListModel[index]
                                                            .username,
                                                        style: TextStyle(
                                                            color:
                                                                AppColors.white,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (chatListModel[
                                                                          index]
                                                                      .username !=
                                                                  chatListModel[
                                                                          index]
                                                                      .senderUsername &&
                                                              chatListModel[
                                                                      index]
                                                                  .senderUsername
                                                                  .isNotEmpty)
                                                            Icon(
                                                              Icons.done_all,
                                                              size: 16,
                                                              color: chatListModel[
                                                                          index]
                                                                      .read
                                                                  ? AppColors
                                                                      .backgroundColor4
                                                                  : AppColors
                                                                      .white,
                                                            ),
                                                          Flexible(
                                                            fit: FlexFit.loose,
                                                            child: Text(
                                                              chatListModel[index]
                                                                          .typeOfMessage ==
                                                                      ChatMessageTypes
                                                                          .text
                                                                          .toString()
                                                                  ? chatListModel[
                                                                          index]
                                                                      .latestMessage
                                                                  : chatListModel[index]
                                                                              .typeOfMessage ==
                                                                          ChatMessageTypes
                                                                              .video
                                                                              .toString()
                                                                      ? 'Video'
                                                                      : chatListModel[index].typeOfMessage ==
                                                                              ChatMessageTypes.audio.toString()
                                                                          ? 'Audio'
                                                                          : chatListModel[index].typeOfMessage == ChatMessageTypes.image.toString()
                                                                              ? 'Image'
                                                                              : chatListModel[index].typeOfMessage == ChatMessageTypes.document.toString()
                                                                                  ? 'Document'
                                                                                  : chatListModel[index].typeOfMessage == ChatMessageTypes.location.toString()
                                                                                      ? 'Location'
                                                                                      : '',
                                                              style: TextStyle(
                                                                  color: chatListModel[
                                                                              index]
                                                                          .read
                                                                      ? AppColors
                                                                          .textColor2
                                                                      : AppColors
                                                                          .white,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (chatListModel[index]
                                                      .numberOfmessage !=
                                                  '0')
                                                Container(
                                                  // height: 50,
                                                  padding: EdgeInsets.all(6),
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .backgroundColor5,
                                                    shape: BoxShape.circle,
                                                    // borderRadius: BorderRadius.circular(15)
                                                  ),
                                                  child: Text(
                                                    chatListModel[index]
                                                        .numberOfmessage,
                                                    style: TextStyle(
                                                        color: AppColors.white,
                                                        fontSize: 12),
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 18),
                                                    child: Text(
                                                      timeaAgo,
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .textColor2,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container();
                              });
                        }),
                      ));
                },
              ),
            ),
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

    String partnerProfilePicURL = '';

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

            partnerProfilePicURL = doc.get(UserDetailsFields.profilePic);

            model = UserPrimaryModel(
                email: email,
                profileImagePath: '',
                mobileNumber: '',
                notifications: '',
                profileImageURL: partnerProfilePicURL,
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
              List partnerMessages = messages[email] ?? [];

              if (partnerMessages.isNotEmpty) {
                final latestMessage = messages[email].last;

                int index = -1;
                chatListModel.map((element) {
                  if (element.username == username) {
                    index = chatListModel.indexOf(element);
                  }
                }).toList();
                if (index > -1) {
                  latestMessageModel = ChatListModel(
                      partnerProfilePicPath: '',
                      partnerProfilePicURL: partnerProfilePicURL,
                      latestMessage: latestMessage[ChatMessageFields.message],
                      latestMessageDate: latestMessage[ChatMessageFields.date],
                      username: username,
                      numberOfmessage: messages[email].length.toString(),
                      typeOfMessage:
                          latestMessage[ChatMessageFields.typeOfMessage],
                      read: false,
                      senderUsername:
                          latestMessage[ChatMessageFields.messageHolder]);

                  chatListModel.removeAt(index);

                  chatListModel.insert(index, latestMessageModel);
                } else {
                  latestMessageModel = ChatListModel(
                      partnerProfilePicURL: partnerProfilePicURL,
                      partnerProfilePicPath: '',
                      latestMessage: latestMessage[ChatMessageFields.message],
                      latestMessageDate: latestMessage[ChatMessageFields.date],
                      username: username,
                      numberOfmessage: messages[email].length.toString(),
                      typeOfMessage:
                          latestMessage[ChatMessageFields.typeOfMessage],
                      read: false,
                      senderUsername:
                          latestMessage[ChatMessageFields.messageHolder]);
                  chatListModel.add(latestMessageModel);

                  chatListModel.sort(
                    (a, b) {
                      return DateTime.parse(b.latestMessageDate)
                          .compareTo(DateTime.parse(a.latestMessageDate));
                    },
                  );
                }
              } else {
                BlocProvider.of<HomeBloc>(context).add(
                  FetchUserPartnerMessageEvent(
                      username: username, profilePicUrl: partnerProfilePicURL),
                );
              }

              // messages.values.map((value) {
              //   if (value.isNotEmpty) {
              //     final latestMessage = value.last;

              //   }
              // });
            } else {
              BlocProvider.of<HomeBloc>(context).add(
                  FetchUserPartnerMessageEvent(
                      username: username, profilePicUrl: partnerProfilePicURL));
            }
          }
        }).toList();
      }
    }).toList();
  }

  Future<String> _getPartnerProfilePic(
      {required String newprofilePicUrl, ChatListModel? chatListModel}) async {
    if (chatListModel != null) {
      if (newprofilePicUrl == chatListModel.partnerProfilePicURL) {
        return chatListModel.partnerProfilePicPath;
      } else {
        final Directory? directory = await getExternalStorageDirectory();

        final profileStorage =
            await Directory("${directory!.path}/profilePic").create();
        final String imageSroragePath =
            "${profileStorage.path}${DateTime.now().toString().split(" ").join("")}.png";

        await dio.download(newprofilePicUrl, imageSroragePath);

        return imageSroragePath;
      }
    } else {
      final Directory? directory = await getExternalStorageDirectory();

      final profileStorage =
          await Directory("${directory!.path}/profilePic").create();
      final String imageSroragePath =
          "${profileStorage.path}${DateTime.now().toString().split(" ").join("")}.png";

      await dio.download(newprofilePicUrl, imageSroragePath);

      return imageSroragePath;
    }
  }
}
