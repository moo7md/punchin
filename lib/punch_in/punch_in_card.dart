import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/punch_in.dart';
import '../utils/utils.dart';

class PunchInCard extends StatelessWidget {
  final PunchIn punchIn;

  const PunchInCard({super.key, required this.punchIn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPunchIn(context),
      child: Card(
        color: Colors.grey[50],
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Container(
                  color: punchIn.type == PunchInType.In ? Colors.green[100] : Colors.grey[100],
                  child: const Icon(Icons.fingerprint_rounded)),
            ),
            const VerticalDivider(
              width: 10,
              color: Colors.transparent,
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(punchIn.type == PunchInType.In ? "Punched in" : "Punched in"),
                    Text(formatDateTime(punchIn.createdOn.toDate())),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void _openPunchIn(context) {
    final Completer<GoogleMapController> controller = Completer();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  punchIn.type == PunchInType.In ? "Punched in" : "Punched in",
                  style: const TextStyle(fontSize: 24),
                ),
                Text(formatDateTime(punchIn.createdOn.toDate())),
                const Divider(
                  height: 15,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    clipBehavior: Clip.hardEdge,
                    child: punchIn.point != null
                        ? GoogleMap(
                        zoomControlsEnabled: false,
                        rotateGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: true,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: false,
                        trafficEnabled: false,
                        liteModeEnabled: Platform.isAndroid,
                        markers: {
                          Marker(
                            markerId: MarkerId(punchIn.uid),
                            position: LatLng(punchIn.point!.latitude, punchIn.point!.longitude),
                          ),
                        },
                        onMapCreated: (c) {
                          controller.complete(c);
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(punchIn.point!.latitude, punchIn.point!.longitude),
                          zoom: 14,
                        ))
                        : Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(style: TextStyle(fontSize: 18, color: Colors.black), children: [
                              WidgetSpan(
                                  child: Icon(
                                    Icons.error_rounded,
                                    size: 25,
                                  )),
                              TextSpan(text: "\n\nNo location"),
                            ])),
                      ),
                    ),
                  ),
                ),
                if(punchIn.point != null) const Divider(height: 15, color: Colors.transparent),
                if(punchIn.point != null) Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () {
                            final Size size = MediaQuery.of(context).size;
                            final url = 'https://www.google.com/maps/search/?api=1&query=${punchIn.point!.latitude},${punchIn.point!.longitude}';
                            Share.share(url, sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
                          },
                          icon: const Icon(Icons.share_rounded),
                          label: const Text("Share"),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15
                            )),
                            backgroundColor: MaterialStateProperty.all(const Color(0xff695cff).withOpacity(.2)),
                            foregroundColor: MaterialStateProperty.all(const Color(0xff695cff)),
                          ),
                      ),
                    ),
                    const VerticalDivider(width: 10, color: Colors.transparent,),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final url = 'https://www.google.com/maps/search/?api=1&query=${punchIn.point!.latitude},${punchIn.point!.longitude}';
                          if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                          } else {
                          throw 'Could not launch $url';
                          }
                        },
                        icon: const Icon(Icons.navigation_rounded),
                        label: const Text("Navigate to"),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15
                          )),
                          backgroundColor: MaterialStateProperty.all(const Color(0xff695cff).withOpacity(.2)),
                          foregroundColor: MaterialStateProperty.all(const Color(0xff695cff)),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}