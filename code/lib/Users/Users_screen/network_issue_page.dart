import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Sender/main_sender.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/current_user_location.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/kyc.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/main_traveller.dart';
import 'package:deliveryx/Users/Users_screen/login_with_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/firestore.dart';

class NetworkIssuePage extends StatefulWidget {
  const NetworkIssuePage({Key? key}) : super(key: key);

  @override
  State<NetworkIssuePage> createState() => _NetworkIssuePageState();
}

class _NetworkIssuePageState extends State<NetworkIssuePage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 80),
            Image.asset('assets/third-party_images/images/network_issue.png',
                height: 300),
            const SizedBox(height: 32),
            const Text(
              'WHOOPS!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No internet connection found.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA084E8),
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
              ),
              onPressed: _tryAgain,
              child: const Text(
                'Try again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateBasedOnRole() async {
    final userData = await _firestoreService.getUserData();
    String currentuserId = FirebaseAuth.instance.currentUser!.uid;

    if (userData != null) {
      final role = userData["role"];
      final traveler = userData["traveler"];

      if (role == 0) {
        // Navigate to sender's home page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainSender(getIndex: 0),
          ),
        );
      } else if (role == 1 && !traveler) {
        // Update role to 1 and traveler to true
        // await _firestoreService.updateUserRole(userData["id"], 1);

        // Navigate to traveler home page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const KYCScreen(),
          ),
        );
      } else if (role == 1 && traveler) {
        final travelerStatus = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentuserId)
            .collection('travelers')
            .doc(currentuserId)
            .collection('Accepted orders')
            .orderBy('Timestamp', descending: true)
            .limit(1)
            .get();

        if (travelerStatus.docs.isNotEmpty) {
          var firstOrder = travelerStatus.docs[0];
          var firstOrderId = firstOrder.id;

          if (firstOrder.data().containsKey("Status") &&
              firstOrder["Status"] == 'Processing') {
            print('First Order ID: $firstOrderId');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GetUserCurrentLocationScreen(
                  prevPage: 1,
                  orderId: firstOrderId,
                  senderId: firstOrder['senderId'],
                ),
              ),
            );
          } else if (firstOrder.data().containsKey("Status") &&
              firstOrder["Status"] == 'Picked') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GetUserCurrentLocationScreen(
                  prevPage: 2,
                  orderId: firstOrderId,
                  senderId: firstOrder['senderId'],
                ),
              ),
            );
          } else {
            print('Order found, but it is not in Processing status.');
          }
        } else {
          print('No accepted orders found.');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainTraveller(getIndex: 0),
            ),
          );
        }
      }
      // final trevelerStatus = FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(currentuserId)
      //     .collection('travelers')
      //     .doc(currentuserId)
      //     .collection('Accepted orders')
      //     .orderBy('Timestamp', descending: true)
      //     .get(); // Update role to 0
      // // await _firestoreService.updateUscurrentuserId["id"], 0);

      // if (trevelerStatus.docs.isNotEmpty) {
      //   // Access the first document
      //   var firstDocument = trevelerStatus.docs[0].id;

      //   // Now you can use firstDocument.data() to get the data of the document
      //   var data = firstDocument.data();
      //   print("Data of the first document: $data");
      // }

      // Navigate to traveler registration page
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreenOTP(),
        ),
      );
    }
  }

  Future<void> _tryAgain() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // Still no internet connection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Internet connection is available, go back to the previous page
      navigateBasedOnRole();
    }
  }
}
