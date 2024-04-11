import 'package:deliveryx/Users/Users_screen/Sender/main_sender.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/kyc.dart';
import 'package:deliveryx/Users/Users_screen/login_with_otp.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/main_traveller.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'eventlogger.dart';

import '../../services/auth.dart';
import '../../services/firestore.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  void initState() {
    super.initState();
    // Log event on initialization
    logEventOnInitialization();
  }

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  void logEventOnInitialization() async {
    try {
      // Get current user
      firebase_auth.User? user = await _authService.getCurrentUser();
      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        final role = userData["role"];

        // Log the event
        DateTime timestamp = DateTime.now();
        EventLogger.logOnboardingEvent(
          'low',
          timestamp.toString(),
          role,
          'user',
          'OnboardingStarted',
          'Onboarding Started',
          {'userid': user?.uid},
        );
      }
    } catch (e) {
      print("Error logging event on initialization: $e");
    }
  }

  void navigateBasedOnRole() async {
    try {
      final userData = await _firestoreService.getUserData();

      firebase_auth.User? user = await _authService.getCurrentUser();

      // final role = userData["role"]

      if (userData != null) {
        final role = userData["role"];
        final traveler = userData["traveler"];

        if (role == -1 && !traveler) {
          // Update role to 1 and traveler to false
          // await userDoc.update({"role": 1, "traveler": true});

          // Navigate to sender's home page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KYCScreen(),
            ),
          );
        } else if (role == -1 && traveler) {
          // Update role to 1 and traveler to true
          await _firestoreService.updateUserRole(userData["id"], 1);
          // String currentuserId = FirebaseAuth.instance.currentUser!.uid;
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
          // Navigate to traveler home page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const MainTraveller(
          //       getIndex: 0,
          //     ),
          //   ),
          // );
        }

        final userDataAgain = await _firestoreService.getUserData();

        if (userDataAgain != null) {
          final role = userDataAgain["role"];

          DateTime timestamp = DateTime.now();
          EventLogger.logOnboardingEvent(
              'medium',
              timestamp.toString(),
              role,
              'user',
              'OnboardingSuccesssful',
              'Onboarding Successsful',
              {'userid': user?.uid});
        }
      } else {
        // User data does not exist, show an alert
        showNoDataAvailableDialog(context);
        DateTime timestamp = DateTime.now();

        final userData = await _firestoreService.getUserData();
        if (userData != null) {
          final role = userData["role"];

          EventLogger.logOnboardingEvent(
              'high',
              timestamp.toString(),
              role,
              'user',
              'OnbardingFailed',
              'Onbarding failed as no user data available', {
            'userid': user?.uid,
          });
        }
      }
    } catch (e) {
      firebase_auth.User? user = await _authService.getCurrentUser();
      DateTime timestamp = DateTime.now();
      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        final role = userData["role"];
        EventLogger.logOnboardingEvent('high', timestamp.toString(), role,
            'user', 'OnboardingFailed', e, {'userid': user?.uid});
      }
      // Exception occurred, check for not-found error
      if (e is FirebaseException && e.code == 'not-found') {
        // Show a specific alert for a not-found document
        showDocumentNotFoundErrorDialog(context);
      } else {
        // Show a generic alert for other errors
        print("Error fetching user data: $e");
        showNoDataAvailableDialog(context);
      }
    }
  }

  void showDocumentNotFoundErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('User document not found.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
                // Navigate back to LoginScreenOTP
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const LoginScreenOTP()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showNoDataAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('No data available for the current user.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
                // Navigate back to LoginScreenOTP
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const LoginScreenOTP()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> logOnboardingCancelledEvent() async {
    try {
      // Get current user
      firebase_auth.User? user = await _authService.getCurrentUser();

      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        final role = userData["role"];

        // Log the event
        DateTime timestamp = DateTime.now();
        EventLogger.logOnboardingEvent(
          'low',
          timestamp.toString(),
          role,
          'user',
          'OnboardingCancelled',
          'Onboarding Cancelled',
          {'userid': user?.uid},
        );
      }
    } catch (e) {
      print("Error logging event on cancellation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        await logOnboardingCancelledEvent();
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          // child: Container(
          //   height: size.height,
          //   width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 80),
                Container(
                  child: CarouselSlider(
                    items: [
                      Container(
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/third-party_images/images/carousal_woman_gps.png',
                              height: size.height * 0.4,
                            ),
                            const Text(
                              'Seamless Sending, Hassle-Free Delivery.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/third-party_images/images/carousal_bike_man.png',
                              height: size.height * 0.4,
                            ),
                            const Text(
                              'Earn While You Journey, Deliver with Ease.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/third-party_images/images/carousal_delivery_done.png',
                              height: size.height * 0.4,
                            ),
                            const Text(
                              'Connect, Deliver, Empower Together.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                    options: CarouselOptions(
                      height: size.height * 0.5,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      viewportFraction: 0.9,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    'Welcome to DeliveryX',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  child: const Text(
                    'Choose to be a sender of the package or choose to deliver it on the go...',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8297A8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
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
                  onPressed: () async {
                    try {
                      firebase_auth.User? user =
                          await _authService.getCurrentUser();

                      final userData = await _firestoreService.getUserData();
                      if (userData != null) {
                        final role = userData["role"];

                        DateTime timestamp = DateTime.now();
                        EventLogger.logOnboardingEvent(
                            'low',
                            timestamp.toString(),
                            role,
                            'button',
                            'SendPackage_button_clicked',
                            'Send Package button clicked',
                            {'userid': user?.uid});
                      }

                      if (user != null) {
                        await _firestoreService.updateUserAsSender(user);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const MainSender(
                                    getIndex: 0,
                                  )),
                          (route) => false,
                        );

                        final userData = await _firestoreService.getUserData();

                        if (userData != null) {
                          final role = userData["role"];
                          DateTime timestamp = DateTime.now();
                          EventLogger.logOnboardingEvent(
                              'medium',
                              timestamp.toString(),
                              role,
                              'user',
                              'OnboardingSuccessful',
                              'Onboarding Successful',
                              {'userid': user.uid});
                        }
                      }
                    } catch (e) {
                      print("Error updating user data: $e");

                      firebase_auth.User? user =
                          await _authService.getCurrentUser();

                      final userData = await _firestoreService.getUserData();
                      if (userData != null) {
                        final role = userData["role"];
                        DateTime timestamp = DateTime.now();
                        EventLogger.logOnboardingEvent(
                            'high',
                            timestamp.toString(),
                            role,
                            'user',
                            'OnboardingFailed',
                            e, {
                          'userid': user?.uid,
                        });
                      }

                      // Check if the error is due to a not-found document
                      if (e is FirebaseException && e.code == 'not-found') {
                        // Show a specific alert for a not-found document
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'User document doesn\'t exist. Sorry.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the alert dialog

                                    // Navigate back to LoginScreenOTP
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              const LoginScreenOTP()),
                                    );
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Show a generic alert for other errors
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'An error occurred while updating user data. Please try again.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the alert dialog

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              const LoginScreenOTP()),
                                    );
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text(
                    'Send a package',
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
                  onPressed: () async {
                    firebase_auth.User? user =
                        await _authService.getCurrentUser();
                    DateTime timestamp = DateTime.now();
                    final userData = await _firestoreService.getUserData();
                    if (userData != null) {
                      final role = userData["role"];
                      EventLogger.logOnboardingEvent(
                          'low',
                          timestamp.toString(),
                          role,
                          'button',
                          'DeliverPackage_button_clicked',
                          'Deliver Package button clicked',
                          {'userid': user?.uid});
                    }
                    navigateBasedOnRole();
                  },
                  child: Text(
                    'Deliver a package',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
