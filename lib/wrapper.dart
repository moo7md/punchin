// ignore_for_file: no_logic_in_create_state

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
  bool _isDBInitializing  = true;
  bool _isGettingUserInfo = true;
  bool _isLocationAllowed = false;

  _WrapperState(this.user);

  @override
  void initState() {
    Firebase.initializeApp().then((value) async {
      db = Database();
      _isDBInitializing = false;
      await user.init(db);
      await _checkLocationPermissions();
      setState(() {
        _isGettingUserInfo = false;
      });
    });
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
              if(_isDBInitializing || _isGettingUserInfo) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const Divider(height: 15, color: Colors.transparent,),
                    Text(_isDBInitializing? "Loading Database..." : "Getting User Info..."),
                  ],
                );
              } else if (!_isLocationAllowed) {
                return _LocationPermissionErrorMsg(onRetry: _requestLocation,);
              }else if(appUser.isLoggedIn) {
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
    if(!_isLocationAllowed) {
      await _requestLocation();
    }
  }

  Future _requestLocation() async {
    var permission = await Geolocator.requestPermission();
    setState(() {
      _isLocationAllowed = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    });
  }
}

class _LocationPermissionErrorMsg extends StatelessWidget {
  final VoidCallback onRetry;

  const _LocationPermissionErrorMsg({super.key, required this.onRetry});
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
              const Icon(Icons.error_rounded, size: 64, color: Colors.red,),
              const Divider(height: 10, color: Colors.transparent,),
              const Text("To use this application, please allow the application to access location.", style: TextStyle(fontSize: 18),),
              const Divider(height: 10, color: Colors.transparent,),
              OutlinedButton(onPressed: onRetry, child: const Text("Allow")),
            ],
          ),
        ),
      ),
    );
  }

}