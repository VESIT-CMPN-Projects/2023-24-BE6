import 'dart:async';
// import 'dart:js_interop';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/maps/map_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:path/to/location_model.dart';

class LocationController {
  final LocationModel model = LocationModel();

  LocationController();

  Set<Marker> get markers => model.markers;
  Set<Circle> get circles => model.circles;
  late BitmapDescriptor customMarkerIcon;

  get future => null;

  Future<void> setupMarkers() async {
    // Your existing implementation
    customMarkerIcon = await model
        .createCustomMarkerIcon('assets/third-party_images/icons/package.png');
  }

  Future<Position> getUserCurrentLocation() async {
    // Your existing implementation
    var permission = await Geolocator.checkPermission();
    print('the permission is $permission');
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      await Geolocator.requestPermission().catchError((error) {
        print("error: $error");
      });
    }
    return await Geolocator.getCurrentPosition();
  }

  Stream<QuerySnapshot<Object?>>? fetchStream(String userId) {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
          .collectionGroup("orders")
          .where("Status", isEqualTo: "Active")
          .where("userid", isNotEqualTo: currentUser?.uid)
          .orderBy("userid", descending: true)
          .orderBy("Timestamp", descending: true)
          .snapshots();
      model.stream = stream;
    } catch (e) {
      print(e);
    }
    return model.stream;
  }

  Future<Set<Marker>> fetchAndShowOrders() async {
    late Set<Marker> updated;
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup("orders")
          .where("Status", isEqualTo: "Active")
          .where("userid", isNotEqualTo: currentUser?.uid)
          .orderBy("userid", descending: true)
          .orderBy("Timestamp", descending: true)
          .get();
      // model.stream = stream;

      // stream.listen((QuerySnapshot snapshot) async {
      // if (!snapshot.hasData) {
      //   return;
      // }

      final senderAddresses =
          snapshot.docs.map((doc) => doc['Sender Address'] as String).toList();
      final senderPincodes =
          snapshot.docs.map((doc) => doc['Sender Pincode'] as String).toList();
      final receiverAddresses = snapshot.docs
          .map((doc) => doc['Receiver Address'] as String)
          .toList();
      final receiverPincodes = snapshot.docs
          .map((doc) => doc['Receiver Pincode'] as String)
          .toList();
      final senderIds =
          snapshot.docs.map((doc) => doc['userid'] as String).toList();
      final documentIds = snapshot.docs.map((doc) => doc.id).toList();

      updated = await geocodeAddressesAndAddMarkers(
        senderAddresses,
        receiverAddresses,
        documentIds,
        senderIds,
        senderPincodes,
        receiverPincodes,
      );
      // updated = marker;
      // });
    } catch (e) {
      print("Error fetching and showing orders: $e");
    }
    print('1236781F $updated');
    return updated;
  }

  Future<Set<Marker>> geocodeAddressesAndAddMarkers(
      List<String> senderAddresses,
      List<String> receiverAddresses,
      List<String> documentIds,
      List<String> senderIds,
      List<String> senderPincodes,
      List<String> receiverPincodes) async {
    // Your existing implementation
    customMarkerIcon = await model
        .createCustomMarkerIcon('assets/third-party_images/icons/package.png');
    final Set<Marker> updatedMarkers = {};
    // LocationModel location = new LocationModel();

    final Position userLocation = await getUserCurrentLocation();
    // List<Placemark> placemarks = await placemarkFromCoordinates(
    // userLocation.latitude, userLocation.longitude);
    // Placemark place = placemarks[0];
    // int userPincode = int.parse(place.postalCode.toString());
    updatedMarkers.add(
      Marker(
        markerId: const MarkerId('userLocation'),
        position: LatLng(userLocation.latitude, userLocation.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "My current Location"),
      ),
    );

    for (int i = 0; i < senderAddresses.length; i++) {
      final senderAddress = senderAddresses[i];
      final receiverAddress = receiverAddresses[i];
      // int factor = 5;
      // // int factor = int.parse(factorValue.substring(0, 1));
      // int lowerBound = userPincode - factor;
      // int upperBound = userPincode + factor;
      // int senderPincode = int.parse(senderPincodes[i]);
      // if (senderPincode <= upperBound && senderPincode >= lowerBound) {
      try {
        final senderLocations = await locationFromAddress(senderAddress);
        final receiverLocations = await locationFromAddress(receiverAddress);
        // print(senderPincode);
        // print('34567890');
        print('34567890 $senderLocations $receiverLocations');

        if (senderLocations.isNotEmpty && receiverLocations.isNotEmpty) {
          final senderLocation = senderLocations.first;

          final LatLng senderLatLng =
              LatLng(senderLocation.latitude, senderLocation.longitude);
          // print(senderPincode);
          // .addressCoordinates[senderAddress] = senderLatLng;
          // double distanceInMeters = Geolocator.distanceBetween(
          //     userLocation.latitude,
          //     userLocation.longitude,
          //     senderLocation.latitude,
          //     senderLocation.longitude);
          // print(distanceInMeters);
          // print(i);

          // if (distanceInMeters < radius) {
          final MarkerId senderMarkerId = MarkerId(senderAddress);

          final Marker senderMarker = Marker(
            markerId: senderMarkerId,
            position: senderLatLng,
            infoWindow: InfoWindow(title: "Dropoff : $receiverAddress"),
            icon: customMarkerIcon,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => OrderClickT(
              //       orderId: documentIds[i],
              //       senderId: senderIds[i],
              //       showdeliverbutton: true,
              //     ),
              //   ),
              // );
            },
          );
          // print('34567890  $senderMarker');

          // updatedMarkers.add(senderMarker);
          // if (!(_markers.contains(senderMarker))) {
          //   print('true');
          // setState(() {
          model.markers.add(senderMarker);
          // });
          print(i);
          // print(model.markers);
          // }
        }
      } catch (e) {
        print("Geocoding error for address: $senderAddress - $e");
      }
      // }
    }
    print('controller 67892 marker');
    print(model.markers);
    return model.markers;
  }
}
