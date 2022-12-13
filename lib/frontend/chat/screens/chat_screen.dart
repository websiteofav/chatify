// ignore_for_file: prefer_const_constructors

import 'package:chat_app/frontend/chat/models/chat_model.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:circle_list/circle_list.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // _controller.addListener(() {
    //   if()
    // });
    super.initState();
  }

  final List<ChatMessageModel> _allMessages = [
    ChatMessageModel(message: 'Abc', time: '12:20pm'),
    ChatMessageModel(message: 'def', time: '1:20pm'),
    ChatMessageModel(message: 'ghi', time: '2:20pm'),
  ];

  final List<ChatMessageTypes> _chatMessageType = [
    ChatMessageTypes.text,
    ChatMessageTypes.text,
    ChatMessageTypes.text
  ];
  List<bool> _messageHolder = [true, false, false];

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final dimensions = deviceDimensions(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
              const Text(
                'Shivam',
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
        body: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height:
                  dimensions[0] - 130 - MediaQuery.of(context).padding.bottom,
              child: ListView.builder(
                  // physics: NeverScrollableScrollPhysics(),
                  controller: _controller,
                  itemCount: _allMessages.length,
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) {
                    if (_chatMessageType[index] == ChatMessageTypes.text) {
                      return _textConversation(index);
                    } else if (_chatMessageType[index] ==
                        ChatMessageTypes.image) {
                      return _imageConversation(index);
                    }

                    return Container();
                  }),
            ),
            _messageBottomSheet()
          ],
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
            onPressed: null,
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
              controller: _textEditingController,
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
                          final currentTime =
                              '${DateTime.now().hour}:${DateTime.now().minute}';
                          final ChatMessageModel model = ChatMessageModel(
                              message: _textEditingController.text,
                              time: currentTime);
                          _allMessages.add(model);
                          _messageHolder.add(false);
                          _textEditingController.clear();
                          _chatMessageType.add(ChatMessageTypes.text);
                        });
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
                          onTap: () async {
                            // final pickedImage = await ImagePicker().pickImage(
                            //     source: ImageSource.camera, imageQuality: 50);
                            // if (pickedImage != null) {
                            //   _addSelectedMediaToChat(pickedImage.path);
                            // }
                          },
                          onLongPress: () async {
                            // final XFile? pickedImage = await ImagePicker()
                            //     .pickImage(
                            //         source: ImageSource.gallery,
                            //         imageQuality: 50);
                            // if (pickedImage != null) {
                            //   _addSelectedMediaToChat(pickedImage.path);
                            // }
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
                          onTap: () async {
                            // final pickedVideo = await ImagePicker().pickVideo(
                            //     source: ImageSource.camera,
                            //     maxDuration: Duration(seconds: 15));

                            // if (pickedVideo != null) {
                            //   final String thumbnailPathTake =
                            //       await _nativeCallback.getTheVideoThumbnail(
                            //           videoPath: pickedVideo.path);

                            //   _addSelectedMediaToChat(pickedVideo.path,
                            //       chatMessageTypeTake: ChatMessageTypes.Video,
                            //       thumbnailPath: thumbnailPathTake);
                            // }
                          },
                          onLongPress: () async {
                            // final pickedVideo = await ImagePicker().pickVideo(
                            //     source: ImageSource.gallery,
                            //     maxDuration: Duration(seconds: 15));

                            // if (pickedVideo != null) {
                            //   final String thumbnailPathTake =
                            //       await _nativeCallback.getTheVideoThumbnail(
                            //           videoPath: pickedVideo.path);

                            //   _addSelectedMediaToChat(pickedVideo.path,
                            //       chatMessageTypeTake: ChatMessageTypes.Video,
                            //       thumbnailPath: thumbnailPathTake);
                            // }
                          },
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
                            // await _pickFileFromStorage();
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
                            // final PermissionStatus locationPermissionStatus =
                            //     await Permission.location.request();
                            // if (locationPermissionStatus ==
                            //     PermissionStatus.granted) {
                            //   await _takeLocationInput();
                            // } else {
                            //   showToast(
                            //       "Location Permission Required", this._fToast);
                            // }
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
                            // final List<String> _allowedExtensions = const [
                            //   'mp3',
                            //   'm4a',
                            //   'wav',
                            //   'ogg',
                            // ];

                            // final FilePickerResult? _audioFilePickerResult =
                            //     await FilePicker.platform.pickFiles(
                            //   type: FileType.audio,
                            // );

                            // Navigator.pop(context);

                            // if (_audioFilePickerResult != null) {
                            //   _audioFilePickerResult.files.forEach((element) {
                            //     print('Name: ${element.path}');
                            //     print('Extension: ${element.extension}');
                            //     if (_allowedExtensions
                            //         .contains(element.extension)) {
                            //       _voiceAndAudioSend(element.path.toString(),
                            //           audioExtension: '.${element.extension}');
                            //     } else {
                            //       _voiceAndAudioSend(element.path.toString());
                            //     }
                            //   });
                            // }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget _textConversation(index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: _messageHolder[index]
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
          alignment: _messageHolder[index]
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: _messageHolder[index]
                  ? AppColors.iconColor1
                  : AppColors.backgroundColor9,
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: _messageHolder[index]
                      ? Radius.circular(0.0)
                      : Radius.circular(20.0),
                  topRight: _messageHolder[index]
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
          alignment: _messageHolder[index]
              ? Alignment.centerLeft
              : Alignment.centerRight,
          margin: _messageHolder[index]
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

  Widget _imageConversation(index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: _messageHolder[index]
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
          alignment: _messageHolder[index]
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: _messageHolder[index]
                  ? AppColors.iconColor1
                  : AppColors.backgroundColor9,
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: _messageHolder[index]
                      ? Radius.circular(0.0)
                      : Radius.circular(20.0),
                  topRight: _messageHolder[index]
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
          alignment: _messageHolder[index]
              ? Alignment.centerLeft
              : Alignment.centerRight,
          margin: _messageHolder[index]
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
}
