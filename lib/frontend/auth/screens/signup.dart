import 'dart:developer';

// import 'package:ecommerce/auth/bloc/auth_bloc.dart';
// import 'package:ecommerce/auth/repository/auth_repository.dart';
// import 'package:ecommerce/auth/screens/login.dart';
// import 'package:ecommerce/widgets/circular_indicator.dart';
// import 'package:ecommerce/widgets/message_pop_up.dart';
// import 'package:ecommerce/utils/device_dimensions.dart';
// import 'package:ecommerce/utils/images.dart';
// import 'package:ecommerce/utils/validators.dart';
import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/auth/repository/repository.dart';
import 'package:chat_app/frontend/auth/screens/login.dart';
import 'package:chat_app/frontend/home/screens/homepage.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:chat_app/frontend/user_detail/screens/user_detail.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/environment.dart';
import 'package:chat_app/frontend/utils/image_path.dart';
import 'package:chat_app/frontend/utils/validators.dart';
import 'package:chat_app/frontend/widgets/custom_textfield.dart';
import 'package:chat_app/frontend/widgets/overlay_loader.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _emailEditingController = TextEditingController();
  final _passwordEditingController = TextEditingController();
  final _confirmPasswordEditingController = TextEditingController();
  // final _nameEditingController = TextEditingController();
  // final _mobileNumberEditingController = TextEditingController();

  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();
  final LoadingOverlay _loadingOverlay = LoadingOverlay();

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    final dimensions = deviceDimensions(context);
    return BlocListener<UserDetailBloc, UserDetailState>(
      listener: (context, state) {
        if (state is UserDetalsExists) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return const HomePage();
          }));
        } else if (state is UserDetalsExistsFailed) {
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
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            _loadingOverlay.show(context);
          } else if (state is SignupLoaded) {
            _loadingOverlay.hide();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const Login();
            }));
          } else if (state is GoogleSignInLoaded) {
            // _loadingOverlay.hide();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const HomePage();
            }));
            // Navigator.popAndPushNamed(context, '/about');
          } else if (state is AuthError) {
            _loadingOverlay.hide();
            CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              text: state.message,
            );
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
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            height: dimensions[0],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.dstATop),
                image: const AssetImage(ImagePaths.dropletsBackground),
                fit: BoxFit.fill,
              ),
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.transparent,
              body: Container(
                alignment: Alignment.center,
                height: dimensions[0],
                // margin: EdgeInsets.only(top: dimensions[0] * 0.2, bottom: 10),
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
                        // CustomTextField(
                        //   hintText: 'Mobile Number',
                        //   onChange: (value) {
                        //     _mobileNumberEditingController.text = value;
                        //     _mobileNumberEditingController.selection =
                        //         TextSelection.fromPosition(TextPosition(
                        //             offset: _mobileNumberEditingController
                        //                 .text.length));
                        //   },
                        //   textController: _mobileNumberEditingController,
                        //   validator: (value) {
                        //     if (Validators.isValidPhoneNumber(value!) ==
                        //         false) {
                        //       return 'Invalid Mobile Number ID';
                        //     } else {
                        //       return null;
                        //     }
                        //   },
                        // ),
                        CustomTextField(
                          obscureText: !showPassword,
                          suffixIcon: GestureDetector(
                            onTap: (() => setState(() {
                                  showPassword = !showPassword;
                                })),
                            child: Icon(
                              showPassword
                                  ? Icons.lock_open_rounded
                                  : Icons.lock_clock_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
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
                            if (_passwordEditingController.text.trim().length <
                                6) {
                              return 'Password length should be greater than or equal to 6';
                            } else {
                              return null;
                            }
                          },
                        ),
                        CustomTextField(
                          obscureText: true,
                          hintText: 'Confirm Password',
                          onChange: (value) {
                            _confirmPasswordEditingController.text = value;
                            _confirmPasswordEditingController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: _confirmPasswordEditingController
                                        .text.length));
                          },
                          textController: _confirmPasswordEditingController,
                          validator: (value) {
                            if (_passwordEditingController.text !=
                                _confirmPasswordEditingController.text) {
                              return 'Password do not match';
                            } else {
                              return null;
                            }
                          },
                        ),
                        // CustomTextField(
                        //   hintText: 'Name',
                        //   onChange: (value) {
                        //     _nameEditingController.text = value;
                        //     _nameEditingController.selection =
                        //         TextSelection.fromPosition(TextPosition(
                        //             offset:
                        //                 _nameEditingController.text.length));
                        //   },
                        //   textController: _nameEditingController,
                        //   validator: (value) {
                        //     if (_nameEditingController.text.isEmpty) {
                        //       return 'Name is Required';
                        //     } else {
                        //       return null;
                        //     }
                        //   },
                        // ),
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
                                  SignupEvent(
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
                              'Signup',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        // const SizedBox(
                        //   height: 15,
                        // ),
                        // const Text(
                        //   'Or Login with',
                        //   style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 15,
                        //       fontWeight: FontWeight.w500),
                        // ),
                        // socialMediaAuth(dimensions),
                        const SizedBox(
                          height: 15,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Already Registerd? Please',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.cyanAccent),
                            children: <TextSpan>[
                              TextSpan(
                                  text: ' Login',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.pushReplacement(
                                            context, MaterialPageRoute(
                                                builder: (context) {
                                          return const Login();
                                        })),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue)),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
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
                              // if (_formKey.currentState!.validate()) {
                              //   BlocProvider.of<AuthBloc>(context).add(
                              //     SignupEvent(
                              //         email: _emailEditingController.text,
                              //         password:
                              //             _passwordEditingController.text),
                              //   );
                              // }

                              BlocProvider.of<AuthBloc>(context).add(
                                LoginEvent(
                                    email: Environment.testUserEmail,
                                    password: Environment.testUserPassword),
                              );
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.orange)),
                            child: const Text('Login as test user',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center),
                          ),
                        ),
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
  }

  Widget socialMediaAuth(dimensions) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      GestureDetector(
        onTap: () {
          BlocProvider.of<AuthBloc>(context).add(
            GoogleSignInEvent(),
          );
        },
        child: Image.asset(
          ImagePaths.google,
          width: 70,
        ),
      ),
      // GestureDetector(
      //   onTap: () {},
      //   child: Image.asset(
      //     ImagePaths.facebook,
      //     width: 70,
      //   ),
      // ),
    ]);
  }
}
