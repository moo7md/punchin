import 'package:firebase_auth/firebase_auth.dart';
import 'package:punch_in/models/app_user.dart';
import 'package:punch_in/services/database.dart';

class Auth {
  static const int good = 1;
  static const int other = -1;
  static const int usedEmail = -2;
  final Database db;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int errorCode = 1;
  User? _user;

  Auth(this.db);

  ///Initialize auth and set the user if any
  Future<AppUser> init() async {
    _user = _auth.currentUser;
    return await _getUser(_user?.uid);
  }

  Future<AppUser> createUser(String email, String password, AppUser user) async {
    try {
      var authRes = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = authRes.user;
      if(_user == null) return AppUser('', '', '', '', UserStatus.loggedOut);
      user.uuid = _user!.uid;
      user.status = UserStatus.loggedIn;
      await db.writeUser(_user!.uid, user);
      errorCode = good;
      return user;
    } on FirebaseAuthException catch(e) {
      print("AuthError: $e");
      if(e.code == "email-already-in-use") {
        errorCode = usedEmail;
      } else {
        errorCode = other;
      }
      return AppUser('', '', '', '', UserStatus.loggedOut);
    }
  }
  Future<AppUser> login(String email, String password) async {
    try {
      var authRes = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = authRes.user;
      if(_user == null) return AppUser('', '', '', '', UserStatus.loggedOut);
      var t =  await _getUser(_user?.uid);
      return t;
    } catch (e) {
      print(e);
      return AppUser('', '', '', '', UserStatus.loggedOut);
    }
  }

  Future<bool> reAuth(String email, String password) async {
    try {
      var authRes = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = authRes.user;
      if(_user == null) return false;
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  ///Get the currently logged in user
  Future<AppUser> _getUser(String? uid) async {
    if(uid != null) {
      try {
        var userDoc = await db.getUser(uid);
        if (userDoc == null) return AppUser('', '', '', '', UserStatus.loggedOut);
        return AppUser(
          userDoc.get("uid"),
          userDoc.get("name"),
          userDoc.get("email"),
          userDoc.get("punchedInUid"),
          UserStatus.loggedIn,
        );
      } catch (e) {
        print(e);
        return AppUser('', '', '', '', UserStatus.loggedOut);
      }
    }
    return AppUser('', '', '', '', UserStatus.loggedOut);
  }

  logout() async {
    await _auth.signOut();
  }
}
