import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
enum PunchInType {
  In,
  Out,
  Unknown
}
class PunchIn  extends ChangeNotifier{
  String uid, userUid;
  Timestamp createdOn;
  GeoPoint? point;
  PunchInType type;

  PunchIn(this.uid, this.userUid, this.type, this.createdOn, this.point);

  Map<String, dynamic> get toMap => {
        "uid": uid,
        "userUid": userUid,
        "type": type.toString(),
        "createdOn": createdOn,
        "geoPoint": point,
      };

  static PunchIn fromDocument(DocumentSnapshot doc) {
    return PunchIn(
      doc.get("uid"),
      doc.get("userUid"),
      doc.get("type") == PunchInType.In.toString()? PunchInType.In : PunchInType.Out,
      doc.get("createdOn"),
      doc.get("geoPoint"),
    );
  }

  void update(PunchIn newData) {
    uid = newData.uid;
    userUid = newData.userUid;
    type = newData.type;
    createdOn = newData.createdOn;
    point = newData.point;
    notifyListeners();
  }
}
