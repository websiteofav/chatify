// ignore_for_file: prefer_const_constructors

import 'package:animations/animations.dart';
import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
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
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/widgets/overlay_loader.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _localDB = HomeRepository();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final UserRepository repository = UserRepository();

  final List<Widget> homePages = const <Widget>[
    ChatList(
      key: PageStorageKey<String>('chat'),
    ),
    UserCalls(
      key: PageStorageKey<String>('call'),
    ),
    Profile(
      key: PageStorageKey<String>('profile'),
    ),
  ];

  final LoadingOverlay _loadingOverlay = LoadingOverlay();

  @override
  void initState() {
    _loadingOverlay.hide();
    super.initState();
  }

  Future<bool> startTime() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? firstTime = prefs.getBool('first_time');

      if (firstTime == null) {
        final data = await repository.getCurrentUserData(
            email: FirebaseAuth.instance.currentUser!.email);

        final UserDetailsModel firebaseModel = UserDetailsModel.fromJson(data);
        await _localDB.createimportantUserDB();

        UserPrimaryModel model = UserPrimaryModel(
          userName: firebaseModel.userName,
          email: firebaseModel.email.toString(),
          mobileNumber: firebaseModel.mobileNumber,
          notifications: '',
          profileImagePath: firebaseModel.profilePic,
          profileImageURL: firebaseModel.profilePic,
          bio: firebaseModel.bio,
          wallpaper: '',
        );

        await _localDB.insertOrUpdateImportantUserDB(model);

        await _localDB.createSecondarytUserDB(username: firebaseModel.userName);
        //  await _localDB.insertOrUpdateSecondaryUserDB(model)

        prefs.setBool('first_time', false);

        return true;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final dimensions = deviceDimensions(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: _appBar(dimensions),
        drawer: _drawer(dimensions),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        bottomNavigationBar: BottomNavigationBar(
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: bottomBarIndex,
          selectedItemColor: Colors.amber[800],
          onTap: (index) => bottomBarTapped(index),
        ),
        backgroundColor: AppColors.backgroundColor1,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is LogoutLoaded) {
              Navigator.popAndPushNamed(context, '/login');
            } else if (state is AuthError) {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                text: state.message,
              );
            }
          },
          child: FutureBuilder<bool>(
              future: startTime(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: ListView(
                      children: [
                        // SizedBox(
                        //   height: 100,
                        // ),

                        bottomBarIndex == 0 ? ChatroomsList() : Container(),

                        PageStorage(
                            bucket: _homeBucket,
                            child: homePages[bottomBarIndex])
                      ],
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.data == false) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Something Went Wromg',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              }),
        ));
  }

  void bottomBarTapped(index) {
    setState(() {
      bottomBarIndex = index;
    });
  }

  PreferredSize _appBar(dimensions) {
    return PreferredSize(
        preferredSize: Size.fromHeight(280),
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
                    onTap: (() => _scaffoldKey.currentState!.openDrawer()),
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
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 15,
                      // top: 43,
                    ),
                    child: FloatingActionButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        if (mounted) {
                          prefs.getString('loginType') == 'email'
                              ? BlocProvider.of<AuthBloc>(context)
                                  .add(LogoutEvent())
                              : BlocProvider.of<AuthBloc>(context)
                                  .add(GoogleSignOutEvent());
                        }
                      },
                      backgroundColor: AppColors.logout,
                      child: const Icon(Icons.logout_rounded, size: 15),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 80,
                      child: TextField(
                        onChanged: null,
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            transitionType: ContainerTransitionType.fadeThrough,
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
          ],
        ));
  }

  Drawer _drawer(dimensions) {
    return Drawer(
      child: Container(
        color: AppColors.backgroundColor1,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 80, 0, 20),
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.textColor1,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('A',
                            style: TextStyle(
                                color: AppColors.black, fontSize: 35)),
                      )),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    'Avinash',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
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
        openBuilder: (context, openWidget) {
          if (menuItem == 'Profile') {
            return Profile();
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
}
