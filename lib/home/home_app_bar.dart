import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/database.dart';

class HomeAppBar extends StatelessWidget {
  final Database db;
  final AppUser user;

  const HomeAppBar({Key? key, required this.db, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.account_circle_outlined,
          size: 50,
          color: Colors.black54,
        ),
        const SizedBox(
          width: 15,
        ),
        Text(
          user.name,
          style: const TextStyle(fontSize: 30),
        ),
        const Expanded(child: SizedBox()),
        IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final frmKey = GlobalKey<FormState>();
                  String password = "";
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Form(
                      key: frmKey,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Wrap(
                          children: [
                            const Text("Are you sure you want to logout?"),
                            const Divider(height: 10, color: Colors.transparent),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                      onPressed: () async {
                                        user.logout(db);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Yes")),
                                ),
                                const VerticalDivider(width: 10, color: Colors.transparent),
                                Expanded(
                                  child: OutlinedButton(
                                      onPressed: () => Navigator.of(context).pop(), child: const Text("No")),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            tooltip: "Logout",
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xff695cff),
            ))
      ],
    );
  }
}
