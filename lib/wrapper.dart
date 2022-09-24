// ignore_for_file: no_logic_in_create_state

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:punch_in/account/login.dart';
import 'package:punch_in/home/home.dart';

import 'models/app_user.dart';
import 'services/database.dart';

///Wrapper class that Displays the proper screen for the user
class Wrapper extends StatefulWidget {
  final AppUser user;

  const Wrapper({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WrapperState(user);
  }
}

class _WrapperState extends State<Wrapper> {
  late Database db;
  final AppUser user;
  bool _isDBInitializing = true;
  bool _isGettingUserInfo = true;
  bool _isLocationAllowed = false;
  bool _checkingNetwork = true;
  bool _isNetworkOnline = false;

  _WrapperState(this.user);

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Consumer(
            builder: (context, AppUser appUser, widget) {
              if (_isDBInitializing || _isGettingUserInfo || _checkingNetwork) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const Divider(height: 15, color: Colors.transparent,),
                    Text(_checkingNetwork ? "Checking network connection..." : _isDBInitializing
                        ? "Loading Database..."
                        : "Getting User Info..."),
                  ],
                );
              } else if (!_isNetworkOnline) {
                return _ErrorMessage(onRetry: _init, isNetwork: true);
              } else if (!_isLocationAllowed) {
                return _ErrorMessage(onRetry: _requestLocation, isNetwork: false);
              } else if (appUser.isLoggedIn) {
                // show home page
                return Home(db: db, user: appUser,);
              }
              //else show login/signup screen
              return Login(user: appUser, db: db);
            }
        ),
      ),
    );
  }

  Future _checkLocationPermissions() async {
    var permission = await Geolocator.checkPermission();
    _isLocationAllowed = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    if (!_isLocationAllowed) {
      await _requestLocation();
    }
  }

  Future _requestLocation() async {
    var permission = await Geolocator.requestPermission();
    setState(() {
      _isLocationAllowed = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    });
  }

  void _init() async {
    setState(() {
      _checkingNetwork = true;
      _isDBInitializing = true;
      _isGettingUserInfo = true;
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      _isNetworkOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      print("ggg $_isNetworkOnline");
      setState(() {
        _checkingNetwork = false;
      });
      if (_isNetworkOnline) {
        Firebase.initializeApp().then((value) async {
          db = Database();
          setState(() {
            _isDBInitializing = false;
          });
          await user.init(db);
          await _checkLocationPermissions();
        });
        setState(() {
          _isGettingUserInfo = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _checkingNetwork = false;
        _isDBInitializing = false;
        _isGettingUserInfo = false;
      });
    }
  }
}

class _ErrorMessage extends StatelessWidget {
  final Function onRetry;
  final bool isNetwork;

  const _ErrorMessage({super.key, required this.onRetry, required this.isNetwork});


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Icon(isNetwork? Icons.wifi_off_rounded : Icons.error_rounded, size: 64, color: Colors.red,),
              const Divider(height: 10, color: Colors.transparent,),
              Text(
                isNetwork
                    ? "To use this application, please allow the application to access network."
                    : "To use this application, please connect to a network and retry.",
                style: const TextStyle(fontSize: 18),),
              const Divider(height: 10, color: Colors.transparent,),
              OutlinedButton(onPressed: () => onRetry(), child: Text(isNetwork? "Retry" : "Allow")),
            ],
          ),
        ),
      ),
    );
  }

}