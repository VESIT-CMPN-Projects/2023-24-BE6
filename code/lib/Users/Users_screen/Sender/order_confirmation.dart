import 'package:deliveryx/Users/Users_screen/Sender/order_tracking.dart';
import 'package:deliveryx/Users/Users_screen/Sender/qr.dart';
import 'package:deliveryx/services/auth.dart';
import 'package:deliveryx/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../eventlogger.dart';
import '/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orderconfirmation extends StatefulWidget {
  final String orderId;
  final String date;

  const Orderconfirmation({
    super.key,
    required this.orderId,
    required this.date,
  });

  @override
  State<Orderconfirmation> createState() => _OrderconfirmationState();
}

class _OrderconfirmationState extends State<Orderconfirmation> {
  final FirestoreService firestoreService = FirestoreService();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final currentUser = FirebaseAuth.instance.currentUser;
  String? senderId;

  String travelerName = 'Name';
  String travelerPhone = 'Phone';

  @override
  void initState() {
    super.initState();
    fetchTravelerInfo();
    _getSenderId();
  }

  Future<void> _getSenderId() async {
    senderId = await _firestoreService.getUserId();
  }

  Future<void> fetchTravelerInfo() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      final orderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('orders')
          .doc(widget.orderId)
          .get();

      print("Currentuser ID");
      print(currentUser?.uid);

      if (orderSnapshot.exists) {
        final travelerId = orderSnapshot['travelerId'];

        final travelerSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(travelerId)
            .get();

        print("TRAVELER ID");
        print(travelerId);

        if (travelerSnapshot.exists) {
          setState(() {
            travelerName = travelerSnapshot['name'];
            travelerPhone = travelerSnapshot['phone'];
          });
        }
      }
    } catch (e) {
      print('Error fetching traveler information: $e');
    }
  }

  void _launchPhoneCall() async {
    final String phoneNumber = 'tel:=+91$travelerPhone';
    try {
      await launchUrlString(phoneNumber);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 90,
              ),

              // Display Traveler's Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: const Image(
                      image: AssetImage(
                          "assets/third-party_images/icons/user.png"),
                      width: 70,
                    ),
                  ),
                  const SizedBox(width: 30.0),

                  //NAME OF TRAVELER IS BEING FETCHED
                  Text(travelerName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
              const SizedBox(height: 30.0),
              Text(
                'Order has been confirmed',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Arriving in 6 minutes to your location.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const Image(
                          image: AssetImage(
                              "assets/third-party_images/icons/clock.png"),
                          width: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Column(
                        children: [
                          Text('Start Journey'),
                          SizedBox(height: 3.0),
                          Text('05:00 PM'),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(width: 55),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const Image(
                          image: AssetImage(
                              "assets/third-party_images/icons/distance.png"),
                          width: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Column(
                        children: [
                          Text('End Journey'),
                          SizedBox(height: 3.0),
                          Text('06:17 PM'),
                        ],
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 32.0),

              //DISPLAY TRAVELER number
              Text(
                travelerPhone,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32.0),
              Column(
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                      minimumSize: const Size(double.infinity, 0), // Full width
                    ),
                    onPressed: () {
                      EventLogger.logSendersMyOrdersEvent(
                        'high',
                        DateTime.now().toString(),
                        0,
                        'sender',
                        'b_Dial',
                        'Traveler dial button clicked',
                        {
                          'senderid': senderId,
                          'traveler_name': travelerName,
                          'traveler_phone_number': travelerPhone,
                        },
                      );
                      _launchPhoneCall();
                    },
                    child: Text(
                      'Dial',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.all(20),
                      side: BorderSide(
                        width: 2,
                        color: AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                      minimumSize: const Size(double.infinity, 0), // Full width
                    ),
                    onPressed: () {
                      EventLogger.logSendersMyOrdersEvent(
                        'medium',
                        DateTime.now().toString(),
                        0,
                        'sender',
                        'b_ViewLocation',
                        'View location of traveler button clicked',
                        {
                          'senderid': senderId,
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) =>
                                MyMap(orderId: widget.orderId)),
                      );
                    },
                    child: Text(
                      'View Location',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Last Button with Minimum Width
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 200,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          EventLogger.logSendersMyOrdersEvent(
                            'medium',
                            DateTime.now().toString(),
                            0,
                            'sender',
                            'b_GenerateQR',
                            'Generate QR button clicked',
                            {
                              'senderid': senderId,
                              'orderid': widget.orderId,
                            },
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    QRCodeGenerator(orderId: widget.orderId)),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner_outlined,
                              color: AppColors.black,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Generate QR',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                              ),
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
    );
  }
}
