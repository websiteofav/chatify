// ignore_for_file: prefer_const_constructors

import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:chat_app/frontend/widgets/overlay_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchConnections extends StatefulWidget {
  const SearchConnections({Key? key}) : super(key: key);

  @override
  State<SearchConnections> createState() => _SearchConnectionsState();
}

class _SearchConnectionsState extends State<SearchConnections> {
  final LoadingOverlay _loadingOverlay = LoadingOverlay();

  void initState() {
    BlocProvider.of<UserDetailBloc>(context).add(
      GetAllUUsersEvent(),
    );
    super.initState();
  }

  List userConnectionStatus = [];

  List<UserDetailsModel> model = [];
  final _searchEditingController = TextEditingController();

  List userPartners = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.textFieldBackgroundColor,
          title: const Text(
            'Available Connections',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1,
                fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: AppColors.backgroundColor1,
        body: BlocListener<UserDetailBloc, UserDetailState>(
          listener: (context, state) {
            if (state is GetAllUsers) {
              _loadingOverlay.hide();

              BlocProvider.of<UserDetailBloc>(context).add(
                FetchUserPartnersEvent(
                    email: FirebaseAuth.instance.currentUser!.email.toString()),
              );

              model = state.model;
            } else if (state is UserDetailLoading) {
              _loadingOverlay.show(context);
            } else if (state is GetUserPartners) {
              _loadingOverlay.hide();

              userPartners = state.partner;
            } else {
              _loadingOverlay.hide();
            }
          },
          child: BlocBuilder<UserDetailBloc, UserDetailState>(
            builder: (context, state) {
              if (model.isNotEmpty) {
                _loadingOverlay.hide();

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: Column(children: [
                      SizedBox(
                        height: 80,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {});
                          },
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
                            hintText: 'Search Usernames',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[200]),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              // width: 0.0 produces a thin "hairline" border
                              borderSide: BorderSide(
                                // color: Colors.black,
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: model.length,
                          itemBuilder: (ctx, index) {
                            return model[index]
                                    .userName!
                                    .toLowerCase()
                                    .contains(_searchEditingController.text
                                        .trim()
                                        .toLowerCase())
                                ? Container(
                                    padding: EdgeInsets.all(20),
                                    height: 140,
                                    // margin: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.backgroundColor2,
                                          blurRadius: 5.0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      model[index]
                                                          .userName
                                                          .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.logout,
                                                          fontSize: 20)),
                                                  Text(
                                                    model[index].bio.toString(),
                                                    overflow:
                                                        TextOverflow.visible,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .shadowColor1,
                                                        fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // _getButton()
                                            _getButton(index)
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container();
                          }),
                    ]),
                  ),
                );
              } else if (state is GetAllUsersFailed) {
                _loadingOverlay.hide();

                return Container(
                  alignment: Alignment.center,
                  child: Text(state.message,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                      )),
                );
              } else {
                return Container();
              }
            },
          ),
        ));
  }

  void _onPress(index) {
    String? userEmail = FirebaseAuth.instance.currentUser!.email.toString();
    if (userConnectionStatus[index] == 'Connect') {
      userPartners
          .add({model[index].email: UserPartnersState.pending.toString()});
      BlocProvider.of<UserDetailBloc>(context).add(
        UpdateUserPartnersEvent(
            partnerEmail: model[index].email.toString(),
            partnerUpdateStatus:
                OtherUserPartnersState.requestPending.toString(),
            userEmail: userEmail,
            userPartnerUpdateList: userPartners),
      );
    }

    if (userConnectionStatus[index] == 'Connect') {
      userPartners
          .add({model[index].email: UserPartnersState.pending.toString()});
      BlocProvider.of<UserDetailBloc>(context).add(
        UpdateUserPartnersEvent(
            partnerEmail: model[index].email.toString(),
            partnerUpdateStatus:
                OtherUserPartnersState.requestPending.toString(),
            userEmail: userEmail,
            userPartnerUpdateList: userPartners),
      );
    } else if (userConnectionStatus[index] == 'Accept') {
      userPartners.add({
        model[index].email: OtherUserPartnersState.requestAccepted.toString()
      });
      BlocProvider.of<UserDetailBloc>(context).add(
        UpdateUserPartnersEvent(
            partnerEmail: model[index].email.toString(),
            partnerUpdateStatus: UserPartnersState.connected.toString(),
            userEmail: userEmail,
            userPartnerUpdateList: userPartners),
      );
    }
  }

  _getButton(index) {
    if (userConnectionStatus.length == model.length) {
      userConnectionStatus = [];
    }
    bool userInPartners = false;
    String partnerStatus = '';
    String email = model[index].email.toString();

    userPartners.map((e) {
      if (e.keys.first.toString() == email) {
        userInPartners = true;
        partnerStatus = e.values.first.toString();
      }
    }).toList();

    if (userInPartners) {
      if (partnerStatus == UserPartnersState.pending.toString()) {
        userConnectionStatus.add('Pending');

        return _buttonDesign(index, AppColors.borderColor1, 'Pending');
      } else if (partnerStatus == UserPartnersState.connected.toString() ||
          partnerStatus == OtherUserPartnersState.requestAccepted.toString()) {
        userConnectionStatus.add('Connected');

        return _buttonDesign(index, AppColors.backgroundColor3, 'Connected');
      } else if (partnerStatus ==
          OtherUserPartnersState.requestPending.toString()) {
        userConnectionStatus.add('Accept');

        return _buttonDesign(index, AppColors.borderColor1, 'Accept');
      }
    } else {
      userConnectionStatus.add('Connect');

      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            border: Border.all(color: AppColors.backgroundColor4)),
        width: 120,
        child: ElevatedButton(
          onPressed: () {
            _onPress(index);
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent)),
          child: const Text(
            'Connect',
            style: TextStyle(color: AppColors.backgroundColor4, fontSize: 18),
          ),
        ),
      );
    }
  }

  _buttonDesign(index, borderColor, title) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          border: Border.all(color: borderColor)),
      width: 130,
      child: ElevatedButton(
        onPressed: () {
          _onPress(index);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child: Text(
          title,
          style: TextStyle(color: borderColor, fontSize: 18),
        ),
      ),
    );
  }
}
