import 'dart:io';

import 'package:chat_app/frontend/chat/models/chat_model.dart';
import 'package:chat_app/frontend/home/bloc/home_bloc.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:chat_app/frontend/utils/image_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class Profile extends StatefulWidget {
  UserPrimaryModel userPrimaryModel;
  Profile({Key? key, required this.userPrimaryModel}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Dio dio = Dio();
  late UserPrimaryModel userPrimaryModel;

  String profilePicUrl = '';
  String profileImagePath = '';

  @override
  void initState() {
    BlocProvider.of<HomeBloc>(context).add(
      FetchUserPrimaryDataEvent(),
    );
    profileImagePath = widget.userPrimaryModel.profileImagePath;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = deviceDimensions(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor1,
      appBar: AppBar(
        toolbarHeight: 60,
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
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is UserPrimaryDetailsLoaded) {
            setState(() {
              profileImagePath = state.model.profileImagePath;
            });
          } else if (state is UserPrimaryDataFetched) {
            userPrimaryModel = state.model;
          }
        },
        child: BlocListener<UserDetailBloc, UserDetailState>(
          listener: (context, state) {
            if (state is FileUploadedToStorage) {
              profilePicUrl = state.downloadUrl;
              BlocProvider.of<UserDetailBloc>(context)
                  .add(UpdateProfileImageUrlEvent(downloadUrl: profilePicUrl));
            } else if (state is UpdateProfileImage) {
              _updateUserPic();
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is UserPrimaryDataFetchedFailed) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                    ),
                  ),
                );
              } else {
                return WillPopScope(
                  onWillPop: () async {
                    Navigator.pop(context);
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: dimensions[0] * 0.4,
                          child: Stack(children: [
                            Positioned(
                              // height: 300,
                              // width: 200,
                              height: dimensions[0] * 0.3,
                              width: dimensions[1],
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    colorFilter: ColorFilter.mode(
                                        AppColors.backgroundColor6,
                                        BlendMode.dstATop),
                                    image: const AssetImage(
                                        ImagePaths.coverBackground),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            profileImagePath.isEmpty
                                ? Positioned.fill(
                                    top: dimensions[0] * 0.25,
                                    child: InkWell(
                                      onLongPress: () => _imagePicker(),
                                      child: Container(
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            color: AppColors.white,
                                            size: 40,
                                          )),
                                    ))
                                : Positioned(
                                    left: dimensions[1] * 0.4,
                                    height: dimensions[0] * 0.1,
                                    width: dimensions[1] * 0.2,
                                    top: dimensions[0] * 0.25,
                                    child: InkWell(
                                      onTap: () async =>
                                          await OpenFile.open(profileImagePath),
                                      onLongPress: () => _imagePicker(),
                                      child: CircleAvatar(
                                        backgroundImage: FileImage(
                                          File(
                                            profileImagePath,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ]),
                        ),
                        const Text(
                          '* Long press on the pic to change your profile picture',
                          style:
                              TextStyle(color: AppColors.white, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          '* To logout of account, please clear data from app settings.',
                          style:
                              TextStyle(color: AppColors.white, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: dimensions[1],
                          child: ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                height: 100,
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowColor1,
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Text(
                                      'Username :',
                                      style: TextStyle(
                                          color: AppColors.backgroundColor2,
                                          fontSize: 20),
                                    ),
                                    Text(
                                        widget.userPrimaryModel.userName
                                            .toString(),
                                        style: const TextStyle(
                                            color: AppColors.logout,
                                            fontSize: 25))
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                height: 100,
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowColor1,
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Text(
                                      'Bio : ',
                                      style: TextStyle(
                                          color: AppColors.backgroundColor2,
                                          fontSize: 20),
                                    ),
                                    Flexible(
                                      child: Text(
                                          widget.userPrimaryModel.bio
                                              .toString(),
                                          overflow: TextOverflow.visible,
                                          style: const TextStyle(
                                              color: AppColors.logout,
                                              fontSize: 18)),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                height: 100,
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowColor1,
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Text(
                                      'Date Joined :',
                                      style: TextStyle(
                                          color: AppColors.backgroundColor2,
                                          fontSize: 20),
                                    ),
                                    Text(
                                        widget.userPrimaryModel
                                            .accountCreationDate!,
                                        style: const TextStyle(
                                            color: AppColors.logout,
                                            fontSize: 18))
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   height: 20,
                              // ),
                              // Container(
                              //   decoration: const BoxDecoration(
                              //     borderRadius: BorderRadius.all(
                              //       Radius.circular(40),
                              //     ),
                              //   ),
                              //   width: dimensions[1] * 0.8,
                              //   child: ElevatedButton(
                              //     onPressed: null,
                              //     style: ButtonStyle(
                              //         backgroundColor:
                              //             MaterialStateProperty.all(
                              //                 AppColors.logout)),
                              //     child: const Text(
                              //       'Delete My Account',
                              //       style: TextStyle(
                              //           color: Colors.white, fontSize: 18),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _updateUserPic() async {
    final Directory? directory = await getExternalStorageDirectory();

    final audioStorage =
        await Directory("${directory!.path}/profilePic").create();
    final String imageSroragePath =
        "${audioStorage.path}${DateTime.now().toString().split(" ").join("")}.png";

    await dio.download(profilePicUrl, imageSroragePath);

    final UserPrimaryModel updatedPrimaryModel = UserPrimaryModel(
      email: widget.userPrimaryModel.email,
      notifications: widget.userPrimaryModel.notifications,
      profileImagePath: imageSroragePath,
      profileImageURL: profilePicUrl,
      wallpaper: widget.userPrimaryModel.wallpaper,
      mobileNumber: widget.userPrimaryModel.mobileNumber,
      accountCreationDate: widget.userPrimaryModel.accountCreationDate,
      accountCreationTime: widget.userPrimaryModel.accountCreationTime,
      bio: widget.userPrimaryModel.bio,
      token: widget.userPrimaryModel.token,
      userName: widget.userPrimaryModel.userName,
    );

    if (mounted) {
      BlocProvider.of<HomeBloc>(context)
          .add(AddPrimaryDataEvent(model: updatedPrimaryModel));
    }
  }

  void _imagePicker() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedImage != null) {
      if (mounted) {
        BlocProvider.of<UserDetailBloc>(context).add(
            UploadFileToFirebaseStorageEvent(
                filePath: File(pickedImage.path),
                reference: 'userProfilePic/'));

        // BlocProvider.of<UserDetailBloc>(context).add(
        //     UploadFileToFirebaseStorageEvent(
        //         filePath: File(pickedImage.path), reference: 'chatImage/'));
      }
    }
  }
}
