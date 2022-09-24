import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:punch_in/models/app_user.dart';
import 'package:punch_in/models/punch_in.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:uuid/uuid.dart';

///Main class for this app API utilities.
class Database {
  static final Database _db = Database._internal();
  static final CollectionReference _usersCollection = _db._fdb.collection("users");
  static final CollectionReference _punchInsCollection = _db._fdb.collection("punchIns");

  bool isInitialized = false;
  final FirebaseFirestore _fdb = FirebaseFirestore.instance;

  factory Database() {
    return _db;
  }

  Database._internal();

  Future<bool> createUser(String name, String email, String password) async {
    try {
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<DocumentSnapshot?> getUser(String uid) async {
    try {
      return await _db._fdb.runTransaction((transaction) => transaction.get(_usersCollection.doc(uid)));
    } catch (e) {
      return null;
    }
  }

  Future<bool> writeUser(String uid, AppUser user) async {
    try {
      await _db._fdb.runTransaction((transaction) async => transaction.set(_usersCollection.doc(uid), user.toMap));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  ///Gets the latest punch ins depending on [size] which has a default
  ///value of 1.
  Future<List<QueryDocumentSnapshot>> getPunchIns(String userUid, {int size = 1, DocumentSnapshot? lastDoc}) async {
    try {
      var query = _punchInsCollection.where("userUid", isEqualTo: userUid).orderBy("createdOn", descending: true);
      if (lastDoc != null) query = query.startAfterDocument(lastDoc);
      query = query.limit(size);
      var res = await query.get();
      if (res.size == 0) return [];
      return res.docs;
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<bool> writePunchedIn(PunchIn p) async {
    try {
      var doc = _punchInsCollection.doc();
      p.uid = doc.id;
      await _db._fdb.runTransaction((transaction) async => transaction.set(doc, p.toMap));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
