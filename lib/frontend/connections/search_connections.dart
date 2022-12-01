// ignore_for_file: prefer_const_constructors

import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/user_detail/bloc/user_detail_bloc.dart';
import 'package:chat_app/frontend/user_detail/models/user_detail.dart';
import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/widgets/overlay_loader.dart';
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

  List<UserDetailsModel> model = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor1,
        body: BlocListener<UserDetailBloc, UserDetailState>(
          listener: (context, state) {
            if (state is GetAllUsers) {
              _loadingOverlay.hide();

              model = state.model;
            } else if (state is UserDetailLoading) {
              _loadingOverlay.show(context);
            }
          },
          child: BlocBuilder<UserDetailBloc, UserDetailState>(
            builder: (context, state) {
              if (model.isNotEmpty) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Available Connections',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 25,
                                backgroundColor: AppColors.backgroundColor5)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: model.length,
                          itemBuilder: (ctx, index) {
                            return Container(
                              padding: EdgeInsets.all(20),
                              height: 140,
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.backgroundColor2,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    color: AppColors.logout,
                                                    fontSize: 20)),
                                            Text(
                                              model[index].bio.toString(),
                                              overflow: TextOverflow.visible,
                                              style: TextStyle(
                                                  color: AppColors
                                                      .backgroundColor3,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                            border: Border.all(
                                                color: AppColors
                                                    .backgroundColor4)),
                                        width: 120,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent)),
                                          child: const Text(
                                            'Connect',
                                            style: TextStyle(
                                                color:
                                                    AppColors.backgroundColor4,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
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
}
