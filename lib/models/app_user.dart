import 'package:flutter/material.dart';

import '../services/auth.dart';
import '../services/database.dart';

///Model class for the app user
enum UserStatus {
  loggedIn,
  loggedOut
}
class AppUser extends ChangeNotifier {
  static const String tableName = "appUser";
  static const String uuidCol = "uuid";
  static const String nameCol = "name";
  static const String emailCol = "email";
  static const String punchedInUidCol = "punchedInUid";
  static const String lastPunchInCol = "lastPunchIn";
  static const String lastPunchOutCol = "lastPunchOut";
  String uuid, name, email, punchedInUid;
  UserStatus status;


  AppUser(this.uuid, this.name, this.email, this.punchedInUid, this.status);

  Map<String, Object?> get toMap => {
    'uid': uuid,
    'name': name,
    'email': email,
    'punchedInUid': punchedInUid,
  };

  Future init(Database db) async {
   var user = await Auth(db).init();
   if(user.isLoggedIn) {
     _setUser(user);
   }
  }

  bool get isLoggedIn => status == UserStatus.loggedIn;

  Future<bool> login(String email, String password, Database db) async {
    try{
      var user = await Auth(db).login(email, password);
      print("userrr === ${user.toMap}");
      if(user.isLoggedIn) {
        _setUser(user);
        return true;
      }
      return false;
    }catch(e) {
      print(e);
      return false;
    }
  }
  void logout(Database db) async {
    await Auth(db).logout();
    _setUser(AppUser('', '', '', '', UserStatus.loggedOut));
  }

  Future<int> signUp(Database db, Auth auth, String name, String email, String password) async {
    try{
      var user = await auth.createUser(email, password, AppUser('', name, email, '', UserStatus.loggedOut));
      if(user.isLoggedIn) {
        _setUser(user);
        return auth.errorCode;
      }
      return auth.errorCode;
    }catch(e) {
      print(e);
      return auth.errorCode;
    }
  }

  void _setUser(AppUser user) {
    uuid = user.uuid;
    name = user.name;
    email = user.email;
    status = user.status;
    punchedInUid = user.punchedInUid;
    notifyListeners();
  }
}