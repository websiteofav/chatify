// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:animations/animations.dart';
import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/auth/screens/login.dart';
import 'package:chat_app/frontend/connections/search_connections.dart';
import 'package:chat_app/frontend/home/bloc/home_bloc.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/home/repository/repository.dart';
import 'package:chat_app/frontend/home/screens/chatrooms.dart';
import 'package:chat_app/frontend/home/screens/chats_list.dart';
import 'package:chat_app/frontend/home/screens/user_calls.dart';
import 'package:chat_app/frontend/menu/about.dart';
import 'package:chat_app/frontend/menu/profile_screen.dart';
import 'package:chat_app/frontend/menu/settings.dart';
import 'package:chat_app/frontend/menu/support.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/show_toast_messages.dart';
import 'package:chat_app/frontend/widgets/overlay_loader.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchEditingController = TextEditingController();
  int bottomBarIndex = 0;
  final PageStorageBucket _homeBucket = PageStorageBucket();

  SharedPreferences? prefs;
  final Dio dio = Dio();

  final FToast fToast = FToast();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final UserRepository repository = UserRepository();

  final List<Widget> homePages = <Widget>[
    MultiBlocProvider(
      providers: [
        BlocProvider(
            lazy: false,
            create: (context) => UserDetailBloc(repository: UserRepository())),
        BlocProvider(
            lazy: false,
            create: (context) => HomeBloc(repository: HomeRepository())),
      ],
      child: ChatList(
        key: PageStorageKey<String>('chat'),
      ),
    ),
    // UserCalls(
    //   key: PageStorageKey<String>('log'),
    // ),

    // Profile(
    //   key: PageStorageKey<String>('profile'),
    // ),
  ];

  final LoadingOverlay _loadingOverlay = LoadingOverlay();

  UserPrimaryModel? userPrimaryModel;

  late UserPrimaryModel firebaseModel;

  @override
  void initState() {
    _loadingOverlay.hide();
    startTime();

    super.initState();
  }

  Future<void> startTime() async {
    try {
      prefs = await SharedPreferences.getInstance();

      bool? firstTime = prefs!.getBool('first_time');

      if (firstTime == null && mounted) {
        BlocProvider.of<UserDetailBloc>(context).add(
          FetchUserDataEvent(
              email: FirebaseAuth.instance.currentUser!.email.toString(),
              parse: true),
        );

        // await _localDB.createSecondarytUserDB(username: firebaseModel.userName);

      } else {
        if (mounted) {
          BlocProvider.of<HomeBloc>(context).add(
            FetchUserPrimaryDataEvent(),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final dimensions = deviceDimensions(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: _appBar(dimensions),
        drawer: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (userPrimaryModel == null) {
              return Container();
            }
            return _drawer(dimensions);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        bottomNavigationBar: SizedBox(
          height: 80,
          child: BottomNavigationBar(
            selectedFontSize: 22,
            backgroundColor: AppColors.backgroundColor2,
            unselectedItemColor: AppColors.bottomBarColor1,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner),
                label: 'Logs',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.person),
              //   label: 'Profile',
              // ),
            ],
            currentIndex: bottomBarIndex,
            selectedItemColor: Colors.amber[800],
            onTap: (index) => bottomBarTapped(index),
          ),
        ),
        backgroundColor: AppColors.backgroundColor1,
        body: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) async {
              if (state is UserPrimaryDataFetched) {
                prefs!.setBool('first_time',
                    false); // No need to wait as it will get initialized before next login

                userPrimaryModel = state.model;
              } else if (state is UserPrimaryDetailsLoaded) {
                prefs!.setBool('first_time', false);

                userPrimaryModel = state.model;
              }

              if (state is UserPrimaryTableLoaded) {
                // _loadingOverlay.hide();

                BlocProvider.of<HomeBloc>(context)
                    .add(AddPrimaryDataEvent(model: firebaseModel));
              }
            },
            child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is LogoutLoaded) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  } else if (state is AuthError) {
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.error,
                      text: state.message,
                    );
                  }
                },
                child: BlocListener<UserDetailBloc, UserDetailState>(
                  listener: (context, state) {
                    if (state is CurrentUserDataFetched) {
                      _getProfileImage(state.model);
                    }
                  },
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (userPrimaryModel != null) {
                        return ListView(
                          children: [
                            // SizedBox(
                            //   height: 100,
                            // ),

                            // bottomBarIndex == 0 ? ChatroomsList() : Container(),

                            PageStorage(
                                bucket: _homeBucket,
                                child: homePages[bottomBarIndex])
                          ],
                        );
                      } else if (state is UserPrimaryDataFetchedFailed) {
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            state.message,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ))));
  }

  void bottomBarTapped(index) {
    // setState(() {
    //   bottomBarIndex = index;

    // });
    if (index == 1) {
      fToast.init(context);

      showToast(
          fToast: fToast,
          message: 'Coming Soon',
          toastColor: AppColors.bancgroundColor1,
          fontSize: 16,
          toastGravity: ToastGravity.values[1]);
    }
  }

  PreferredSize _appBar(dimensions) {
    return PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor1,
                    blurRadius: 5.0,
                  ),
                ],
                color: AppColors.backgroundColor2,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
              ),
              height: 150,
              width: dimensions[1],
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (() => userPrimaryModel == null
                        ? null
                        : _scaffoldKey.currentState!.openDrawer()),
                    child: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    'Chatify',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                  // Spacer(),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     right: 15,
                  //     // top: 43,
                  //   ),
                  //   child: FloatingActionButton(
                  //     onPressed: () async {
                  //       SharedPreferences prefs =
                  //           await SharedPreferences.getInstance();
                  //       if (mounted) {
                  //         prefs.getString('loginType') == 'email'
                  //             ? BlocProvider.of<AuthBloc>(context)
                  //                 .add(LogoutEvent())
                  //             : BlocProvider.of<AuthBloc>(context)
                  //                 .add(GoogleSignOutEvent());
                  //       }
                  //     },
                  //     backgroundColor: AppColors.logout,
                  //     child: const Icon(Icons.logout_rounded, size: 15),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ));
  }

  Drawer _drawer(
    dimensions,
  ) {
    return Drawer(
      child: Container(
        color: AppColors.backgroundColor1,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 80, 0, 20),
              child: Row(
                children: [
                  userPrimaryModel!.profileImagePath.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.textColor1,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.white,
                            size: 25,
                          ))
                      : BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            if (state is UserPrimaryDataFetched) {
                              return CircleAvatar(
                                radius: 25,
                                backgroundImage: Image.file(
                                  File(state.model.profileImagePath),
                                  fit: BoxFit.cover,
                                ).image,
                              );
                            } else {
                              return CircleAvatar(
                                radius: 25,
                                backgroundImage: Image.file(
                                  File(userPrimaryModel!.profileImagePath),
                                  fit: BoxFit.cover,
                                ).image,
                              );
                            }
                          },
                        ),
                  SizedBox(
                    width: 12,
                  ),
                  Flexible(
                    child: Text(
                      userPrimaryModel!.userName!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.visible),
                    ),
                  ),
                ],
              ),
            ),
            _menuOptions(Icons.person_outline_rounded, 'Profile'),
            _menuOptions(Icons.support_agent_rounded, 'Support'),
            _menuOptions(Icons.settings_accessibility_rounded, 'Settings'),
            _menuOptions(Icons.info_outline_rounded, 'About'),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 15, bottom: 20),
                alignment: Alignment.bottomLeft,
                child: Text(
                  '1.0.0',
                  style: TextStyle(fontSize: 15, color: AppColors.textColor2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuOptions(IconData icon, menuItem) {
    return OpenContainer(
        openColor: AppColors.backgroundColor1,
        closedColor: AppColors.backgroundColor1,
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: Duration(milliseconds: 500),
        openElevation: 15,
        onClosed: (value) {
          BlocProvider.of<HomeBloc>(context).add(
            FetchUserPrimaryDataEvent(),
          );
        },
        openBuilder: (context, openWidget) {
          if (menuItem == 'Profile') {
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
              child: Profile(
                userPrimaryModel: userPrimaryModel!,
              ),
            );
          } else if (menuItem == "Support") {
            return Support();
          } else if (menuItem == "Settings") {
            return Settings();
          } else if (menuItem == "About") {
            return About();
          }
          return Container(
            height: 50,
          );
        },
        closedBuilder: (context, closedWidget) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 0, 15),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.backgroundColor4,
                  size: 25,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  menuItem,
                  style: TextStyle(color: AppColors.shadowColor1, fontSize: 25),
                )
              ],
            ),
          );
        });
  }

  void _getProfileImage(UserDetailsModel userDetailsModel) async {
    String imageSroragePath = '';
    try {
      if (userDetailsModel.profilePic.isNotEmpty) {
        final Directory? directory = await getExternalStorageDirectory();

        final audioStorage =
            await Directory("${directory!.path}/profilePic").create();
        imageSroragePath =
            "${audioStorage.path}${DateTime.now().toString().split(" ").join("")}.png";

        await dio.download(userDetailsModel.profilePic, imageSroragePath);
      }
      firebaseModel = UserPrimaryModel(
          userName: userDetailsModel.userName,
          email: userDetailsModel.email.toString(),
          mobileNumber: userDetailsModel.mobileNumber,
          notifications: '',
          profileImagePath: imageSroragePath,
          profileImageURL: userDetailsModel.profilePic,
          bio: userDetailsModel.bio,
          wallpaper: '',
          accountCreationDate: userDetailsModel.accountCreationDate,
          accountCreationTime: userDetailsModel.accountCreationTime,
          token: userDetailsModel.token);
      BlocProvider.of<HomeBloc>(context).add(const CreatePrimaryTableEvent());
    } catch (e) {
      debugPrint(e.toString());
      BlocProvider.of<HomeBloc>(context).add(const CreatePrimaryTableEvent());
    }
  }
}
