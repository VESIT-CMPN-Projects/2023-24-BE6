import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/order_delivering.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/order_summary.dart';
import 'package:deliveryx/services/maps.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:math';

class GetUserCurrentLocationScreen extends StatefulWidget {
  const GetUserCurrentLocationScreen(
      {Key? key, this.prevPage, this.orderId, this.senderId})
      : super(key: key);
  final prevPage;
  final orderId;
  final senderId;

  @override
  _GetUserCurrentLocationScreenState createState() =>
      _GetUserCurrentLocationScreenState();
}

class _GetUserCurrentLocationScreenState
    extends State<GetUserCurrentLocationScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool isLoading = true;
  bool didModalBottomSheet = false;
  double radius = 3000;
  bool refreshLoading = false;

  final Completer<GoogleMapController> _controller = Completer();
  Map<String, LatLng> addressCoordinates = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(19.0514885, 72.8869815),
    zoom: 5,
  );

  Stream<QuerySnapshot>? _stream1;
  Stream<QuerySnapshot>? _stream2;
  Stream<QuerySnapshot>? _stream3;

  @override
  void initState() {
    super.initState();

    if (widget.prevPage == 1 || widget.prevPage == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomModalBottomSheet(
          orderId: widget.orderId,
          senderId: widget.senderId,
          prevPage: widget.prevPage,
        ).show(context);
      });
    }

    setupMarkers();
    final pincode = getPostalCode().toString();

    _stream3 = FirebaseFirestore.instance
        .collectionGroup("orders")
        .where("Status", isEqualTo: "Active")
        .where("Sender Pincode", isEqualTo: pincode)
        .snapshots();
    getAddress(_stream3);
    _stream1 = FirebaseFirestore.instance
        .collectionGroup("orders")
        .where("Status", isEqualTo: "Active")
        .where("Sender Pincode", isLessThan: pincode)
        .orderBy("Sender Pincode", descending: true)
        .snapshots();
    getAddress(_stream1);
    _stream2 = FirebaseFirestore.instance
        .collectionGroup("orders")
        .where("Status", isEqualTo: "Active")
        .where("Sender Pincode", isGreaterThan: pincode)
        .orderBy("Sender Pincode", descending: false)
        .snapshots();
    getAddress(_stream2);
  }

  getAddress(Stream<QuerySnapshot<Object?>>? stream) {
    final currentUser = FirebaseAuth.instance.currentUser;
    Set<LatLng> markerPositions = {}; // List to store marker positions

    stream?.listen((QuerySnapshot querySnapshot) {
      for (var document in querySnapshot.docs) {
        if (document['userid'] != currentUser!.uid) {
          final senderAddress = document['Sender Address'];
          final receiverAddress = document['Receiver Address'];
          try {
            LatLng markerPosition = LatLng(
              document['Sender Geocode Lat'],
              document['Sender Geocode Lon'],
            );
            print(
                "Thisssssssssssssssss ${markerPositions.contains(markerPosition)}");

            // Check if marker position already exists with a slight offset
            while (markerPositions.contains(markerPosition)) {
              print("Thisssss $markerPosition");
              print("Thisssss ${document['Sender Address']}");

              const double offset = 0.00005; // Adjust as needed
              markerPosition = LatLng(
                markerPosition.latitude + (Random().nextDouble() * offset),
                markerPosition.longitude + (Random().nextDouble() * offset),
              );
              print("after Thissssss $markerPosition");
            }

            markerPositions
                .add(markerPosition); // Add marker position to the list

            final MarkerId senderMarkerId = MarkerId(senderAddress);

            final Marker senderMarker = Marker(
              markerId: senderMarkerId,
              position: markerPosition, // Use the modified marker position
              infoWindow: InfoWindow(title: "Dropoff : $receiverAddress"),
              icon: customMarkerIcon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderClickT(
                      orderId: document.id,
                      senderId: document['userid'],
                      showdeliverbutton: true,
                    ),
                  ),
                );
              },
            );
            setState(() {
              _markers.add(senderMarker);
            });
          } catch (e) {
            print("Geocoding error for address: $senderAddress - $e");
          }
        }
      }
    });
  }

  // getAddress(Stream<QuerySnapshot<Object?>>? stream) {
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //   stream?.listen((QuerySnapshot querySnapshot) {
  //     for (var document in querySnapshot.docs) {
  //       if (document['userid'] != currentUser!.uid) {
  //         final senderAddress = document['Sender Address'];
  //         final receiverAddress = document['Receiver Address'];
  //         try {
  //           // print('before ${DateTime.now()}');
  //           // print('middle ${DateTime.now()}');
  //           final MarkerId senderMarkerId = MarkerId(senderAddress);

  //           final Marker senderMarker = Marker(
  //             markerId: senderMarkerId,
  //             position: LatLng(document['Sender Geocode Lat'],
  //                 document['Sender Geocode Lon']),
  //             infoWindow: InfoWindow(title: "Dropoff : $receiverAddress"),
  //             icon: customMarkerIcon,
  //             onTap: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => OrderClickT(
  //                     orderId: document.id,
  //                     senderId: document['userid'],
  //                     showdeliverbutton: true,
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //           setState(() {
  //             _markers.add(senderMarker);
  //           });
  //           // print(i);
  //           print(_markers);
  //           // }
  //           // }
  //         } catch (e) {
  //           print("Geocoding error for address: $senderAddress - $e");
  //         }
  //       }
  //     }
  //   });
  // }

  late BitmapDescriptor customMarkerIcon;

  late final Set<Marker> _markers = <Marker>{};
  final Set<Circle> _circles = <Circle>{};

  Future<void> setupMarkers() async {
    customMarkerIcon = await _createCustomMarkerIcon(
        'assets/third-party_images/icons/package.png');

    final Position userLocation = await getUserCurrentLocation();
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(userLocation.latitude, userLocation.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: const InfoWindow(title: "My current Location"),
        ),
      );
    });

    _circles.add(Circle(
      circleId: const CircleId('userLocationCircle'),
      center: LatLng(userLocation.latitude, userLocation.longitude),
      radius: radius, // Radius in meters
      fillColor: Colors.blue.withOpacity(0.2),
      strokeWidth: 0,
    ));

    CameraPosition cameraPosition = CameraPosition(
      zoom: 15,
      target: LatLng(userLocation.latitude, userLocation.longitude),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(String imagePath,
      {int width = 100, int height = 100}) async {
    final ByteData byteData = await rootBundle.load(imagePath);

    final Uint8List uint8List = byteData.buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(uint8List,
        targetHeight: height, targetWidth: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedByteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedUint8List = resizedByteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(resizedUint8List);
  }

  @override
  void dispose() {
    _circles.clear();
    _stream1 = null;
    _stream2 = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            markers: Set<Marker>.of(_markers),
            circles: Set<Circle>.of(_circles),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                getUserCurrentLocation().then((value) async {
                  CameraPosition cameraPosition = CameraPosition(
                    zoom: 16,
                    target: LatLng(value.latitude, value.longitude),
                  );
                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(cameraPosition));
                });
              },
              child: const Icon(Icons.filter_center_focus),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              backgroundColor: AppColors.white,
              onPressed: () {
                setState(() {
                  refreshLoading = true;
                  final pincode = getPostalCode().toString();
                  _stream3 = FirebaseFirestore.instance
                      .collectionGroup("orders")
                      .where("Status", isEqualTo: "Active")
                      .where("Sender Pincode", isEqualTo: pincode)
                      .snapshots();
                  getAddress(_stream3);
                  _stream1 = FirebaseFirestore.instance
                      .collectionGroup("orders")
                      .where("Status", isEqualTo: "Active")
                      .where("Sender Pincode", isLessThan: pincode)
                      .orderBy("Sender Pincode", descending: true)
                      .snapshots();
                  getAddress(_stream1);
                  _stream2 = FirebaseFirestore.instance
                      .collectionGroup("orders")
                      .where("Status", isEqualTo: "Active")
                      .where("Sender Pincode", isGreaterThan: pincode)
                      .orderBy("Sender Pincode", descending: false)
                      .snapshots();
                  getAddress(_stream2);
                  refreshLoading = false;
                });
              },
              child: refreshLoading
                  ? CircularProgressIndicator(
                      color: AppColors.grey,
                    )
                  : Icon(Icons.refresh, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
