import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Sender/main_sender.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/kyc.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/main_traveller.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/qr_scanner.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/wallet.dart';
import 'package:deliveryx/Users/Users_screen/login_with_otp.dart';
import 'package:deliveryx/services/auth.dart';
import 'package:deliveryx/Users/Users_screen/contactpage.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/firestore.dart';

class ProfilepageTraveler extends StatefulWidget {
  const ProfilepageTraveler({super.key});
  @override
  State<ProfilepageTraveler> createState() => _ProfilepageTravelerState();
}

class _ProfilepageTravelerState extends State<ProfilepageTraveler> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String name = ""; // State variable for name
  String phoneNumber = "";
  int role = -1;

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore when the widget is created
    fetchUserData();
  }

  // Function to fetch user data from Firestore
  void fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      print(currentUser);
      if (currentUser != null) {
        final userDoc =
            FirebaseFirestore.instance.collection("users").doc(currentUser.uid);

        final userData = await userDoc.get();

        if (userData.exists) {
          setState(() {
            name = userData.get("name");
            phoneNumber = userData.get("phone");

            role = userData.get('role');
          });
          print(name);
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
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
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void navigateBasedOnRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc =
          FirebaseFirestore.instance.collection("users").doc(currentUser.uid);

      final userData = await userDoc.get();

      if (userData.exists) {
        final role = userData.get("role");
        final traveler = userData.get("traveler");

        if (role == 0 && !traveler) {
          // Update role to 1 and traveler to false
          await userDoc.update({"role": 1, "traveler": true});

          // Navigate to sender's home page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KYCScreen(),
            ),
          );
        } else if (role == 0 && traveler) {
          // Update role to 1 and traveler to true
          await userDoc.update({"role": 1});

          // Navigate to traveler home page
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MainTraveller(getIndex: 0)),
          );
        } else if (role == 1) {
          // Update role to 0
          await userDoc.update({"role": 0});

          // Navigate to traveler registration page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainSender(
                getIndex: 0,
              ),
            ),
          );
        }
      }
    }
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
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        false); // Don't allow navigation
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Yes'),
                                                  onPressed: () {
                                                    _signOut();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
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
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.white,
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
                side: BorderSide(
                  width: 1,
                  color: AppColors.inputBorder,
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
            child: InkWell(
              onTap: () async {
                // final currentUser = FirebaseAuth.instance.currentUser;
                // var walletRef= await FirebaseFirestore.instance
                //     .collection("users")
                //     .doc(currentUser!.uid)
                //     .collection("travelers")
                //     .doc(currentUser.uid)
                //     .set({
                //   "Wallet Balance": 50,
                // });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Wallet()),
                );
              },
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: InkWell(
              onTap: () {
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
          const Padding(
            padding: EdgeInsets.all(16), //apply padding to all four sides
            child: Text(
              'About Us',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ),
          ),
          //test QrScannner
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), //apply padding to all four sides
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScanner()),
                );
              },
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: AppColors.inputBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(
                  Icons.qr_code_2_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('QR Scanner'),
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
                // final user = await _authService.getCurrentUser();
                // final userData = await _firestoreService.getUserData();
                // if (userData != null) {
                // final role = userData["role"];

                // EventLogger.logProfileEvent(
                //     'low',
                //     DateTime.now().toString(),
                //     role,
                //     'button',
                //     'b_ContactUs',
                //     'COntact Us button clicked',
                //     {'senderid': user?.uid});
                // }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsPage(),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16), //apply padding to all four sides
            child: Text(
              'Other',
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
                side: BorderSide(width: 1, color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(
                Icons.mobile_friendly_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Get the latest version'),
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
