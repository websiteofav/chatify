// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_app/frontend/home/bloc/home_bloc.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/home/repository/repository.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:animations/animations.dart';
import 'package:chat_app/frontend/chat/models/chat_model.dart';
import 'package:chat_app/frontend/chat/screens/image_view.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:chat_app/frontend/utils/show_toast_messages.dart';
import 'package:circle_list/circle_list.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:record/record.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/percent_indicator.dart';

// impor;

class ChatScreen extends StatefulWidget {
  final String partnerUsername;
  const ChatScreen({Key? key, required this.partnerUsername}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _emojiEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final _localDB = HomeRepository();

  int? currentAudioIndex = -1;

  ChatMessageModel? model;

  double? currAudioPlayingTime;

  double audioPlayingSpeed = 1.0;
  final record = Record();

  /// Audio Playing Time Related
  String totalDuration = '0:00';
  String loadingTime = '0:00';

  final player = AudioPlayer();

  List<ChatMessageModel> _allMessages = [];

  final FToast fToast = FToast();
  bool _showEmojiPicker = false;

  final ScrollController _controller = ScrollController();

  double chatBoxHeight = 0;

  List<ChatMessageModel>? incomingMessagesModel;

  IconData _iconData = Icons.play_arrow_rounded;

  Directory? audioDirectory;
  String downloadUrl = '';

  String partnerEmail = '';

  final Dio dio = Dio();
  void initState() {
    fToast.init(context);
    _takeStoragePermission();
    _getPartnerEmail();
    _fetchPastMessages();
    _fetchIncomingMessage();
    super.initState();
  }

  void _takeStoragePermission() async {
    var request = await Permission.storage.request();
    if (request == PermissionStatus.granted) {
      showToast(
          fToast: fToast,
          message: '',
          toastColor: AppColors.backgroundColor3,
          fontSize: 16);

      _directoryForAudioRecording();
    } else {
      showToast(
          fToast: fToast,
          message: 'Permission denied',
          toastColor: AppColors.logout,
          fontSize: 16);
    }
  }

  void _getPartnerEmail() async {
    partnerEmail = await _localDB.getImportantData(
        widget.partnerUsername, UserPrimaryFields.email);
  }

  void _fetchPastMessages() async {
    List<ChatMessageModel> model =
        await _localDB.queryMessageInUserTable(widget.partnerUsername);

    _allMessages.addAll(model);
    _allMessages = _allMessages.reversed.toList();
  }

  void _fetchIncomingMessage() {
    BlocProvider.of<UserDetailBloc>(context).add(
      FetchRealTimeMessageEvent(),
    );
  }

  void _directoryForAudioRecording() async {
    final Directory? directory = await getExternalStorageDirectory();

    audioDirectory = await Directory('${directory!.path}/Recordings').create();
  }

  List dimensions = [];

  void didChangeDependencies() {
    super.didChangeDependencies();
    dimensions = deviceDimensions(context);
    chatBoxHeight =
        dimensions[0] - 130 - MediaQuery.of(context).viewPadding.top;
  }

  @override
  void dispose() {
    player.dispose();
    record.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          if (_showEmojiPicker) {
            setState(() {
              _showEmojiPicker = false;

              chatBoxHeight += 300;
            });

            return false;
          }
          return true;
        },
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.backgroundColor1,
          appBar: AppBar(
            toolbarHeight: 60,
            backgroundColor: AppColors.textFieldBackgroundColor,
            title: Row(
              children: [
                Container(
                  // height: 50,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.textColor4,
                    shape: BoxShape.circle,
                    // borderRadius: BorderRadius.circular(15)
                  ),
                  child: Text(
                    'A',
                    style: TextStyle(color: AppColors.black, fontSize: 20),
                  ),
                ),
                Text(
                  widget.partnerUsername,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(
                  Icons.call,
                  color: AppColors.backgroundColor3,
                )
              ],
            ),
          ),
          body: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is UserMessageAddedToTable) {
                setState(() {
                  _allMessages.insert(0, state.model);
                });
              }
            },
            child: BlocListener<UserDetailBloc, UserDetailState>(
              listener: (context, state) {
                if (state is ChatMessageAdded) {
                  // setState(() {
                  //   _allMessages.add(model!);
                  // });
                  BlocProvider.of<HomeBloc>(context).add(
                    InserMessageToTableEvent(
                        model: model!, username: widget.partnerUsername),
                  );
                } else if (state is ChatMessageAddedFailed) {
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: state.message,
                  );
                } else if (state is RealTimeMessageFetched) {
                  state.snapshot.listen((doc) {
                    _checkForIncomingMessages(doc.data());
                  });
                } else if (state is OldMessagesRemoved) {
                  incomingMessagesModel!.map((e) {
                    if (e.typeOfMessage == ChatMessageTypes.text.toString()) {
                      BlocProvider.of<HomeBloc>(context).add(
                        InserMessageToTableEvent(
                            model: e, username: widget.partnerUsername),
                      );
                    } else if (e.typeOfMessage ==
                        ChatMessageTypes.audio.toString()) {
                      _manageIcomingMediaMessage(e, ChatMessageTypes.audio);
                    } else if (e.typeOfMessage ==
                        ChatMessageTypes.image.toString()) {
                      _manageIcomingMediaMessage(e, ChatMessageTypes.image);
                    } else if (e.typeOfMessage ==
                        ChatMessageTypes.video.toString()) {
                      _manageIcomingMediaMessage(e, ChatMessageTypes.video);
                    } else if (e.typeOfMessage ==
                        ChatMessageTypes.location.toString()) {
                      BlocProvider.of<HomeBloc>(context).add(
                        InserMessageToTableEvent(
                            model: e, username: widget.partnerUsername),
                      );
                    } else if (e.typeOfMessage ==
                        ChatMessageTypes.document.toString()) {
                      _manageIcomingMediaMessage(e, ChatMessageTypes.document);
                    }
                  }).toList();
                } else if (state is FileUploadedToStorage) {
                  if (state.reference == 'chatVideo/') {
                    downloadUrl = state.downloadUrl;
                    BlocProvider.of<UserDetailBloc>(context).add(
                      UploadFileToFirebaseStorageEvent(
                          filePath: File(model!.thumbnailPath.toString()),
                          reference: 'chatVideoThumbnail/'),
                    );
                  } else {
                    final partnerModel = ChatMessageModel(
                      message: model!.message,
                      recievedMessage: model!.recievedMessage ?? '',
                      time: model!.time,
                      typeOfMessage: model!.typeOfMessage,
                      date: model!.date,
                      fileName: model!.fileName ?? '',
                      messageHolder: model!.messageHolder ?? '',
                      thumbnailPath: model!.thumbnailPath ?? '',
                    );
                    if (state.reference == 'chatVideoThumbnail/') {
                      partnerModel.thumbnailPath = state.downloadUrl;
                    }
                    partnerModel.fileName = state.downloadUrl;
                    BlocProvider.of<UserDetailBloc>(context).add(
                      SendChatMessageEvent(
                          model: partnerModel,
                          username: widget.partnerUsername),
                    );
                  }

                  // BlocProvider.of<HomeBloc>(context).add(
                  //   InserMessageToTableEvent(
                  //       model: model!, username: widget.partnerUsername),
                  // );
                } else if (state is FileUploadedToStorageFaield) {
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: state.message,
                  );
                }
              },
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height:
                        chatBoxHeight - MediaQuery.of(context).padding.bottom,
                    child: ListView.builder(
                        // physics: NeverScrollableScrollPhysics(),
                        controller: _controller,
                        itemCount: _allMessages.length,
                        shrinkWrap: true,
                        reverse: true,
                        itemBuilder: (ctx, index) {
                          if (_allMessages[index].typeOfMessage.toString() ==
                              ChatMessageTypes.text.toString()) {
                            return _textConversation(index);
                          } else if (_allMessages[index]
                                      .typeOfMessage
                                      .toString() ==
                                  ChatMessageTypes.image.toString() ||
                              _allMessages[index].typeOfMessage.toString() ==
                                  ChatMessageTypes.video.toString()) {
                            return _mediaConversation(index);
                          } else if (_allMessages[index]
                                  .typeOfMessage
                                  .toString() ==
                              ChatMessageTypes.document.toString()) {
                            return _documentConversation(index);
                          } else if (_allMessages[index]
                                  .typeOfMessage
                                  .toString() ==
                              ChatMessageTypes.location.toString()) {
                            return _locationConversation(index);
                          } else if (_allMessages[index]
                                  .typeOfMessage
                                  .toString() ==
                              ChatMessageTypes.audio.toString()) {
                            return _audioConversation(index);
                          }

                          return Container();
                        }),
                  ),
                  _messageBottomSheet(),
                  if (_showEmojiPicker) _emojiPicker(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkForIncomingMessages(
    document,
  ) {
    final Map partner = document[UserDetailsFields.partners];

    List? incomingMessages = partner[partnerEmail];

    if (incomingMessages != null && incomingMessages.isNotEmpty) {
      incomingMessagesModel =
          incomingMessages.map((e) => ChatMessageModel.fromJson(e)).toList();

      if (mounted) {
        BlocProvider.of<UserDetailBloc>(context).add(
          RemoveOldMessageEvent(partnerEmail: partnerEmail),
        );
      }
    }
  }

  void _manageIcomingMediaMessage(
      ChatMessageModel voiceModel, ChatMessageTypes chatMessageTypes) async {
    try {
      String reference = '';
      String extension = '';
      String? thumbnailPath;
      if (chatMessageTypes == ChatMessageTypes.audio) {
        reference = '/Audios/';
        extension = '.mp3';
      } else if (chatMessageTypes == ChatMessageTypes.image) {
        reference = '/Images/';
        extension = '.png';
      } else if (chatMessageTypes == ChatMessageTypes.document) {
        reference = '/Documents/';
        extension = '.pdf';
      } else if (chatMessageTypes == ChatMessageTypes.video) {
        reference = '/Videos/';
        extension = '.mp4';
      }

      final Directory? directory = await getExternalStorageDirectory();

      final audioStorage =
          await Directory("${directory!.path}$reference").create();
      final String audioSroragePath =
          "${audioStorage.path}${DateTime.now().toString().split(" ").join("")}$extension";

      await dio.download(voiceModel.fileName.toString(), audioSroragePath);
      if (chatMessageTypes == ChatMessageTypes.video) {
        final thubnailStorage =
            await Directory("${directory.path}/Thumbnail").create();
        thumbnailPath =
            "${thubnailStorage.path}${DateTime.now().toString().split(" ").join("")}.png";
        await dio.download(voiceModel.thumbnailPath.toString(), thumbnailPath);
      }

      final recievedMediaModel = ChatMessageModel(
        message: audioSroragePath,
        time: voiceModel.time,
        typeOfMessage: voiceModel.typeOfMessage,
        recievedMessage: voiceModel.recievedMessage,
        date: voiceModel.date,
        fileName: voiceModel.fileName,
        messageHolder: voiceModel.messageHolder,
        thumbnailPath: thumbnailPath,
      );

      if (mounted) {
        BlocProvider.of<HomeBloc>(context).add(
          InserMessageToTableEvent(
              model: recievedMediaModel, username: widget.partnerUsername),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _manageIcomingLocationMessage(ChatMessageModel chatMessageModel) {}

  Widget _emojiPicker() {
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (Category? category, Emoji emoji) {
          setState(() {
            _textEditingController.text += emoji.emoji;
          });
        },
        onBackspacePressed: () {
          _focusNode.requestFocus();
        },
        textEditingController:
            _emojiEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
        config: Config(
          columns: 7,
          emojiSizeMax: 32 *
              (foundation.defaultTargetPlatform == TargetPlatform.iOS
                  ? 1.30
                  : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
          verticalSpacing: 0,
          horizontalSpacing: 0,
          gridPadding: EdgeInsets.zero,
          initCategory: Category.RECENT,
          bgColor: Color(0xFFF2F2F2),
          indicatorColor: Colors.blue,
          iconColor: Colors.grey,
          iconColorSelected: Colors.blue,
          backspaceColor: Colors.blue,
          skinToneDialogBgColor: Colors.white,
          skinToneIndicatorColor: Colors.grey,
          enableSkinTones: true,
          showRecentsTab: true,
          recentsLimit: 28,
          noRecents: const Text(
            'No Recents',
            style: TextStyle(fontSize: 20, color: Colors.black26),
            textAlign: TextAlign.center,
          ), // Needs to be const Widget
          loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
        ),
      ),
    );
  }

  Widget _messageBottomSheet() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.backgroundColor7,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              20,
            ),
            topRight: Radius.circular(20),
          )),
      height: 70,
      width: double.maxFinite,
      child: Row(children: [
        IconButton(
            onPressed: () {
              setState(() {});
              _showEmojiPicker = !_showEmojiPicker;

              chatBoxHeight =
                  _showEmojiPicker ? chatBoxHeight - 300 : chatBoxHeight + 300;

              FocusManager.instance.primaryFocus?.unfocus();
            },
            icon: Icon(
              Icons.emoji_emotions_rounded,
              color: AppColors.borderColor1,
              size: 30,
            )),
        IconButton(
            onPressed: _attachmentOptions,
            icon: Icon(
              Icons.attach_file_rounded,
              color: AppColors.backgroundColor4,
              size: 30,
            )),
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextField(
              onChanged: (value) {
                setState(() {});
              },
              maxLines: null,
              onTap: () {
                setState(() {
                  // if (MediaQuery.of(context).padding.bottom > 0) {
                  //   chatBoxHeight = chatBoxHeight - 300;
                  // } else {
                  //   chatBoxHeight = chatBoxHeight + 300;
                  // }

                  // -
                  // MediaQuery.of(context).padding.bottom;
                  _focusNode.requestFocus();

                  _showEmojiPicker = false;
                });
              },
              controller: _textEditingController,
              focusNode: _focusNode,
              style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
              decoration: InputDecoration(
                suffixIcon: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                        _textEditingController.text.isEmpty
                            ? Icons.keyboard_voice_rounded
                            : Icons.send_outlined,
                        size: 22),
                    onPressed: () {
                      if (_textEditingController.text.isNotEmpty) {
                        setState(() {
                          sendText();

                          _textEditingController.clear();
                        });

                        _controller
                            .jumpTo(_controller.position.maxScrollExtent);
                      } else {
                        _audioRecording();

                        _recordVoice();
                      }
                    },
                    color: AppColors.backgroundColor3,
                  ),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor7,
                hintText: 'Type...',
                hintStyle: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange[200]),
                enabledBorder: const UnderlineInputBorder(
                  // borderRadius: BorderRadius.all(Radius.circular(10)),
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(
                    color: AppColors.backgroundColor4,
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void sendText() {
    final currentTime = '${DateTime.now().hour}:${DateTime.now().minute}';
    model = ChatMessageModel(
      message: _textEditingController.text,
      time: currentTime,
      typeOfMessage: ChatMessageTypes.text.toString(),
      recievedMessage: true,
      fileName: null,
      thumbnailPath: null,
      date: DateTime.now().toString(),
    );
    _textEditingController.clear();

    BlocProvider.of<UserDetailBloc>(context).add(
      SendChatMessageEvent(model: model!, username: widget.partnerUsername),
    );
  }

  void _attachmentOptions() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              elevation: 0.3,
              backgroundColor: AppColors.backgroundColor8,
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.7,
                child: Center(
                  child: CircleList(
                    initialAngle: 55,
                    outerRadius: MediaQuery.of(context).size.width / 3.2,
                    innerRadius: MediaQuery.of(context).size.width / 10,
                    showInitialAnimation: true,
                    innerCircleColor: Color.fromRGBO(34, 48, 60, 1),
                    outerCircleColor: Color.fromRGBO(0, 0, 0, 0.1),
                    origin: Offset(0, 0),
                    rotateMode: RotateMode.allRotate,
                    centerWidget: Center(
                      child: Text(
                        "Type",
                        style: TextStyle(
                          color: AppColors.backgroundColor4,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            )),
                        child: GestureDetector(
                          onTap: () {
                            Future.delayed(Duration(seconds: 1),
                                _mediaOptions(ChatMessageTypes.image));
                          },
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            )),
                        child: GestureDetector(
                          onTap: () async => Future.delayed(
                              Duration(seconds: 1),
                              _mediaOptions(ChatMessageTypes.video)),
                          child: Icon(
                            Icons.video_collection,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            )),
                        child: GestureDetector(
                          onTap: () async {
                            await _pickFileFromStorage();
                          },
                          child: Icon(
                            Icons.document_scanner_outlined,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            )),
                        child: GestureDetector(
                          onTap: () async {
                            final PermissionStatus locationStatus =
                                await Permission.location.request();

                            if (locationStatus == PermissionStatus.granted) {
                              _takeLocationInput();
                            }
                          },
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            )),
                        child: GestureDetector(
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Colors.lightGreen,
                          ),
                          onTap: () async {
                            _audioPicker();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  _mediaOptions(ChatMessageTypes type) {
    showDialog(
        context: context,
        builder: (_) => SimpleDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0.3,
              backgroundColor: AppColors.black,
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    if (type == ChatMessageTypes.image) {
                      _imagePicker(ImageSource.camera);
                    } else if (type == ChatMessageTypes.video) {
                      _videoPickerPicker(ImageSource.camera);
                    } else if (type == ChatMessageTypes.audio) {
                      _audioPicker();
                    }
                  },
                  child: Text(
                    'Camera',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    if (type == ChatMessageTypes.image) {
                      _imagePicker(ImageSource.gallery);
                    } else if (type == ChatMessageTypes.video) {
                      _videoPickerPicker(ImageSource.gallery);
                    } else if (type == ChatMessageTypes.audio) {
                      _audioPicker();
                    }
                  },
                  child: const Text(
                    'Gallery',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }

  void _imagePicker(ImageSource source) async {
    final pickedImage =
        await ImagePicker().pickImage(source: source, imageQuality: 70);

    if (pickedImage != null) {
      final currentTime = '${DateTime.now().hour}:${DateTime.now().minute}';

      model = ChatMessageModel(
        message: pickedImage.path,
        time: currentTime,
        typeOfMessage: ChatMessageTypes.image.toString(),
        recievedMessage: true,
        fileName: null,
        thumbnailPath: null,
        date: DateTime.now().toString(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pop(context);
        BlocProvider.of<UserDetailBloc>(context).add(
            UploadFileToFirebaseStorageEvent(
                filePath: File(pickedImage.path), reference: 'chatImage/'));
      }
    }

    setState(() {});
  }

  void _videoPickerPicker(ImageSource source) async {
    final pickedVideo = await ImagePicker()
        .pickVideo(source: source, maxDuration: Duration(seconds: 15));

    if (pickedVideo != null) {
      final currentTime = '${DateTime.now().hour}:${DateTime.now().minute}';
      final String? imagePath = await VideoThumbnail.thumbnailFile(
        video: pickedVideo.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth:
            128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 100,
      );

      model = ChatMessageModel(
        message: pickedVideo.path,
        time: currentTime,
        thumbnailPath: imagePath,
        typeOfMessage: ChatMessageTypes.video.toString(),
        recievedMessage: false,
        fileName: null,
        date: DateTime.now().toString(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pop(context);

        BlocProvider.of<UserDetailBloc>(context).add(
          UploadFileToFirebaseStorageEvent(
              filePath: File(pickedVideo.path), reference: 'chatVideo/'),
        );
      }
    }

    setState(() {});
  }

  void _audioPicker() async {
    // final List<String> allowedExtensions = ['mp3', 'm4a', 'wav', 'aac'];
    final FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles(
      // allowedExtensions: _allowedExtensions,
      type: FileType.audio,
    );

    if (mounted) {
      if (filePickerResult != null) {
        Navigator.of(context).pop();
        // Navigator.of(context).pop();

        _iconData = Icons.play_arrow_rounded;
        filePickerResult.files.map((e) {
          // if (allowedExtensions.contains(e.extension)) {
          _sendAudio(e.path.toString(),
              extension: e.extension, fileName: e.name.toString());
          //}
        }).toList();
      }
    }
  }

  void _sendAudio(path, {extension, fileName}) async {
    await player.stop();
    setState(() {
      _iconData = Icons.play_arrow_rounded;
    });

    await player.setFilePath(path);
    if (player.duration!.inMinutes > 15) {
      showToast(
          fToast: fToast,
          message: 'Audio should not be gretater tha 15 mins',
          backgroundColor: AppColors.logout);
    } else {
      final currentTime = '${DateTime.now().hour}:${DateTime.now().minute}';

      model = ChatMessageModel(
        message: path,
        time: currentTime,
        typeOfMessage: ChatMessageTypes.audio.toString(),
        recievedMessage: true,
        fileName: fileName,
        thumbnailPath: null,
        date: DateTime.now().toString(),
      );

      if (mounted) {
        BlocProvider.of<UserDetailBloc>(context).add(
          UploadFileToFirebaseStorageEvent(
              filePath: File(path), reference: 'chatAudio/'),
        );
      }
    }
  }

  Widget _textConversation(index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: (_allMessages[index].messageHolder == widget.partnerUsername)
              ? EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 3,
                  left: 5.0,
                  top: 10,
                  bottom: 10)
              : EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 3,
                  right: 5.0,
                  top: 10,
                  bottom: 10),
          alignment: _allMessages[index].messageHolder == widget.partnerUsername
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary:
                  _allMessages[index].messageHolder == widget.partnerUsername
                      ? AppColors.iconColor1
                      : AppColors.backgroundColor9,
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: _allMessages[index].messageHolder ==
                          widget.partnerUsername
                      ? Radius.circular(0.0)
                      : Radius.circular(20.0),
                  topRight: _allMessages[index].messageHolder ==
                          widget.partnerUsername
                      ? Radius.circular(20.0)
                      : Radius.circular(0.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
            child: Text(
              _allMessages[index].message,
              style: TextStyle(fontSize: 16.0, color: AppColors.white),
            ),
            onPressed: () {},
            onLongPress: () {},
          ),
        ),
        Container(
          alignment: _allMessages[index].messageHolder == widget.partnerUsername
              ? Alignment.centerLeft
              : Alignment.centerRight,
          margin: _allMessages[index].messageHolder == widget.partnerUsername
              ? const EdgeInsets.only(
                  left: 5.0,
                  bottom: 5.0,
                  top: 5.0,
                )
              : const EdgeInsets.only(
                  right: 5.0,
                  bottom: 5.0,
                  top: 5.0,
                ),
          child: _timeWidget(_allMessages[index].time),
        )
      ],
    );
  }

  Widget _timeWidget(String time) {
    final timeSplit = time.split(':');
    final hour = timeSplit[0].padLeft(2, '0');
    final minutes = timeSplit[1].padLeft(2, '0');

    return Text('$hour:$minutes ',
        style: TextStyle(
            color: AppColors.textColor2,
            overflow: TextOverflow.ellipsis,
            fontSize: 14,
            fontWeight: FontWeight.w600));
  }

  Widget _mediaConversation(index) {
    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            margin: _allMessages[index].messageHolder == widget.partnerUsername
                ? EdgeInsets.only(
                    right: MediaQuery.of(context).size.width / 3,
                    left: 5.0,
                    top: 30.0,
                  )
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 3,
                    right: 5.0,
                    top: 15.0,
                  ),
            alignment:
                _allMessages[index].messageHolder == widget.partnerUsername
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
            child: OpenContainer(
              openColor: AppColors.backgroundColor1,
              closedColor:
                  _allMessages[index].messageHolder == widget.partnerUsername
                      ? AppColors.backgroundColor1
                      : AppColors.iconColor1,
              middleColor: AppColors.backgroundColor1,
              closedElevation: 0.0,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              transitionDuration: Duration(
                milliseconds: 500,
              ),
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (context, openWidget) {
                return ImageView(
                    imagePath: _allMessages[index].message // image path
                    // imageProviderCategory: ImageProvider.FileImage,
                    );
              },
              closedBuilder: (context, closedWidget) {
                return Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: PhotoView(
                        enableRotation: true,
                        minScale: PhotoViewComputedScale.covered,
                        loadingBuilder: (ctx, event) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorBuilder: (ctx, obj, stackTrace) => Container(
                          alignment: Alignment.center,
                          child: const Text('Could not load image',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                              )),
                        ),
                        imageProvider: _allMessages[index].typeOfMessage ==
                                ChatMessageTypes.image.toString()
                            ? FileImage(
                                File(_allMessages[index].message.toString()))
                            : FileImage(File(
                                _allMessages[index].thumbnailPath.toString())),
                      ),
                    ),
                    if (_allMessages[index].typeOfMessage ==
                        ChatMessageTypes.video.toString())
                      GestureDetector(
                        onTap: () async {
                          final openResult =
                              await OpenFile.open(_allMessages[index].message);
                          _openedFileResult(openResult);
                        },
                        child: Center(
                          child: Icon(Icons.play_arrow_rounded,
                              size: 50,
                              color: AppColors.white,
                              shadows: const [
                                Shadow(color: AppColors.black, blurRadius: 15.0)
                              ]),
                        ),
                      )
                  ],
                );
              },
            )),
        // _conversationMessageTime(
        Container(
          alignment: _allMessages[index].messageHolder == widget.partnerUsername
              ? Alignment.centerLeft
              : Alignment.centerRight,
          margin: _allMessages[index].messageHolder == widget.partnerUsername
              ? const EdgeInsets.only(
                  left: 5.0,
                  bottom: 5.0,
                  top: 5.0,
                )
              : const EdgeInsets.only(
                  right: 5.0,
                  bottom: 5.0,
                  top: 5.0,
                ),
          child: _timeWidget(_allMessages[index].time),
        )
      ],
    );
  }

  _openedFileResult(OpenResult openResult) {
    if (openResult.type == ResultType.permissionDenied) {
      showToast(
          fToast: fToast,
          message: 'Permission not granted',
          toastColor: AppColors.logout,
          fontSize: 16);
    } else if (openResult.type == ResultType.fileNotFound) {
      showToast(
          fToast: fToast,
          message: 'Video not found',
          toastColor: AppColors.logout,
          fontSize: 16);
    } else if (openResult.type == ResultType.noAppToOpen) {
      showToast(
          fToast: fToast,
          message: 'No app to open',
          toastColor: AppColors.logout,
          fontSize: 16);
    } else if (openResult.type == ResultType.error) {
      showToast(
          fToast: fToast,
          message: 'Error in opening file',
          toastColor: AppColors.logout,
          fontSize: 16);
    }
  }

  Future<void> _pickFileFromStorage() async {
    List<String> allowedExtensions = [
      'pdf',
      'doc',
      'docx',
      'ppt',
      'pptx',
      'c',
      'cpp',
      'py',
      'text'
    ];

    try {
      if (!await Permission.storage.isGranted) _takeStoragePermission();

      final FilePickerResult? filePickerResult =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
        filePickerResult.files.map((file) async {
          if (allowedExtensions.contains(file.extension)) {
            final currentTime =
                '${DateTime.now().hour}:${DateTime.now().minute}';
            // _allMessages.add(ChatMessageModel(
            //   message: file.path.toString(),
            //   time: currentTime,
            //   typeOfMessage: ChatMessageTypes.document.toString(),
            //   recievedMessage: false,
            //   fileName: file.path!.split('/').last,
            // ));

            model = ChatMessageModel(
              message: file.path.toString(),
              time: currentTime,
              typeOfMessage: ChatMessageTypes.document.toString(),
              recievedMessage: true,
              fileName: file.path!.split('/').last,
              thumbnailPath: null,
              date: DateTime.now().toString(),
            );

            BlocProvider.of<UserDetailBloc>(context).add(
                UploadFileToFirebaseStorageEvent(
                    filePath: File(file.path.toString()),
                    reference: 'chatDocuments/'));
          }
        }).toList();

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
      showToast(
          fToast: fToast,
          message: 'Something went wrong',
          toastColor: AppColors.logout,
          fontSize: 16);
    }
  }

  Widget _documentConversation(index) {
    return Column(children: [
      Container(
          height: _allMessages[index].message.contains('.pdf') ? 250 : 100,
          margin: _allMessages[index].messageHolder == widget.partnerUsername
              ? EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 3,
                  left: 5.0,
                  top: 30.0,
                )
              : EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 3,
                  right: 5.0,
                  top: 15.0,
                ),
          alignment: _allMessages[index].messageHolder == widget.partnerUsername
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                shape: BoxShape.rectangle,
                color: _allMessages[index].message.contains('.pdf')
                    ? AppColors.white
                    : _allMessages[index].messageHolder ==
                            widget.partnerUsername
                        ? AppColors.textColor2
                        : AppColors.textColor4),
            child: _allMessages[index].message.contains('.pdf')
                ? Stack(
                    children: [
                      Center(
                        child: Text(
                          'Unable to load PDF',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: PdfView(path: _allMessages[index].message),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final OpenResult openResult =
                              await OpenFile.open(_allMessages[index].message);
                          _openedFileResult(openResult);
                        },
                        child: Center(
                          child: Icon(
                            Icons.open_in_new_off_rounded,
                            color: AppColors.backgroundColor4,
                            size: 30,
                          ),
                        ),
                      )
                    ],
                  )
                : GestureDetector(
                    onTap: () async {
                      final OpenResult openResult =
                          await OpenFile.open(_allMessages[index].message);
                      _openedFileResult(openResult);
                    },
                    child: Row(children: [
                      SizedBox(
                        width: 15,
                      ),
                      Icon(
                        Icons.file_open_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(
                          _allMessages[index].fileName.toString(),
                          style:
                              TextStyle(fontSize: 16.0, color: AppColors.white),
                        ),
                      )
                    ]),
                  ),
          )),
      Container(
        alignment: _allMessages[index].messageHolder == widget.partnerUsername
            ? Alignment.centerLeft
            : Alignment.centerRight,
        margin: _allMessages[index].messageHolder == widget.partnerUsername
            ? const EdgeInsets.only(
                left: 5.0,
                bottom: 5.0,
                top: 5.0,
              )
            : const EdgeInsets.only(
                right: 5.0,
                bottom: 5.0,
                top: 5.0,
              ),
        child: _timeWidget(_allMessages[index].time),
      )
    ]);
  }

  void _takeLocationInput() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      final Marker marker = Marker(
          markerId: MarkerId('location'),
          zIndex: 2,
          draggable: true,
          position: LatLng(position.latitude, position.longitude));

      final currentTime = '${DateTime.now().hour}:${DateTime.now().minute}';

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                backgroundColor: Colors.transparent,
                actions: [
                  FloatingActionButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        // _allMessages.add(ChatMessageModel(
                        //     message:
                        //         '${position.latitude}:${position.longitude}',
                        //     recievedMessage: false,
                        //     time: currentTime,
                        //     typeOfMessage:
                        //         ChatMessageTypes.location.toString()));
                        // setState(() {});
                        model = ChatMessageModel(
                          message: '${position.latitude}:${position.longitude}',
                          time: currentTime,
                          typeOfMessage: ChatMessageTypes.location.toString(),
                          recievedMessage: true,
                          fileName: null,
                          thumbnailPath: null,
                          date: DateTime.now().toString(),
                        );

                        BlocProvider.of<UserDetailBloc>(context).add(
                            SendChatMessageEvent(
                                model: model!,
                                username: widget.partnerUsername));
                      }
                    },
                    child: Icon(
                      Icons.send_rounded,
                      // color: AppColors.white,
                    ),
                  )
                ],
                content: FittedBox(
                    child: Container(
                  width: dimensions[1],
                  height: dimensions[0],
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(color: AppColors.borderColor1)),
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    markers: {marker},
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                          position.latitude,
                          position.longitude,
                        ),
                        zoom: 20),
                  ),
                )),
              ));
    } catch (e) {
      foundation.debugPrint(e.toString());
    }
  }

  Widget _locationConversation(index) {
    return Column(children: [
      Container(
          height: 250,
          margin: _allMessages[index].messageHolder == widget.partnerUsername
              ? EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 3,
                  left: 5.0,
                  top: 30.0,
                )
              : EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 3,
                  right: 5.0,
                  top: 15.0,
                ),
          alignment: _allMessages[index].messageHolder == widget.partnerUsername
              ? Alignment.centerLeft
              : Alignment.centerRight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft:
                  _allMessages[index].messageHolder == widget.partnerUsername
                      ? Radius.circular(0.0)
                      : Radius.circular(20.0),
              topRight:
                  _allMessages[index].messageHolder == widget.partnerUsername
                      ? Radius.circular(20.0)
                      : Radius.circular(0.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
            color: _allMessages[index].messageHolder == widget.partnerUsername
                ? AppColors.textColor2
                : AppColors.textColor4,
          ),
          child: GoogleMap(
            mapType: MapType.hybrid,
            markers: {
              Marker(
                  markerId: MarkerId('location'),
                  zIndex: 2,
                  draggable: true,
                  position: LatLng(
                    double.parse(_allMessages[index].message.split(':').first),
                    double.parse(_allMessages[index].message.split(':').last),
                  ))
            },
            initialCameraPosition: CameraPosition(
                target: LatLng(
                  double.parse(_allMessages[index].message.split(':').first),
                  double.parse(_allMessages[index].message.split(':').last),
                ),
                zoom: 20),
          )),
      Container(
        alignment: _allMessages[index].messageHolder == widget.partnerUsername
            ? Alignment.centerLeft
            : Alignment.centerRight,
        margin: _allMessages[index].messageHolder == widget.partnerUsername
            ? const EdgeInsets.only(
                left: 5.0,
                bottom: 5.0,
                top: 5.0,
              )
            : const EdgeInsets.only(
                right: 5.0,
                bottom: 5.0,
                top: 5.0,
              ),
        child: _timeWidget(_allMessages[index].time),
      )
    ]);
  }

  Widget _audioConversation(index) {
    return Column(children: [
      Container(
          // color: AppColors.black,
          // height: 150,
          margin: _allMessages[index].messageHolder == widget.partnerUsername
              ? EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 3,
                  left: 5.0,
                  top: 30.0,
                )
              : EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 3,
                  right: 5.0,
                  top: 15.0,
                ),
          alignment: _allMessages[index].messageHolder == widget.partnerUsername
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.all(5),
            height: 100,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft:
                    _allMessages[index].messageHolder == widget.partnerUsername
                        ? Radius.circular(0.0)
                        : Radius.circular(20.0),
                topRight:
                    _allMessages[index].messageHolder == widget.partnerUsername
                        ? Radius.circular(20.0)
                        : Radius.circular(0.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              color: _allMessages[index].messageHolder == widget.partnerUsername
                  ? AppColors.textColor2
                  : AppColors.textColor4,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    _allMessages[index].message.toString().split('/').last,
                    style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                Row(children: [
                  GestureDetector(
                    onTap: () => chatAudioOnTap(index),
                    onLongPress: () => chatAudioOnLonTap(index),
                    child: Icon(
                      index == currentAudioIndex
                          ? _iconData
                          : Icons.play_arrow_rounded,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 26.0,
                            ),
                            child: LinearPercentIndicator(
                              percent: player.duration == null
                                  ? 0.0
                                  : currentAudioIndex == index
                                      ? currAudioPlayingTime! /
                                                  player
                                                      .duration!.inMicroseconds
                                                      .ceilToDouble() <=
                                              1.0
                                          ? currAudioPlayingTime! /
                                              player.duration!.inMicroseconds
                                                  .ceilToDouble()
                                          : 0.0
                                      : 0,
                              backgroundColor: Colors.black26,
                              progressColor:
                                  _allMessages[index].messageHolder ==
                                          widget.partnerUsername
                                      ? AppColors.backgroundColor4
                                      : AppColors.borderColor1,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 7.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      currentAudioIndex == index
                                          ? loadingTime
                                          : '0:00',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      currentAudioIndex == index
                                          ? totalDuration
                                          : '',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          )),
      Container(
        alignment: _allMessages[index].messageHolder == widget.partnerUsername
            ? Alignment.centerLeft
            : Alignment.centerRight,
        margin: _allMessages[index].messageHolder == widget.partnerUsername
            ? const EdgeInsets.only(
                left: 5.0,
                bottom: 5.0,
                top: 5.0,
              )
            : const EdgeInsets.only(
                right: 5.0,
                bottom: 5.0,
                top: 5.0,
              ),
        child: _timeWidget(_allMessages[index].time),
      )
    ]);
  }

  void chatAudioOnTap(index) async {
    if (mounted) {
      try {
        player.positionStream.listen((event) {
          setState(() {
            currAudioPlayingTime = event.inMicroseconds.ceilToDouble();
            loadingTime =
                '${event.inMinutes} : ${event.inSeconds > 59 ? event.inSeconds % 60 : event.inSeconds} ';
          });
        });

        player.playerStateStream.listen((event) async {
          if (event.processingState == ProcessingState.completed) {
            await player.stop();
            setState(() {
              loadingTime = '0.00';
              _iconData = Icons.play_arrow_rounded;
            });
          }
        });

        if (currentAudioIndex != index) {
          await player.setFilePath(_allMessages[index].message);

          setState(() {
            currentAudioIndex = index;
            totalDuration =
                '${player.duration!.inMinutes} : ${player.duration!.inSeconds > 59 ? player.duration!.inSeconds % 60 : player.duration!.inSeconds}';
            _iconData = Icons.pause;
            audioPlayingSpeed = 1.0;
            player.setSpeed(audioPlayingSpeed);
          });

          await player.play();
        } else {
          if (player.processingState == ProcessingState.idle) {
            await player.setFilePath(_allMessages[index].message);

            setState(() {
              currentAudioIndex = index;
              totalDuration =
                  '${player.duration!.inMinutes} : ${player.duration!.inSeconds}';
              _iconData = Icons.pause;
            });

            await player.play();
          } else if (player.playing) {
            setState(() {
              _iconData = Icons.play_arrow_rounded;
            });
            await player.pause();
          } else if (player.processingState == ProcessingState.ready) {
            setState(() {
              _iconData = Icons.pause;
            });
            await player.play();
          } else if (player.processingState == ProcessingState.completed) {
            setState(() {
              _iconData = Icons.play_arrow_rounded;
            });
            player.stop();
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void chatAudioOnLonTap(index) async {
    if (player.playing && index == currentAudioIndex) {
      await player.stop();

      setState(() {
        loadingTime = '0:00';
        _iconData = Icons.play_arrow_rounded;
        currentAudioIndex = -1;
      });
    }
  }

  void _audioRecording() async {
    bool? result = await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.transparent,
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              // actions: [
              //   FloatingActionButton(
              //     onPressed: () {
              //       if (mounted) {
              //         _recordVoice();
              //       }
              //     },
              //     child: Icon(
              //       Icons.send_rounded,
              //       // color: AppColors.white,
              //     ),
              //   ),
              //   FloatingActionButton(
              //     onPressed: () {
              //       if (mounted) {
              //         Navigator.of(context).pop();
              //         player.stop();
              //       }
              //     },
              //     child: Icon(
              //       Icons.cancel_rounded,
              //       // color: AppColors.white,
              //     ),
              //   )
              // ],
              content: AvatarGlow(
                endRadius: 70.0,
                child: Column(
                  children: [
                    Text(
                      'Recording...',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      radius: 30.0,
                      child: IconButton(
                        icon: Icon(Icons.keyboard_voice_rounded),
                        onPressed: () {
                          if (mounted) {
                            Navigator.of(context).pop(true);
                          }
                          _recordVoice();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ));

    if (result == null) {
      await record.stop();
    }
  }

  void _recordVoice() async {
    final PermissionStatus microphoneStatus;
    if (!await Permission.microphone.status.isGranted) {
      microphoneStatus = await Permission.microphone.request();
    } else {
      microphoneStatus = PermissionStatus.granted;
    }

    if (microphoneStatus == PermissionStatus.granted) {
      if (await record.isRecording()) {
        final String? recordedFilePath = await record.stop();

        _sendAudio(recordedFilePath,
            fileName: recordedFilePath!.split('/').last);
      } else {
        await record.start(
            path: '${audioDirectory!.path}${DateTime.now()}.aac');
      }
    }
  }
}
