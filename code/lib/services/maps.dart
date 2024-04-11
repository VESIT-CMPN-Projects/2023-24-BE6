import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Position> getUserCurrentLocation() async {
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

Future<int> getPostalCode() async {
  final Position userLocation = await getUserCurrentLocation();
  List<Placemark> placemarks = await placemarkFromCoordinates(
      userLocation.latitude, userLocation.longitude);
  Placemark place = placemarks[0];
  int userPincode = int.parse(place.postalCode.toString());
  return userPincode;
}

Future<int> getPostalCodeFromLocation(latitude, longitude) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
  Placemark place = placemarks[0];
  int userPincode = int.parse(place.postalCode.toString());
  return userPincode;
}

Future<Stream<QuerySnapshot>?> sortStreamByDistance(
  Stream<QuerySnapshot<Object?>>? stream,
  double userlat,
  double userlong,
) async {
  return stream!.take(2).asyncMap((snapshot) {
    final documents = snapshot.docs;
    documents.sort((a, b) {
      // final bLocation = GeoPoint(b['latitude'], b['longitude']);
      final distanceA = Geolocator.distanceBetween(
          userlat, userlong, a['Sender Geocode Lat'], a['Sender Geocode Lon']);
      final distanceB = Geolocator.distanceBetween(
          userlat, userlong, b['Sender Geocode Lat'], b['Sender Geocode Lon']);
      return distanceA.compareTo(distanceB);
    });
    print('the snap is ${documents.first['Sender Geocode Lat']}');
    final snap = documents as QuerySnapshot<Object?>;
    return snap;
  });
}

// Define a function to sort orders
List<LatLng> sortOrderForPolyLines(
  List<LatLng> points,
  Position currentLocation,
) {
  List<LatLng> sorted = [];
  try {
    print("inside parent ${points.length}");
    LatLng init = getNearestPoint(
        points, LatLng(currentLocation.latitude, currentLocation.longitude));
    sorted.add(init);
    points.remove(init);
    int length = points.length;
    for (int i = 0; i < length; i++) {
      print("thisis sorted $sorted");
      init = getNearestPoint(points, init);
      sorted.add(init);
      points.remove(init);
      print("thisis points $points");
    }
  } catch (e) {
    print("The error in parent $e");
  }
  print("is points empty ${sorted.length}");
  return sorted;
}

getNearestPoint(List<LatLng> points, LatLng currentLocation) {
  try {
    points.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
    print("inside child ${points.first}");
    return points.first;
  } catch (e) {
    print("The error in child $e");
  }
}

List<QueryDocumentSnapshot<Object?>> sortOrders(
    QuerySnapshot snapshot, Position currentLocation) {
  final orders = snapshot.docs;
  orders.sort((a, b) {
    final distanceA = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      a['Sender Geocode Lat'],
      a['Sender Geocode Lon'],
    );
    final distanceB = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      b['Sender Geocode Lat'],
      b['Sender Geocode Lon'],
    );
    return distanceA.compareTo(distanceB);
  });
  return orders;
}

Future<List<LatLng>> getPolyPoints(
    LatLng senderDestination, LatLng receiverDestination) async {
  List<LatLng> polyline = [];
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
    }
  } catch (e) {
    print('error in polylinex is $e');
  }
  return polyline;
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<Stream<QuerySnapshot>> sortStreamByDistance(
//   Stream<QuerySnapshot> stream,
//   double userlat,
//   double userlong,
// ) async {
//   return stream.take(2).map((snapshot) {
//     final documents = snapshot.docs.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       return data.containsKey('Sender Geocode Lat') &&
//           data.containsKey('Sender Geocode Lon');
//     });

//     final sortedDocuments = documents
//         .map((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           final senderGeocodeLat = data['Sender Geocode Lat'];
//           final senderGeocodeLon = data['Sender Geocode Lon'];

//           // Check if both fields exist
//           if (senderGeocodeLat != null && senderGeocodeLon != null) {
//             final distance = Geolocator.distanceBetween(
//                 userlat, userlong, senderGeocodeLat, senderGeocodeLon);
//             return {'doc': doc, 'distance': distance};
//           } else {
//             return null; // Skip this document
//           }
//         })
//         .where((doc) => doc != null) // Filter out documents that were skipped
//         .toList();

//     // Sort the documents by distance
//     sortedDocuments.sort(
//         (a, b) => (a!['distance'] as double).compareTo(b!['distance'] as double));

//     // Extract the documents from the sorted list
//     // final sortedDocs = sortedDocuments
//     //     .map((doc) => doc!['doc'] as QueryDocumentSnapshot)
//     //     .toList();

//     // return QuerySnapshot<Object?>.docs(sortedDocs);
//         // Extract the documents from the sorted list
//     final sortedDocs = sortedDocuments.map((doc) => doc!['doc'] as QueryDocumentSnapshot).toList();

//     return QuerySnapshot<Object?>.fromDocuments(sortedDocs);
//   });
// }