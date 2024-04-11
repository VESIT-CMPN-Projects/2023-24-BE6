import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/maps/map_controller.dart';
import 'package:deliveryx/services/auth.dart';
import 'package:deliveryx/services/maps.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../eventlogger.dart';
// import 'package:path/to/location_controller.dart';

// class LocationView extends StatefulWidget {
//   LocationView(
//       {Key? key, this.prevPage, this.orderId, this.senderId})
//       : super(key: key);

// class LocationView extends StatefulWidget {
//   final LocationController controller;

//   LocationView({Key? key, required this.controller}) : super(key: key);
//   var prevPage;
//   var orderId;
//   var senderId;
//   // Your existing properties

//   @override
//   _LocationViewState createState() =>
//       _LocationViewState();
// }

// abstract class _LocationViewState
//     extends State<LocationView>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   late final LocationController controller;
//   LocationView(this.controller);
//   Set<Marker> markers = controller.markers;

//   @override
//   void initState() {
//     super.initState();
//     _controller = LocationController(LocationModel());
//     _controller.setupMarkers();

//     final currentUser = FirebaseAuth.instance.currentUser;
//     _controller.fetchAndShowOrders(currentUser!.uid);
//   }

class LocationView extends StatefulWidget {
  // final LocationController controller;

  const LocationView({Key? key}) : super(key: key);

  @override
  _LocationViewState createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  final AuthService _authService = AuthService();
  late final LocationController _controller = LocationController();
  late final Set<Marker> _markers = {};
  late Set<Circle> _circles = {};
  late var stream;

  startMarker() async {
    var markers = await _controller.fetchAndShowOrders();
    setState(() {
      _markers.addAll(markers);
      print('123456123B $_markers $markers');
    });
  }

  @override
  void initState() {
    super.initState();
    startMarker();
    setState(() {
      // _markers = _controller.fetchAndShowOrders();
      _circles = _controller.circles;

      final currentUser = FirebaseAuth.instance.currentUser;
      stream = _controller.fetchStream(currentUser!.uid);
    });
    print(_markers);
    // print(_controller.fetchAndShowOrders());
    print('123456123');
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(19.0514885, 72.8869815),
    zoom: 5,
  );

  @override
  void dispose() {
    super.dispose();
    // final user = await _authService.getCurrentUser();
    EventLogger.logContinueDeliveringEvent('medium', DateTime.now().toString(),
        1, 'traveler', 'MapCancelled', 'Map Page Cancelled', {});
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    // Your existing build method

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          final user = await _authService.getCurrentUser();
          EventLogger.logContinueDeliveringEvent(
              'medium',
              DateTime.now().toString(),
              1,
              'traveler',
              'MapCancelled',
              'Map Page Cancelled',
              {'travelerid': user?.uid});
          return true;
        },
        child: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // startMarker();

                // try {
                //   final senderAddresses = snapshot.data!.docs
                //       .map((doc) => doc['Sender Address'] as String)
                //       .toList();
                //   final senderPincodes = snapshot.data!.docs
                //       .map((doc) => doc['Sender Pincode'] as String)
                //       .toList();

                //   final receiverAddresses = snapshot.data!.docs
                //       .map((doc) => doc['Receiver Address'] as String)
                //       .toList();
                //   final receiverPincodes = snapshot.data!.docs
                //       .map((doc) => doc['Receiver Pincode'] as String)
                //       .toList();
                //   final senderIds = snapshot.data!.docs
                //       .map((doc) => doc['userid'] as String)
                //       .toList();
                //   final documentIds =
                //       snapshot.data!.docs.map((doc) => doc.id).toList();

                //   // print(senderAddresses);
                //   // print(receiverAddresses);

                //   _controller.geocodeAddressesAndAddMarkers(
                //       senderAddresses,
                //       receiverAddresses,
                //       documentIds,
                //       senderIds,
                //       senderPincodes,
                //       receiverPincodes);
                // } catch (e) {
                //   print(e);
                // }
                // print(_controller.fetchAndShowOrders());
                print('12345612312');
                return GoogleMap(
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  // markers: _controller.fetchAndShowOrders() as Set<Marker>,
                  markers: _markers,
                  circles: Set<Circle>.of(_circles),
                  onMapCreated: (GoogleMapController controller) {
                    // _controller.complete(controller);
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          getUserCurrentLocation().then((value) async {
            // print("My current Location");
            // print(value.latitude.toString() + " " + value.longitude.toString());

            CameraPosition cameraPosition = CameraPosition(
              zoom: 16,
              target: LatLng(value.latitude, value.longitude),
            );

            final GoogleMapController controller = await _controller.future;

            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          });
        },
        child: const Icon(Icons.filter_center_focus),
      ),
    );
  }
}
