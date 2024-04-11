import 'dart:async';

import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/order_summary.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/qr_scanner.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/send_receiver_otp.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/verify_receiver_otp.dart';
import 'package:deliveryx/services/mongodb.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../eventlogger.dart';

class CustomModalBottomSheet {
  final String orderId;
  final String senderId;
  final int prevPage;
  late DocumentReference documentReference;
  var destination;
  var lat;
  var long;

  CustomModalBottomSheet(
      {required this.orderId, required this.senderId, required this.prevPage}) {
    logContinueDeliveryPageViewed();
    documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('orders')
        .doc(orderId);
    getDestination();
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _listenLocation();
      _setLocation();
      // getLocationUpdate();
    });
  }
//tracking
  // final loc.Location location = loc.Location();
  // StreamSubscription<loc.LocationData>? _locationSubscription;

  Future<void> logContinueDeliveryPageViewed() async {
    // final userData = await _firestoreService.getUserData();
    EventLogger.logContinueDeliveringEvent(
      'low',
      DateTime.now().toString(),
      1,
      'traveler',
      'ContinueDeliveryPageViewed',
      'Continue Delivery page viewed',
      {'travelerid': ''},
    );
  }

  Future<void> _setLocation() async {
    if (lat == null || long == null) {
      return;
    }
    await MongoDatabase.updateOrCreate(lat, long, orderId);
  }

  Future<void> _listenLocation() async {
    BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) async {
      lat = location.latitude;
      long = location.longitude;
    });
  }

  Future<void> getDestination() async {
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (prevPage == 1) {
      String destinationAddress = documentSnapshot['Sender Address'];
      var destinations = await locationFromAddress(destinationAddress);
      destination = destinations.first;
    } else if (prevPage == 2) {
      String destinationAddress = documentSnapshot['Receiver Address'];
      var destinations = await locationFromAddress(destinationAddress);
      destination = destinations.first;
    }
  }

  void show(BuildContext context) async {
    showModalBottomSheet(
      // isDismissible: true,
      // enableDrag: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              EventLogger.logContinueDeliveringEvent(
                'medium',
                DateTime.now().toString(),
                1,
                'traveler',
                'ContinueDeliveryPageCancelled',
                'Continue Delivery page cancelled',
                {'travelerid': ''},
              );
              return true;
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ListTile(
                        title: Align(
                          alignment:
                              Alignment.center, // Align title to the center
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Continue Delivery',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              child: ElevatedButton(
                                onPressed: () async {
                                  String message = prevPage == 1
                                      ? "Verify Sender's QR button  clicked"
                                      : "Verify Receiver's OTP button  clicked";
                                  String eventType = prevPage == 1
                                      ? "b_VerifyQR"
                                      : "b_VerifyOTP";

                                  // Log event for verifying QR or OTP
                                  EventLogger.logContinueDeliveringEvent(
                                    'low',
                                    DateTime.now().toString(),
                                    1,
                                    'traveler',
                                    eventType,
                                    message,
                                    {'travelerid': '',
                                      'orderid': orderId},
                                  );

                                  if (prevPage == 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const QRScanner()),
                                    );
                                  } else {
                                    //Add Receiver OTP page navigator here
                                    Future<String?> s = send_receiver_otp()
                                        .sendSMS(senderId, orderId);

                                    try {
                                      // Wait for the future to complete and get the result
                                      String? sentOtp = await s;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VerifyReceiverOtp(
                                                  senderId: senderId,
                                                  orderId: orderId,
                                                  sentOtp: sentOtp,
                                                )),
                                      );

                                      // Now you can use the result as a regular String
                                      print(
                                          'Send Receiver OTP 12345678: $sentOtp');
                                    } catch (error) {
                                      print('Error: $error');
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(20),
                                  backgroundColor: AppColors.white,
                                  // minimumSize: Size(double.infinity, 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                        color: AppColors.primary, width: 2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pin,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      prevPage == 1
                                          ? "Verify Sender's QR"
                                          : "Verify Receiver's OTP",
                                      style: TextStyle(color: AppColors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              child: ElevatedButton(
                                onPressed: <Future>() async {
                                  final Position currentLocation =
                                      await Geolocator.getCurrentPosition();

                                  String url =
                                      'https://www.google.com/maps/dir/?api=1&origin=${currentLocation.latitude},${currentLocation.longitude} &destination=${destination.latitude},${destination.longitude}';
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(20),
                                  backgroundColor: AppColors.primary,
                                  // minimumSize: Size(double.infinity, 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.route,
                                      color: AppColors.white,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Directions",
                                      style: TextStyle(color: AppColors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 150,
                            child: TextButton(
                              onPressed: () {
                                DateTime timestamp = DateTime.now();
                                EventLogger.logContinueDeliveringEvent(
                                    'low',
                                    timestamp.toString(),
                                    1,
                                    'traveler',
                                    'b_ViewOrderSummary',
                                    'View Order Summary CLicked', {});
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      maintainState: true,
                                      builder: (context) => OrderClickT(
                                        senderId: senderId,
                                        orderId: orderId,
                                        // status: status,
                                        showdeliverbutton: false,
                                      ),
                                      ),
                                    );
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(20),
                                  backgroundColor: AppColors.white,
                                  // minimumSize: Size(double.infinity, 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                        color: AppColors.primary, width: 2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.summarize_outlined,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'View Order Summary',
                                      style: TextStyle(color: AppColors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
