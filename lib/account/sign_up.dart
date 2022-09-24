// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../utils/utils.dart';

class SignUp extends StatefulWidget {
  final Database db;
  final AppUser user;

  const SignUp({Key? key, required this.db, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SignUpState(db, user);
  }
}

class _SignUpState extends State<SignUp> {
  final Database db;
  final AppUser user;
  final _frmKey = GlobalKey<FormState>();
  String _name = "", _email = "", _pass = "", _confirmPass = "";

  bool _isSigningUp = false;

  bool _isSignUpFailed = false;

  int authCode = 1;

  _SignUpState(this.db, this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
        title: const Text("Sign Up"),
      ),
      body: Form(
        key: _frmKey,
        child: _isSigningUp
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            decoration:
                                const InputDecoration(label: Text("Name"), prefixIcon: Icon(Icons.person_rounded)),
                            onChanged: (value) => _name = value,
                            validator: (value) => isEmpty(value) ? "Name is required." : null,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(label: Text("Email"), prefixIcon: Icon(Icons.email_rounded)),
                            onChanged: (value) => _email = value,
                            validator: (value) => isEmpty(value) ? "Email is required." : null,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                              decoration: const InputDecoration(
                                  label: Text("Password"),
                                  prefixIcon: Icon(Icons.password_rounded),
                                  hintText: "Password must be at least 6 characters"),
                              obscureText: true,
                              onChanged: (value) => _pass = value,
                              validator: (value) {
                                if (isEmpty(value)) return "Value is required.";
                                if (value!.length < 5) return "Password must be at least 6 characters";
                                return null;
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                              decoration: const InputDecoration(
                                  label: Text("Confirm Password"), prefixIcon: Icon(Icons.check_box_outlined)),
                              obscureText: true,
                              onChanged: (value) => _confirmPass = value,
                              validator: (value) => value != _pass ? "Passwords must match." : null),
                          const SizedBox(
                            height: 10,
                          ),
                          if (_isSignUpFailed)
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
                                    TextSpan(
                                        text: authCode == Auth.usedEmail
                                            ? " An account with this email already exists."
                                            : " Error occurred. Please try again later.")
                                  ]),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [OutlinedButton(onPressed: () => _signUp(context), child: const Text("Submit"))],
                      ))
                ],
              ),
      ),
    );
  }

  void _signUp(context) async {
    _isSignUpFailed = false;
    if (_frmKey.currentState!.validate()) {
      setState(() {
        _isSigningUp = true;
      });
      authCode = await user.signUp(db, Auth(db), _name, _email.trim(), _pass);
      _isSignUpFailed = authCode != Auth.good;
      setState(() {
        _isSigningUp = false;
      });
      if (!_isSignUpFailed) Navigator.of(context).pop();
    }
  }
}
