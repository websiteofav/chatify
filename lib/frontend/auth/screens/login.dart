import 'dart:developer';

// import 'package:ecommerce/auth/bloc/auth_bloc.dart';
// import 'package:ecommerce/auth/repository/auth_repository.dart';
// import 'package:ecommerce/widgets/circular_indicator.dart';
// import 'package:ecommerce/widgets/message_pop_up.dart';
// import 'package:ecommerce/utils/device_dimensions.dart';
// import 'package:ecommerce/utils/images.dart';
// import 'package:ecommerce/utils/validators.dart';
import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/image_path.dart';
import 'package:chat_app/frontend/utils/validators.dart';
import 'package:chat_app/frontend/widgets/custom_textfield.dart';
import 'package:chat_app/frontend/widgets/overlay_loader.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailEditingController = TextEditingController();
  final _passwordEditingController = TextEditingController();
  final LoadingOverlay _loadingOverlay = LoadingOverlay();

  final _formKey = GlobalKey<FormState>();

  @override
  @override
  Widget build(BuildContext context) {
    final dimensions = deviceDimensions(context);

    return
        // BlocListener<AuthBloc, AuthState>(
        //     listener: (context, state) {
        //       if (state is LoginRegisterLoaded) {
        //         _loadingOverlay.hide();

        //         BlocProvider.of<AuthBloc>(context).add(GetAuthUserEvent());
        //       } else if (state is AuthError) {
        //         _loadingOverlay.hide();
        //         validationAlert(state.message, context: context, from: 'login');
        //       } else if (state is AuthLoading) {
        //         _loadingOverlay.show(context);
        //       } else if (state is AuthLoaded) {
        //         _loadingOverlay.hide();
        //         _emailEditingController.text = '';
        //         _passwordEditingController.text = '';

        //         Navigator.pushNamed(context, '/homepage');
        //       }
        //     },
        //     child:
        GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), BlendMode.dstATop),
            image: const AssetImage(ImagePaths.ecommerceBackground),
            fit: BoxFit.fill,
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: BlocListener<UserDetailBloc, UserDetailState>(
            listener: (context, state) {
              if (state is UserDetalsExists) {
                Navigator.popAndPushNamed(context, '/home');
              } else if (state is UserDetalsExistsFailed) {
                Navigator.popAndPushNamed(context, '/home');
              } else if (state is UserDetalsExistsFailed) {
                Navigator.popAndPushNamed(context, '/userDetail');
              }
            },
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthLoading) {
                  _loadingOverlay.show(context);
                } else if (state is LoginLoaded) {
                  _loadingOverlay.hide();
                  BlocProvider.of<UserDetailBloc>(context).add(
                    const UserRecordEvent(),
                  );
                } else if (state is LoginError) {
                  _loadingOverlay.hide();
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: state.message,
                  );
                } else {
                  _loadingOverlay.hide();
                }
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: dimensions[0] * 0.1),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.all(15),
                          child: const Text(
                            'Welcome to Chatify',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        CustomTextField(
                          hintText: 'Email Id',
                          onChange: (value) {
                            _emailEditingController.text = value;
                            _emailEditingController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset:
                                        _emailEditingController.text.length));
                          },
                          textController: _emailEditingController,
                          validator: (value) {
                            if (Validators.emailValidator(value!) == false) {
                              return 'Invalid Email Id';
                            } else {
                              return null;
                            }
                          },
                        ),
                        CustomTextField(
                          hintText: 'Password',
                          onChange: (value) {
                            _passwordEditingController.text = value;
                            _passwordEditingController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: _passwordEditingController
                                        .text.length));
                          },
                          textController: _passwordEditingController,
                          validator: (value) {
                            // if (Validators.passwordValidator(value!) == false) {
                            //   return 'Invalid Password';
                            // } else {
                            //   return null;
                            // }
                          },
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(40),
                            ),
                          ),
                          width: dimensions[1] * 0.4,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                BlocProvider.of<AuthBloc>(context).add(
                                  LoginEvent(
                                      email: _emailEditingController.text,
                                      password:
                                          _passwordEditingController.text),
                                );
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue)),
                            child: const Text(
                              'Login',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'New here? Please',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.cyanAccent),
                            children: <TextSpan>[
                              TextSpan(
                                  text: ' SignUp',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.popAndPushNamed(
                                        context, '/signup'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // );
  }
}
