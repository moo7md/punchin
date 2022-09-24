// ignore_for_file: no_logic_in_create_state

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:punch_in/account/sign_up.dart';

import '../models/app_user.dart';
import '../services/database.dart';
import '../utils/utils.dart';

class Login extends StatefulWidget {
  final AppUser user;
  final Database db;

  const Login({Key? key, required this.user, required this.db}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginState(db, user);
  }
}

class _LoginState extends State<Login> {
  final AppUser user;
  final Database db;
  final _frmKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  bool _isLoggingIn = false, _isLoginFailure = false;

  _LoginState(this.db, this.user);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _frmKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _isLoggingIn
            ? [
                const CircularProgressIndicator(),
                const Divider(
                  height: 15,
                  color: Colors.transparent,
                ),
                const Text("Logging you in..."),
              ]
            : [
                RichText(
                    text: const TextSpan(style: TextStyle(color: Colors.black), children: [
                  TextSpan(text: "Welcome to PunchIn!\n", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: "Punching in became easier", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
                ])),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Email"),
                  ),
                  onChanged: (value) => _email = value,
                  validator: (value) => isEmpty(value) ? "Email is required." : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Password"),
                  ),
                  validator: (value) => isEmpty(value) ? "Password is required." : null,
                  obscureText: true,
                  onChanged: (value) => _password = value,
                ),
                const SizedBox(
                  height: 15,
                ),
                RichText(
                    text: TextSpan(style: const TextStyle(color: Colors.black, fontSize: 18), children: [
                  const TextSpan(text: "You don't have an account? "),
                  TextSpan(
                      text: "Sign Up",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xff695cff),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => SignUp(db: db, user: user)))),
                ])),
                if (_isLoginFailure)
                  const SizedBox(
                    height: 10,
                  ),
                if (_isLoginFailure)
                  Card(
                    color: Colors.red[100],
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: RichText(
                        text: TextSpan(style: const TextStyle(color: Colors.black), children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.error_rounded,
                              color: Colors.red[900],
                            ),
                            alignment: PlaceholderAlignment.middle,
                          ),
                          const TextSpan(text: " Email or password is incorrect.")
                        ]),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                        onPressed: _login, icon: const Icon(Icons.login_rounded), label: const Text("Login"))
                  ],
                )
              ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoginFailure = false;
    });
    if (_frmKey.currentState!.validate()) {
      setState(() {
        _isLoggingIn = true;
      });
      _isLoginFailure = !await user.login(_email.trim(), _password, db);
      setState(() {
        _isLoggingIn = false;
      });
    }
  }
}
