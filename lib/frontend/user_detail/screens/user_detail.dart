import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/image_path.dart';
import 'package:chat_app/frontend/utils/validators.dart';
import 'package:chat_app/frontend/widgets/custom_textfield.dart';
import 'package:chat_app/frontend/widgets/overlay_loader.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({Key? key}) : super(key: key);

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameEditingController =
      TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final LoadingOverlay _loadingOverlay = LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final dimensions = deviceDimensions(context);

    return Container(
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
        backgroundColor: Colors.transparent,
        body: BlocListener<UserDetailBloc, UserDetailState>(
          listener: (context, state) {
            if (state is UserDetailLoading) {
              _loadingOverlay.show(context);
            } else if (state is UserDetalsFetched) {
              BlocProvider.of<UserDetailBloc>(context).add(
                RegisterUserDetailsEvent(
                    userName: _userNameEditingController.text,
                    bio: _bioController.text,
                    email: FirebaseAuth.instance.currentUser!.email.toString()),
              );
              _loadingOverlay.hide();
            } else if (state is UserDetalsAdded) {
              _loadingOverlay.hide();

              Navigator.popAndPushNamed(context, '/home');

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      'User added successfully',
                    ),
                    backgroundColor: Colors.green,
                  )));
              // Navigator.pushReplacementNamed(context, '/home');
            } else if (state is UserDetailError) {
              _loadingOverlay.hide();
              CoolAlert.show(
                context: context,
                onConfirmBtnTap: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                type: CoolAlertType.error,
                text: state.message,
              );
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  // margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        'Tell us something about yourself',
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        'Full Name',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      CustomTextField(
                        hintText: '',
                        onChange: (value) {
                          _userNameEditingController.text = value;
                          _userNameEditingController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset:
                                      _userNameEditingController.text.length));
                        },
                        textController: _userNameEditingController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Full Name';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        'Bio',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      CustomTextField(
                        expands: true,
                        // height: 500,
                        keyboard: TextInputType.multiline,
                        maxlines: null,
                        hintText: '',
                        onChange: (value) {
                          _aboutController.text = value;
                          _aboutController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: _aboutController.text.length));
                        },
                        textController: _aboutController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Tell us something about yourself';
                          } else {
                            return null;
                          }
                        },
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(40),
                          ),
                        ),
                        width: dimensions[1] * 0.3,
                        child: ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<UserDetailBloc>(context).add(
                              FetchUserEvent(
                                  userName: _userNameEditingController.text),
                            );
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue)),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
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
    );
  }
}
