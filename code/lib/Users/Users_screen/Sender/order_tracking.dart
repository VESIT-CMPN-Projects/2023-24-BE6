import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/services/mongodb.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../eventlogger.dart';
// import 'package:location/location.dart';
// import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  final orderId;
  const MyMap({super.key, required this.orderId});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  // late Position userlocation;
  late Location senderDestination;
  late Location receiverDestination;
  late double travelerLatitude;
  late double travelerLongitude;
  late GoogleMapController _controller;

  bool isloading = true;

  void getUser() async {
    final userId = FirebaseAuth.instance.currentUser;
    // print(userId!.uid.toString());
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(userId!.uid)
        .collection('orders')
        .doc(widget.orderId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    // print(documentSnapshot['Sender Address']);
    // print('1234567890');
    String senderDestinationAddress = documentSnapshot['Sender Address'];
    var senderDestinations =
        await locationFromAddress(senderDestinationAddress);
    String receiverDestinationAddress = documentSnapshot['Receiver Address'];
    var location = await MongoDatabase.readLocationByOrderId(widget.orderId);
    var receiverDestinations =
        await locationFromAddress(receiverDestinationAddress);
    // var userlocations = await getUserCurrentLocation();
    setState(() {
      travelerLatitude = location[0];
      travelerLongitude = location[1];
      receiverDestination = receiverDestinations.first;
      senderDestination = senderDestinations.first;
      isloading = false;
    });
    getPolyPoints();
  }

  List<LatLng> polyline = [];
  void getPolyPoints() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          'AIzaSyCfyl3MjY06VKC5br1KixRV2fYeEqLfC9I',
          PointLatLng(senderDestination.latitude, senderDestination.longitude),
          PointLatLng(
              receiverDestination.latitude, receiverDestination.longitude));
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polyline.add(LatLng(point.latitude, point.longitude));
        }
        setState(() {});
      }
    } catch (e) {
      print('error in polylinex is $e');
    }
  }

  getLocationUpdate() async {
    final userId = FirebaseAuth.instance.currentUser;
    print(userId!.uid.toString());
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(userId.uid)
        .collection('orders')
        .doc(widget.orderId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    print(documentSnapshot['Sender Address']);
    print('1234567890');
    // String senderDestinationAddress = documentSnapshot['Sender Address'];
    setState(() {
      travelerLatitude = documentSnapshot['latitude'];
      travelerLongitude = documentSnapshot['longitude'];
    });

    EventLogger.logSendersMyOrdersEvent(
      'high',
      DateTime.now().toString(),
      0,
      'sender',
      'ViewLocation',
      'Viewing location of traveler',
      {
        'travelerLatitude': travelerLatitude,
        'travelerLongitude': travelerLongitude
      },
    );
  }

  @override
  void initState() {
    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'ViewLocationLoading',
      'Loading location of traveler',
      {},
    );
    getUser();
    super.initState();

    // getPolyPoints();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      getLocationUpdate();
    });
  }

  @override
  void dispose() {
    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'ViewLocationCanceled',
      'View Location cancelled',
      {},
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Scaffold(
            body: Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  // semanticsLabel: 'Hang Tight ! We are fetching your Order',
                  backgroundColor: AppColors.lightwhite,
                  color: AppColors.primary,
                )),
          )
        : Scaffold(
            // body: Text('hello'),
            body: GoogleMap(
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                mapType: MapType.normal,
                markers: {
                  Marker(
                      position: LatLng(senderDestination.latitude,
                          senderDestination.longitude),
                      markerId: const MarkerId("Pick Up"),
                      infoWindow: const InfoWindow(title: 'Pick Up'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueMagenta)),
                  Marker(
                      position: LatLng(receiverDestination.latitude,
                          receiverDestination.longitude),
                      markerId: const MarkerId("Drop"),
                      infoWindow: const InfoWindow(title: 'Drop'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueMagenta)),
                  Marker(
                      position: LatLng(travelerLatitude, travelerLongitude),
                      markerId: const MarkerId("Traveler"),
                      infoWindow: const InfoWindow(title: 'Traveler'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueMagenta))
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(travelerLatitude, travelerLongitude),
                    zoom: 14.47),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: polyline,
                    color: AppColors.primary,
                    width: 6,
                  ),
                },
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                  });
                }),
          );
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(travelerLatitude, travelerLongitude), zoom: 14.47)));
  }
}


