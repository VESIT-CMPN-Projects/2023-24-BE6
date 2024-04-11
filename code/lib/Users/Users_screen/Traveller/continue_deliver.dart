import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/current_user_location.dart';
import 'package:deliveryx/services/firestore.dart';
import 'package:deliveryx/services/maps.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

import 'package:intl/intl.dart';

import '../eventlogger.dart';

class ContinueDelivery extends StatefulWidget {
  const ContinueDelivery({super.key});
  //     {Key? key, this.prevPage, this.orderId, this.senderId})
  //     : super(key: key);
  // final prevPage;
  // final orderId;
  // final senderId;

  @override
  _GetUserCurrentLocationScreenState createState() =>
      _GetUserCurrentLocationScreenState();
}

class _GetUserCurrentLocationScreenState extends State<ContinueDelivery>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool isLoading = true;
  bool didModalBottomSheet = false;
  double radius = 3000;
  bool refreshLoading = false;
  bool _showModal = true;
  late Position currentLocation;
  late Position firstLocation;
  late var order;
  List<LatLng> polyPoints = [];
  Set<Polyline> polySet = {};

  void _toggleModal() {
    setState(() {
      _showModal = !_showModal;
    });
  }

  final Completer<GoogleMapController> _controller = Completer();
  Map<String, LatLng> addressCoordinates = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(19.0514885, 72.8869815),
    zoom: 5,
  );

  Stream<QuerySnapshot>? _stream1;
  // Stream<QuerySnapshot>? _stream2;
  // Stream<QuerySnapshot>? _stream3;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _logContinueDeliveringStarted();

    // if (widget.prevPage == 1 || widget.prevPage == 2) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   CustomModalBottomSheet(stream: _stream1).show(context);
    // });
    // }

    setupMarkers();
    // final pincode = getPostalCode().toString();

    // _stream3 = FirebaseFirestore.instance
    //     .collectionGroup("orders")
    //     .where("Status", isEqualTo: "Active")
    //     .where("Sender Pincode", isEqualTo: pincode)
    //     .snapshots();
    // getAddress(_stream3);
    _loadActiveOrdersStream();
    // getAddress(_stream1);
    // _stream2 = FirebaseFirestore.instance
    //     .collectionGroup("orders")
    //     .where("Status", isEqualTo: "Active")
    //     .where("Sender Pincode", isGreaterThan: pincode)
    //     .orderBy("Sender Pincode", descending: false)
    //     .snapshots();
    // getAddress(_stream2);
  }

  // Future<void> _loadActiveOrdersStream() async {
  //   try {
  //     final ordersStream = await _firestoreService.getOrdersStreamForActive();
  //     final location = await getUserCurrentLocation();
  //     setState(() {
  //       currentLocation = location;
  //     });

  //     setState(() {
  //       _stream1 = ordersStream;
  //     });
  //     List<LatLng> points = [];
  //     ordersStream!.listen((snapshot) async {
  //       snapshot.docs.forEach((DocumentSnapshot document) async {
  //         // Check if the document has the 'latitude' field
  //         print("yyy $document");

  //         if (document['Status'] == 'Processing') {
  //           LatLng point = LatLng(
  //               document['Sender Geocode Lat'], document['Sender Geocode Lon']);
  //           points.add(point);
  //           print("inside processing $point");
  //         } else {
  //           final receiver =
  //               await locationFromAddress(document['Receiver Address']);
  //           print(receiver);
  //           points.add(LatLng(receiver[0].latitude, receiver[0].longitude));
  //         }
  //       });
  //       print("before function $points");
  //       List<LatLng> temp = sortOrderForPolyLines(points, currentLocation);
  //       polyPoints
  //           .add(LatLng(currentLocation.latitude, currentLocation.longitude));
  //       // polyPoints.addAll(temp);

  //       print("after function");
  //       print("yyy $temp");
  //       List<LatLng> tempPoly = await getPolyPoints(
  //           LatLng(currentLocation.latitude, currentLocation.longitude),
  //           temp[0]);
  //       polyPoints.addAll(tempPoly);
  //       print("done");
  //       for (int i = 1; i < temp.length; i++) {
  //         print("done");
  //         List<LatLng> tempPoly = await getPolyPoints(temp[i - 1], temp[i]);
  //         polyPoints.addAll(tempPoly);
  //         print("done");
  //       }
  //       print("doone");
  //       setState(() {
  //         isLoading = false;
  //       });
  //     });
  //     // polySet.add(Polyline(polylineId: const PolylineId('0'), points: [
  //     //   LatLng(currentLocation.latitude, currentLocation.longitude),
  //     //   LatLng(polyPoints[0].latitude, polyPoints[0].longitude)
  //     // ]));
  //     // for (int i = 1; i < polyPoints.length; i++) {
  //     //   polySet.add(Polyline(polylineId: const PolylineId('0'), points: [
  //     //     LatLng(polyPoints[0].latitude, polyPoints[0].longitude),
  //     //     LatLng(polyPoints[1].latitude, polyPoints[1].longitude)
  //     //   ]));
  //     // }
  //     // print("The polyset os ${polySet[0]}");

  //     // })

  //     // setState(() {
  //     //   _stream1 = ordersStream;
  //     // });
  //     getAddress(ordersStream);
  //   } catch (e) {
  //     print('Error loading active orders: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error loading active orders: $e'),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  Future<void> _logContinueDeliveringStarted() async {
    EventLogger.logContinueDeliveringEvent(
      'high',
      DateTime.now().toString(),
      1,
      'traveler',
      'DeliveryStarted',
      'Traveler started delivery',
      {'travelerid': ''},
    );
  }

  // Function to delivery ongoing tile clicked event
  //orderId,
  // cost,
  // status,
  // address,
  // timestamp,
  // formattedDate,
  // dist,
  void logDeliveryOngoingTileClicked(
      String orderId,
      int cost,
      String status,
      String address,
      Timestamp timestamp,
      String formattedDate,
      int dist) async {
    // final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logContinueDeliveringEvent(
        'low',
        DateTime.now().toString(),
        1,
        'traveler',
        'tile_DeliveryOngoing',
        'Delivery Ongoing tile clicked',
        {
          'travelerid': '',
          'orderid': orderId,
          'status': status,
          'cost': cost.toString(),
          'address': address,
          'order_placed_at': formattedDate,
          'distance': dist,
        },
      );
    }
  }

  Future<void> _loadActiveOrdersStream() async {
    try {
      final ordersStream = await _firestoreService.getOrdersStreamForActive();
      final location = await getUserCurrentLocation();
      setState(() {
        currentLocation = location;
      });

      setState(() {
        _stream1 = ordersStream!.take(5);
      });
      getAddress(ordersStream);

      await for (final snapshot in ordersStream!) {
        List<LatLng> pointsS = [];
        List<LatLng> pointsR = [];

        for (final document in snapshot.docs) {
          print("xxxxxxx${document['Status'] == 'Processing'}");
          if (document['Status'] == 'Processing') {
            LatLng point = LatLng(
                document['Sender Geocode Lat'], document['Sender Geocode Lon']);
            pointsS.add(point);
            print("inside processing ${document['Sender Geocode Lat']}");
            print("inside processing $pointsS");
          } else {
            final receiver =
                await locationFromAddress(document['Receiver Address']);
            pointsR
                .add(LatLng(receiver.first.latitude, receiver.first.longitude));
            print("jjjjjjjjjjjjjjjjj");
            print('This is receiver ${receiver.first.latitude}');
            print('This is receiver $pointsR');
          }
        }

        print("pointsS $pointsS");
        pointsS.addAll(pointsR);
        // Sort points and calculate polyPoints
        print("pointsR $pointsR");
        print("ffffffffff $pointsS");
        List<LatLng> temp = sortOrderForPolyLines(pointsS, currentLocation);
        print("yyyyyyy $temp");
        polyPoints.clear(); // Clear polyPoints before adding new points
        polyPoints
            .add(LatLng(currentLocation.latitude, currentLocation.longitude));
        List<LatLng> tempPoly = await getPolyPoints(
            LatLng(currentLocation.latitude, currentLocation.longitude),
            temp[0]);
        polyPoints.addAll(tempPoly);
        for (int i = 1; i < temp.length; i++) {
          List<LatLng> tempPoly = await getPolyPoints(temp[i - 1], temp[i]);
          polyPoints.addAll(tempPoly);
        }

        setState(() {
          isLoading = false;
        });
      }

      getAddress(ordersStream);
    } catch (e) {
      print('Error loading active orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading active orders: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  getAddress(Stream<QuerySnapshot<Object?>>? stream) {
    final currentUser = FirebaseAuth.instance.currentUser;
    stream?.listen((QuerySnapshot querySnapshot) async {
      for (var document in querySnapshot.docs) {
        if (document['userid'] != currentUser!.uid) {
          final isDelivering =
              document['Status'] == 'Processing' ? false : true;
          final senderAddress = document['Sender Address'];
          final receiverAddress = document['Receiver Address'];

          try {
            // print('before ${DateTime.now()}');
            // print('middle ${DateTime.now()}');
            final MarkerId senderMarkerId = MarkerId(senderAddress);
            if (!isDelivering) {
              final Marker senderMarker = Marker(
                markerId: senderMarkerId,
                position: LatLng(document['Sender Geocode Lat'],
                    document['Sender Geocode Lon']),
                infoWindow: InfoWindow(title: "Pickup : $senderAddress"),
                icon: customMarkerIcon,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        // builder: (context) => OrderClickT(
                        //   orderId: document.id,
                        //   senderId: document['userid'],
                        //   showdeliverbutton: true,
                        // ),
                        builder: (context) => GetUserCurrentLocationScreen(
                              orderId: document.id,
                              senderId: document['userid'],
                              prevPage:
                                  document['Status'] == 'Processing' ? 1 : 2,
                            )),
                  );
                },
              );
              setState(() {
                markers.add(senderMarker);
              });
            } else {
              final address = await locationFromAddress(receiverAddress);
              final MarkerId receiverMarkerId = MarkerId(receiverAddress);
              final Marker receiverMarker = Marker(
                markerId: receiverMarkerId,
                position:
                    LatLng(address.first.latitude, address.first.longitude),
                infoWindow: InfoWindow(title: "Dropoff : $receiverAddress"),
                icon: customMarkerIcon,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        // builder: (context) => OrderClickT(
                        //   orderId: document.id,
                        //   senderId: document['userid'],
                        //   showdeliverbutton: true,
                        // ),
                        builder: (context) => GetUserCurrentLocationScreen(
                              orderId: document.id,
                              senderId: document['userid'],
                              prevPage:
                                  document['Status'] == 'Processing' ? 1 : 2,
                            )),
                  );
                },
              );
              setState(() {
                markers.add(receiverMarker);
              });
            }
            // print(i);
            print(markers);
            // }
            // }
          } catch (e) {
            print("Geocoding error for address: $senderAddress - $e");
          }
        }
      }
    });
  }

  late BitmapDescriptor customMarkerIcon;

  final Set<Marker> markers = <Marker>{};
  final Set<Circle> circles = <Circle>{};

  Future<void> setupMarkers() async {
    customMarkerIcon = await createCustomMarkerIcon(
        'assets/third-party_images/icons/package.png');

    final Position userLocation = await getUserCurrentLocation();
    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(userLocation.latitude, userLocation.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: const InfoWindow(title: "My current Location"),
        ),
      );
    });

    circles.add(Circle(
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

  Future<BitmapDescriptor> createCustomMarkerIcon(String imagePath,
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
    circles.clear();
    _stream1 = null;
    // _stream2 = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          EventLogger.logContinueDeliveringEvent(
            'medium',
            DateTime.now().toString(),
            1,
            'traveler',
            'DeliveryCancelled',
            'Traveler cancelled delivery',
            {'travelerid': ''},
          );
          return true; // Return true to allow the navigation
        },
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => _toggleModal(),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      markers: Set<Marker>.of(markers),
                      circles: Set<Circle>.of(circles),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      polylines: {
                          Polyline(
                            polylineId: const PolylineId('route'),
                            points: polyPoints,
                            color: AppColors.primary,
                            width: 6,
                          ),
                        }),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom:
                  _showModal ? 0 : -MediaQuery.of(context).size.height * 0.6,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  _toggleModal(); // Dismiss modal on background tap
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  height: MediaQuery.of(context).size.height * 0.8,
                  // color: Colors.white,
                  child: Center(
                      child: Scaffold(
                    body: SingleChildScrollView(
                        child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Continue Delivering",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    EventLogger.logContinueDeliveringEvent(
                                      'low',
                                      DateTime.now().toString(),
                                      1,
                                      'traveler',
                                      'b_arrow',
                                      'Toggle arrow clicked',
                                      {'travelerid': ''},
                                    );
                                    _toggleModal;
                                  },
                                  child: Center(
                                    child: _showModal
                                        ? const Icon(Icons.arrow_downward)
                                        : const Icon(Icons.arrow_upward),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // //listview
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _stream1,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final orders =
                                    sortOrders(snapshot.data!, currentLocation);
                                // orders.removeRange(5, orders.length);

                                if (orders.isEmpty) {
                                  return const Center(
                                      child: Text("No recent orders"));
                                }

                                // final orders = snapshot.data!.docs;
                                // orders.sort((a, b) {
                                //   // final bLocation = GeoPoint(b['latitude'], b['longitude']);
                                //   final distanceA = Geolocator.distanceBetween(
                                //       currentLocation.latitude,
                                //       currentLocation.longitude,
                                //       a['Sender Geocode Lat'],
                                //       a['Sender Geocode Lon']);
                                //   print("${a['Sender Address']} $distanceA");
                                //   final distanceB = Geolocator.distanceBetween(
                                //       currentLocation.latitude,
                                //       currentLocation.longitude,
                                //       b['Sender Geocode Lat'],
                                //       b['Sender Geocode Lon']);
                                //   print("${b['Sender Address']} $distanceB");
                                //   return distanceA.compareTo(distanceB);
                                // });

                                // if (orders.isEmpty) {
                                //   return const Center(
                                //       child: Text("No recent orders"));
                                // }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: orders.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final Random random = Random();
                                    //  final int cost = random.nextInt(601) + 701;
                                    final orderData = orders[index].data()
                                        as Map<String, dynamic>;
                                    final cost =
                                        orderData['Package Cost'] != null
                                            ? ((orderData['Package Cost'] * 0.7)
                                                .ceil())
                                            : (random.nextInt(601) + 701);

                                    final orderId = orders[index].id;
                                    final senderId =
                                        orderData['userid'] as String?;
                                    final address = orderData['Status'] ==
                                            'Processing'
                                        ? orderData['Sender Address'] as String?
                                        : orderData['Receiver Address']
                                            as String?;
                                    // orderData['Receiver Address'] as String?;
                                    final timestamp =
                                        orderData['Timestamp'] as Timestamp;
                                    final status = orderData['Status'];
                                    final formattedDate =
                                        DateFormat('yyyy-MM-dd HH:mm')
                                            .format(timestamp.toDate());
                                    final dist = (Geolocator.distanceBetween(
                                                currentLocation.latitude,
                                                currentLocation.longitude,
                                                orderData['Sender Geocode Lat'],
                                                orderData[
                                                    'Sender Geocode Lon']) /
                                            1000)
                                        .ceil();

                                    return SingleChildScrollView(
                                      child: Card(
                                        child: GestureDetector(
                                          onTap: () {
                                            logDeliveryOngoingTileClicked(
                                              orderId,
                                              cost,
                                              status,
                                              address!,
                                              timestamp,
                                              formattedDate,
                                              dist,
                                              // orderPlacedAt
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      GetUserCurrentLocationScreen(
                                                        orderId: orderId,
                                                        senderId: senderId,
                                                        prevPage: status ==
                                                                'Processing'
                                                            ? 1
                                                            : 2,
                                                      )),
                                            );
                                          },
                                          child: ListTile(
                                            leading: Image.asset(
                                              'assets/third-party_images/icons/package.png',
                                              width: 40,
                                              height: 40,
                                            ),
                                            title: Text("$address"),
                                            subtitle: Text(formattedDate),
                                            trailing: Text('$dist km'),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
