import 'package:deliveryx/Users/Users_screen/Sender/main_sender.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/main_traveller.dart';
import 'package:deliveryx/Users/Users_screen/login_with_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/auth.dart';
import '../../services/firestore.dart';
import 'package:deliveryx/Users/Users_screen/eventlogger.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreenOTP(),
  ));
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();

    // authService.signOut();

    // Delayed navigation based on the session and user role
    Future.delayed(const Duration(seconds: 3), () async {
      // Log the splash screen event
      EventLogger.logSplashScreenEvent(
        'low',
        DateTime.now().toString(),
        -1,
        'user',
        'SplashScreenViewed',
        'Splash screen viewed',
        {},
      );

      final user = await authService.getCurrentUser();

      if (user == null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreenOTP()));
        return;
      } else {
        final userData = await firestoreService.getUserData();

        if (userData != null) {
          final role = userData["role"];

          if (role != null) {
            if (role == 0) {
              // User is a sender, navigate to sender homepage
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const MainSender(
                          getIndex: 0,
                        )),
              );
            } else if (role == 1) {
              String currentuserId = FirebaseAuth.instance.currentUser!.uid;
              // final travelerStatus = await FirebaseFirestore.instance
              //     .collection('users')
              //     .doc(currentuserId)
              //     .collection('travelers')
              //     .doc(currentuserId)
              //     .collection('Accepted orders')
              //     .orderBy('Timestamp', descending: true)
              //     .limit(1)
              //     .get();

              // if (travelerStatus.docs.isNotEmpty) {
              //   var firstOrder = travelerStatus.docs[0];
              //   var firstOrderId = firstOrder.id;

              //   if (firstOrder.data().containsKey("Status") &&
              //       firstOrder["Status"] == 'Processing') {
              //     print('First Order ID: $firstOrderId');
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => GetUserCurrentLocationScreen(
              //           prevPage: 1,
              //           orderId: firstOrderId,
              //           senderId: firstOrder['senderId'],
              //         ),
              //       ),
              //     );
              //   } else if (firstOrder.data().containsKey("Status") &&
              //       firstOrder["Status"] == 'Picked') {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => GetUserCurrentLocationScreen(
              //           prevPage: 2,
              //           orderId: firstOrderId,
              //           senderId: firstOrder['senderId'],
              //         ),
              //       ),
              //     );
              //   } else {
              //     print('Order found, but it is not in Processing status.');
              //   }
              // } else {
              //   print('No accepted orders found.');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainTraveller(getIndex: 0),
                ),
              );
              // }
              // User is a traveler, navigate to traveler homepage
            }
          } else {
            // Role not found, navigate to login page
           
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LoginScreenOTP()));
          }
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/images/splash_screen_logo.png"),
              width: 600,
            ),
            SizedBox(height: 30),
            SpinKitSquareCircle(
              color: Colors.grey,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
