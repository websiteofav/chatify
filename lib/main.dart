import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/auth/repository/repository.dart';
import 'package:chat_app/frontend/auth/screens/login.dart';
import 'package:chat_app/frontend/auth/screens/signup.dart';
import 'package:chat_app/frontend/auth/screens/splash.dart';
import 'package:chat_app/frontend/home/screens/homepage.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:chat_app/frontend/user_detail/screens/user_detail.dart';
import 'package:chat_app/frontend/widgets/overlay_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LoadingOverlay _overlay = LoadingOverlay();

  @override
  void initState() {}

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            repository: AuthRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => UserDetailBloc(
            repository: UserRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).sio
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const Splash(),
        routes: {
          '/login': (context) => const Login(),
          '/signup': (context) => const SignUp(),
          '/home': (context) => const HomePage(),
          '/userDetail': (context) => const UserDetail()
        },
      ),
    );
  }
}
