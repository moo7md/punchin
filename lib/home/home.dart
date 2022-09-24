// ignore_for_file: no_logic_in_create_state, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:punch_in/home/home_app_bar.dart';

import '../models/app_user.dart';
import '../services/database.dart';
import '../punch_in/punch_in_list_view.dart';

class Home extends StatelessWidget {
  final Database db;
  final AppUser user;

  const Home({super.key, required this.db, required this.user});

  // _HomeState(this.db, this.user);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeAppBar(db: db, user: user),
          Expanded(
            child: PunchInsListView(db: db, user: user),
          )
        ],
      ),
    );
  }
}
