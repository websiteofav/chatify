import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/auth/repository/repository.dart';
import 'package:chat_app/frontend/auth/screens/signup.dart';
import 'package:chat_app/frontend/home/screens/homepage.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:chat_app/frontend/user_detail/screens/user_detail.dart';
import 'package:chat_app/frontend/utils/image_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    BlocProvider.of<UserDetailBloc>(context).add(
      const UserRecordEvent(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserDetailBloc, UserDetailState>(
      listener: (context, state) {
        if (state is UserDetalsExists) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else if (state is UserDetailError) {
          if (state.message.contains('user')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUp(),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext buildContext) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            lazy: false,
                            create: (context) =>
                                UserDetailBloc(repository: UserRepository())),
                        BlocProvider(
                            lazy: false,
                            create: (context) =>
                                AuthBloc(repository: AuthRepository())),
                      ],
                      child: const UserDetail(),
                    )));
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        body: Center(
          child: Image.asset(ImagePaths.splash),
        ),
      ),
    );
  }
}


     //  BlocListener<UserDetailBloc, UserDetailState>(
          //   listener: (context, state) {
          //     BlocProvider.of<UserDetailBloc>(context).add(
          //       const UserRecordEvent(),
          //     );
          //     if (state is UserDetalsExists) {
          //       Navigator.pushReplacementNamed(context, 'home');
          //     } else if (state is UserDetalsExistsFailed) {
          //       if (state.toString().contains('user')) {
          //         Navigator.pushReplacementNamed(context, 'signup');
          //       } else {
          //         Navigator.pushReplacementNamed(context, 'userDetail');
          //       }
          //     }
          //   },
          // ),