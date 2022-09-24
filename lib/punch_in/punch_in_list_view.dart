// ignore_for_file: use_build_context_synchronously, no_logic_in_create_state

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:punch_in/punch_in/punch_in_card.dart';

import '../models/app_user.dart';
import '../models/punch_in.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../utils/utils.dart';
import 'punch_in_button.dart';

class PunchInsListView extends StatefulWidget {
  final Database db;
  final AppUser user;

  const PunchInsListView({super.key, required this.db, required this.user});

  @override
  State<StatefulWidget> createState() {
    return PunchInsListViewState(db, user);
  }
}

class PunchInsListViewState extends State<PunchInsListView> {
  final Database db;
  final AppUser user;
  DocumentSnapshot? _lastDoc;
  late final PunchIn _latestPunchIn = PunchIn('', user.uuid, PunchInType.Unknown, Timestamp.now(), null);
  final List<PunchIn> _items = [];
  bool _isLoading = true;
  final LocalAuthentication _bioAuth = LocalAuthentication();
  final ScrollController _sc = ScrollController();

  PunchInsListViewState(this.db, this.user);

  @override
  void initState() {
    _getPunchIns();
    _sc.addListener(() {
      if(_sc.position.atEdge) {
        if(_sc.position.pixels > 0) {
          _getPunchIns();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _items.isEmpty && _isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : CustomScrollView(
      controller: _sc,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
                  (context, index) => PunchInButton(
                punchedIn: _latestPunchIn,
                onPressed: () => _punchInAction(context),
              ),
              childCount: 1),
        ),
        const SliverAppBar(
          backgroundColor: Colors.white,
          leading: Icon(
            Icons.history_rounded,
            color: Colors.black54,
            size: 50,
          ),
          title: Text(
            " History",
            style: TextStyle(fontSize: 30),
          ),
          pinned: true,
          titleSpacing: 0,
        ),
        _items.isNotEmpty
            ? SliverList(
          delegate: SliverChildBuilderDelegate(
                  (context, index) => PunchInCard(key: UniqueKey(), punchIn: _items[index]),
              childCount: _items.length),
        )
            : SliverList(
          delegate: SliverChildBuilderDelegate((context, index) => const Center(child: Text("No Items")),
              childCount: 1),
        ),
        if(_isLoading && _items.isNotEmpty) SliverList(
          delegate: SliverChildBuilderDelegate(
                  (context, index) => const Center(child: CircularProgressIndicator()),
              childCount: 1),
        ),
      ],
    );
  }

  void _getPunchIns() async {
    setState(() {
      _isLoading = true;
    });
    final punchIns = await db.getPunchIns(user.uuid, size: 10, lastDoc: _lastDoc);
    if (_items.isEmpty) {
      _latestPunchIn.update(punchIns.isEmpty ? _latestPunchIn : PunchIn.fromDocument(punchIns.first));
    }
    setState(() {
      for (DocumentSnapshot doc in punchIns) {
        _items.add(PunchIn.fromDocument(doc));
      }
      _lastDoc = punchIns.isNotEmpty? punchIns.last : _lastDoc;
      _isLoading = false;
    });
  }

  void _punchInAction(context) async {
    bool confirmed = await _confirm(context);
    if (confirmed) {
      var currentLocation = await Geolocator.getCurrentPosition();
      var newPunchIn = PunchIn(
        '',
        user.uuid,
        _latestPunchIn.type == PunchInType.In ? PunchInType.Out : PunchInType.In,
        Timestamp.now(),
        GeoPoint(currentLocation.latitude, currentLocation.longitude),
      );
      _latestPunchIn.update(newPunchIn);
      await db.writePunchedIn(_latestPunchIn);
      setState(() {
        _items.insert(0, newPunchIn);
      });
    }
  }

  Future<bool> _confirm(context) async {
    if (await _bioAuth.canCheckBiometrics) {
      try {
        return await _bioAuth.authenticate(localizedReason: 'Please authenticate to confirm action');
      } on PlatformException {
        return false;
      }
    } else {
      bool confirmed = false;
      await showDialog(
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
                    const Text("Please authenticate to confirm action"),
                    const Divider(height: 10, color: Colors.transparent),
                    TextFormField(
                      onChanged: (value) => password = value,
                      obscureText: true,
                      decoration: const InputDecoration(
                        label: Text("Password"),
                      ),
                      validator: (value) => isEmpty(value) ? "Password is required." : !confirmed? "Wrong password." : null,
                    ),
                    const Divider(height: 10, color: Colors.transparent),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () async {
                                confirmed = await Auth(db).reAuth(user.email, password);
                                if(confirmed) {
                                  Navigator.of(context).pop();
                                } else {
                                  frmKey.currentState!.validate();
                                }
                              },
                              child: const Text("Confirm")),
                        ),
                        const VerticalDivider(width: 10, color: Colors.transparent),
                        Expanded(
                          child:
                          OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
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
      return confirmed;
    }
  }
}