// class MyMap extends StatefulWidget {
//   final user_id;
//   final orderId;
//   MyMap(this.user_id, this.orderId);
//   @override
//   State<MyMap> createState() => _MyMapState();
// }

// class _MyMapState extends State<MyMap> {
//   // final loc.Location location = loc.Location();
//   late GoogleMapController _controller;
//   bool _added = false;
//   Position? userlocation;
//   var destination;

//   Future<Position> getUserCurrentLocation() async {
//     await Geolocator.requestPermission().catchError((error) {
//       print("error: $error");
//     });
//     return await Geolocator.getCurrentPosition();
//   }

//   void getUser() async {
//     DocumentReference documentReference = FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.user_id)
//         .collection('orders')
//         .doc(widget.orderId);
//     DocumentSnapshot documentSnapshot = await documentReference.get();
//     print(documentSnapshot);
//     print('1234567890');
//     String destinationAddress = documentSnapshot['Sender Address'];
//     var destinations = await locationFromAddress(destinationAddress);
//     var userlocations = await getUserCurrentLocation();
//     setState(() {
//       userlocation = userlocations;
//       destination = destinations.first;
//       print(userlocations);
//       print(destination);
//     });
//   }

//   List<LatLng> polyline = [];
//   void getPolyPoints() async {
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         'AIzaSyBo9kEtjiDnvCl5fkbEFV-e_tlXJwI5PI0',
//         PointLatLng(userlocation!.latitude, userlocation!.longitude),
//         destination);
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) =>
//           polyline.add(LatLng(point.latitude, point.longitude)));
//       setState(() {});
//     }
//   }

//   @override
//   void initState() {
//     // userlocation = await getUserCurrentLocation();
//     super.initState();
//     print('1234567890');
//     getUser();
//     getPolyPoints();
//   }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   print('1234567890');
//   //   // userlocation = await getUserCurrentLocation();
//   //   getUser();
//   //   getPolyPoints();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         mapType: MapType.normal,
//         markers: {
//           Marker(
//               position: LatLng(userlocation!.latitude, userlocation!.longitude),
//               markerId: MarkerId("Traveller"),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueMagenta)),
//           Marker(
//               position: LatLng(destination.latitude, destination.longitude),
//               markerId: MarkerId("Pick Up"),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueMagenta))
//         },
//         initialCameraPosition: CameraPosition(
//             target: LatLng(userlocation!.latitude, userlocation!.longitude),
//             zoom: 14.47),
//         polylines: {
//           Polyline(
//             polylineId: PolylineId('route'),
//             points: polyline,
//             color: AppColors.primary,
//             width: 6,
//           )
//         },
//         onMapCreated: (GoogleMapController controller) async {
//           setState(() {
//             _controller = controller;
//             _added = true;
//           });
//         },
//       ),
//     );
//   }

//   Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
//     DocumentReference documentReference = FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.user_id)
//         .collection('orders')
//         .doc(widget.orderId);
//     DocumentSnapshot documentSnapshot = await documentReference.get();
//     String destinationAddress = documentSnapshot['Sender Address'];
//     var destinations = await locationFromAddress(destinationAddress);
//     var destination = destinations.first;

//     await _controller
//         .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//             target: LatLng(
//                 // snapshot.data!.docs.singleWhere(
//                 //     (element) => element.id == widget.user_id)['latitude'],
//                 // snapshot.data!.docs.singleWhere(
//                 //     (element) => element.id == widget.user_id)['longitude'],
//                 destination.latitude,
//                 destination.longitude),
//             zoom: 14.47)));
//   }
// }
