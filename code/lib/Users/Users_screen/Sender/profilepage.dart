import 'package:deliveryx/Users/Users_screen/Sender/main_sender.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/kyc.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/main_traveller.dart';
import 'package:deliveryx/Users/Users_screen/contactpage.dart';
import 'package:deliveryx/Users/Users_screen/faq.dart';
import 'package:deliveryx/Users/Users_screen/login_with_otp.dart';
import 'package:deliveryx/Users/Users_screen/privacy_policy.dart';
import 'package:deliveryx/Users/Users_screen/tandc.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';
import '../../../services/auth.dart';
import '../../../services/firestore.dart';
import '../eventlogger.dart';

class ProfilepageSender extends StatefulWidget {
  const ProfilepageSender({super.key});

  @override
  State<ProfilepageSender> createState() => _ProfilepageSenderState();
}

class _ProfilepageSenderState extends State<ProfilepageSender> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String name = ""; // State variable for name
  String phoneNumber = "";
  int role = -1;

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore when the widget is created
    fetchSenderNamePhone();
    logEventOnInitialization();
  }

  void logEventOnInitialization() async {
    try {
      // Get current user
      final user = await _authService.getCurrentUser();
      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        final role = userData["role"];

        // Log the event
        DateTime timestamp = DateTime.now();
        EventLogger.logProfileEvent(
          'low',
          timestamp.toString(),
          role,
          'sender',
          'ProfilePageStarted',
          'Profile page Started',
          {'userid': user?.uid},
        );
      }
    } catch (e) {
      print("Error logging event on initialization: $e");
    }
  }

  Future<void> fetchSenderNamePhone() async {
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      setState(() {
        // Set the initial values for the sender's info fields
        name = userData['name'] ?? '';
        // phoneNumber = userData['phone'] ?? '';
        role = userData['role'] ?? '';
        // Set other sender's info fields as needed
        phoneNumber = userData['phone'] ?? '';
      });
    }
  }

  void _signOut() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        // Update the user's role using the FirestoreService
        await _firestoreService.updateUserRoleSignout(currentUser.uid);

        // Sign out the user using the AuthService
        await _authService.signOut();

        // Navigate to the login screen after successful logout
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreenOTP()),
        );
      }

      final user = await _authService.getCurrentUser();
      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        final role = userData["role"];

        EventLogger.logProfileEvent(
            'high',
            DateTime.now().toString(),
            role,
            'user',
            'LogoutSuccessful',
            'Logout successful',
            {'senderid': user?.uid});
      }
    } catch (e) {
      print("Error signing out: $e");

      final user = await _authService.getCurrentUser();
      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        final role = userData["role"];

        EventLogger.logProfileEvent('high', DateTime.now().toString(), role,
            'user', 'LogoutFailed', e, {'senderid': user?.uid});
      }

      // Show an alert dialog with the error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'An error occurred while signing out. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the alert dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void navigateBasedOnRole() async {
    try {
      final userData = await _firestoreService.getUserData();

      if (userData != null) {
        final role = userData["role"];
        final traveler = userData["traveler"];

        if (role == null || traveler == null) {
          // Either role or traveler is null, show an appropriate alert
          showRoleTravelerNullDialog(context);
          return;
        }

        if (role == 0 && !traveler) {
          // Navigate to sender's home page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KYCScreen(),
            ),
          );
        } else if (role == 0 && traveler) {
          // Update role to 1 and traveler to true
          await _firestoreService.updateUserRole(userData["id"], 1);
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
        } else if (role == 1) {
          // Update role to 0
          await _firestoreService.updateUserRole(userData["id"], 0);

          // Navigate to traveler registration page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainSender(getIndex: 0),
            ),
          );
        }
      } else {
        // User data is null, show a dialog
        showUserNullDialog(context);
      }

      final user = await _authService.getCurrentUser();
      if (userData != null) {
        final role = userData["role"];

        EventLogger.logProfileEvent(
            'high',
            DateTime.now().toString(),
            role,
            'sender',
            'SwitchSuccessful',
            'Switch to Traveler successful',
            {'senderid': user?.uid});
      }
    } catch (e) {
      final user = await _authService.getCurrentUser();
      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        final role = userData["role"];

        EventLogger.logProfileEvent('high', DateTime.now().toString(), role,
            'sender', 'SwitchToTravelerFailed', e, {'senderid': user?.uid});
      }
      // Exception occurred, show a dialog
      showErrorDialog(context, "An unexpected error occurred in switching: $e");
    }
  }

  // Show dialog when role or traveler is null
  void showRoleTravelerNullDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Role or traveler state not available. Error in switching.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog when user data is null
  void showUserNullDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('User data is not avaialble. Can\'t Switch'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog for general errors
  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(color: AppColors.header),
                  child: const SizedBox(
                    height: 200,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        /*1*/
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*2*/
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text("My Profile",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                      )),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final user =
                                          await _authService.getCurrentUser();
                                      final userData =
                                          await _firestoreService.getUserData();
                                      if (userData != null) {
                                        final role = userData["role"];

                                        EventLogger.logProfileEvent(
                                            'medium',
                                            DateTime.now().toString(),
                                            role,
                                            'button',
                                            'b_logout',
                                            'Logout button clicked', {
                                          'senderid': user?.uid,
                                          'role': role
                                        });
                                      }

                                      await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('LogOut'),
                                              content: const Text(
                                                  'Are you sure you want to logout'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('No'),
                                                  onPressed: () async {
                                                    final user =
                                                        await _authService
                                                            .getCurrentUser();
                                                    final userData =
                                                        await _firestoreService
                                                            .getUserData();
                                                    if (userData != null) {
                                                      final role =
                                                          userData["role"];
                                                      DateTime timestamp =
                                                          DateTime.now();
                                                      EventLogger.logProfileEvent(
                                                          'low',
                                                          DateTime.now()
                                                              .toString(),
                                                          role,
                                                          'button',
                                                          'b_logout_no',
                                                          'Logout cancel button clicked',
                                                          {
                                                            'senderid':
                                                                user?.uid,
                                                            'role': role
                                                          });
                                                    }

                                                    Navigator.of(context).pop(
                                                        false); // Don't allow navigation
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Yes'),
                                                  onPressed: () async {
                                                    final user =
                                                        await _authService
                                                            .getCurrentUser();
                                                    final userData =
                                                        await _firestoreService
                                                            .getUserData();
                                                    if (userData != null) {
                                                      final role =
                                                          userData["role"];
                                                      DateTime timestamp =
                                                          DateTime.now();
                                                      EventLogger.logProfileEvent(
                                                          'medium',
                                                          DateTime.now()
                                                              .toString(),
                                                          role,
                                                          'button',
                                                          'b_logout_yes',
                                                          'Logout yes button clicked',
                                                          {
                                                            'senderid':
                                                                user?.uid,
                                                            'role': role
                                                          });
                                                    }
                                                    _signOut();
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const LoginScreenOTP()));
                                                  },
                                                ),
                                              ],
                                            );
                                          });

                                      // Add your logout logic here
                                      // Call your logout function when tapped
                                    },
                                    child: Icon(
                                      Icons.logout,
                                      size: 30,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ),
                            const SizedBox(
                              height: 90,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: AppColors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Hello!! $name",
                                              style: TextStyle(
                                                fontSize: 15,
                                                // fontWeight: FontWeight.w800,
                                                color: AppColors.white,
                                              )),
                                          Text("+91 $phoneNumber",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(
                                    Icons.edit_square,
                                    size: 30,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Padding(
            // padding: EdgeInsets.only(
            //     bottom: 8, top: 8, left: 8), //apply padding to all four sides
            padding: EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color.fromARGB(255, 203, 195, 195),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(
                Icons.lock,
                color: AppColors.primary,
              ),
              title: const Text(
                'Change Password',
                textAlign: TextAlign.left,
                style: TextStyle(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: AppColors.inputBorder,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(
                Icons.wallet,
                color: AppColors.primary,
              ),
              title: const Text(
                'Wallet',
                textAlign: TextAlign.left,
                style: TextStyle(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: InkWell(
              onTap: () async {
                final user = await _authService.getCurrentUser();
                final userData = await _firestoreService.getUserData();
                if (userData != null) {
                  final role = userData["role"];

                  EventLogger.logProfileEvent(
                      'high',
                      DateTime.now().toString(),
                      role,
                      'button',
                      'b_SwitchToTraveller',
                      'Switch role to traveler button clicked',
                      {'senderid': user?.uid});
                }
                navigateBasedOnRole();
              },
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: AppColors.inputBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
                title: Text(
                  role == 0
                      ? 'Switch roles to Traveler'
                      : 'Switch roles to Sender',
                  style: TextStyle(
                    color: role == 0
                        ? AppColors.black
                        : AppColors
                            .black, // Customize the text color based on the role
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16), //apply padding to all four sides
            child: Text(
              'About Us',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(
                Icons.question_answer_outlined,
                color: AppColors.primary,
              ),
              title: const Text('FAQ'),
              onTap: () async {
                final user = await _authService.getCurrentUser();
                final userData = await _firestoreService.getUserData();
                if (userData != null) {
                  final role = userData["role"];

                  EventLogger.logProfileEvent(
                      'low',
                      DateTime.now().toString(),
                      role,
                      'button',
                      'b_FAQ',
                      'FAQ button clicked',
                      {'senderid': user?.uid});
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FAQPage(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(
                Icons.security,
                color: AppColors.primary,
              ),
              title: const Text('Privacy Policy'),
              onTap: () async {
                final user = await _authService.getCurrentUser();
                final userData = await _firestoreService.getUserData();
                if (userData != null) {
                  final role = userData["role"];

                  EventLogger.logProfileEvent(
                      'low',
                      DateTime.now().toString(),
                      role,
                      'button',
                      'b_PrivacyPolicy',
                      'Privacy Policy button clicked',
                      {'senderid': user?.uid});
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(
                Icons.phone,
                color: AppColors.primary,
              ),
              title: const Text('Contact Us'),
              onTap: () async {
                final user = await _authService.getCurrentUser();
                final userData = await _firestoreService.getUserData();
                if (userData != null) {
                  final role = userData["role"];

                  EventLogger.logProfileEvent(
                      'low',
                      DateTime.now().toString(),
                      role,
                      'button',
                      'b_ContactUs',
                      'COntact Us button clicked',
                      {'senderid': user?.uid});
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsPage(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16), //apply padding to all four sides
            child: Text(
              'Other',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(
                Icons.mobile_friendly_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Terms & Conditions'),
              onTap: () async {
                final user = await _authService.getCurrentUser();
                final userData = await _firestoreService.getUserData();
                if (userData != null) {
                  final role = userData["role"];

                  EventLogger.logProfileEvent(
                      'low',
                      DateTime.now().toString(),
                      role,
                      'button',
                      'b_T&C',
                      'T&C button clicked',
                      {'senderid': user?.uid});
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsAndConditionsPage(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 8, top: 8, left: 8), //apply padding to all four sides
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(
                Icons.share,
                color: AppColors.primary,
              ),
              title: const Text('Share'),
            ),
          ),
        ],
      ),
    );
  }
}
