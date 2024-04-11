import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/main_traveller.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/send_receiver_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import '../../../services/auth.dart';
import '../../../util/colors.dart';
import '../eventlogger.dart';

class VerifyReceiverOtp extends StatefulWidget {
  final String? senderId;
  final String? orderId;
  final String? sentOtp;
  static String? s, pin;
  const VerifyReceiverOtp(
      {super.key,
      required this.senderId,
      required this.orderId,
      required this.sentOtp});

  @override
  State<VerifyReceiverOtp> createState() => _verifyReceiverOtpState();
}

class _verifyReceiverOtpState extends State<VerifyReceiverOtp> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    EventLogger.logContinueDeliveringEvent(
        'medium',
        DateTime.now().toString(),
        1,
        'traveler',
        'OTPVerification Started',
        'OTP Verification Page Viewed', {});
    VerifyReceiverOtp.s = widget.sentOtp;
  }

  Future<bool> VerifyOTP(String? s, String? pin) async {
    print("$s $pin");
    if (s == pin) {
      // Log event for OTP verification success
      EventLogger.logVerifyReceiverOTPEvent(
        'medium',
        DateTime.now().toString(),
        1,
        'traveler',
        'OTPVerificationSuccessfull',
        'OTP verification successful',
        {'travelerid': ''},
      );
      Fluttertoast.showToast(msg: "Verified");
      final currentUser = FirebaseAuth.instance.currentUser;
      try {
        final trevelerStatus = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('travelers')
            .doc(currentUser.uid)
            .collection('Accepted orders')
            .doc(widget.orderId)
            .set({'Status': 'Completed'}, SetOptions(merge: true));
        final orderInfo = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.senderId)
            .collection('orders')
            .doc(widget.orderId)
            .set({'Status': 'Completed'}, SetOptions(merge: true));

        final order = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.senderId)
            .collection('orders')
            .doc(widget.orderId)
            .get();

        final cost = order['Package Cost'];
        var wallet = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .collection("travelers")
            .doc(currentUser.uid)
            .get();

        double balance = 0;
        try {
          setState(() {
            balance = wallet['Wallet Balance'];
            print("$balance inside setState of wallet");
          });
        } catch (e) {
          print('This is the orderrrrr $e');
        }

        var walletRef = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .collection("travelers")
            .doc(currentUser.uid)
            .set({
          'Wallet Balance': balance + cost * 0.7,
        });
        print(balance + cost * 0.7);
      } catch (e) {
        print('--------->value not print');
      }
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MainTraveller(getIndex: 0)),
      );
      return true;
    } else {
      // Log event for OTP verification failure
      EventLogger.logVerifyReceiverOTPEvent(
        'high',
        DateTime.now().toString(),
        1,
        'traveler',
        'OTPVerificationFailed',
        'OTP verification failed',
        {'travelerid': ''},
      );
      
      Fluttertoast.showToast(msg: "Invalid");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
        color: AppColors.splash1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

<<<<<<< HEAD
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Verify OTP"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          width: double.infinity,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align children at the center
            children: [
              const Text(
                "Verification",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: const Text(
                  "Enter the code",
=======
    return WillPopScope(
      onWillPop: () async {
        final user = await _authService.getCurrentUser();
        EventLogger.logContinueDeliveringEvent(
            'medium',
            DateTime.now().toString(),
            1,
            'traveler',
            'OTPVerificationCancelled',
            'OTP Verification Page Cancelled',
            {'travelerid': user?.uid});
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text("Verify OTP"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            margin: const EdgeInsets.only(top: 40),
            width: double.infinity,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Align children at the center
              children: [
                const Text(
                  "Verification",
>>>>>>> 19e5b5ed95afe0dcdef9433f6cb4e251ff411397
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  child: const Text(
                    "Enter the code",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
                Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primary),
                    ),
                  ),
                  onCompleted: (pin) {
                    VerifyReceiverOtp.pin = pin;
                    // VerifyOTP(VerifyReceiverOtp.s, pin);
                  },
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
                  onPressed: () {
                    DateTime timestamp = DateTime.now();
                    EventLogger.logContinueDeliveringEvent(
                        'low',
                        timestamp.toString(),
                        1,
                        'traveler',
                        'b_VerifyOTP',
                        'Verify OTP button Clicked', {});
                    var res =
                        VerifyOTP(VerifyReceiverOtp.s, VerifyReceiverOtp.pin);
                    if (res == true) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(
                                    "Yay! Package successfully delivered"),
                                content: const Text(
                                    "Explore More Packages to Deliver"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainTraveller(getIndex: 0),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.primary),
                                      padding: const EdgeInsets.all(14),
                                      child: Text(
                                        "Explore Now",
                                        style:
                                            TextStyle(color: AppColors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                    }
                  },
                  child: Text(
                    'Verify OTP',
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
                    DateTime timestamp = DateTime.now();
                    EventLogger.logContinueDeliveringEvent(
                        'low',
                        timestamp.toString(),
                        1,
                        'traveler',
                        'b_ResendOTP',
                        'Resend OTP button Clicked', {});
                    Future<String?> otp = send_receiver_otp()
                        .sendSMS(widget.senderId, widget.orderId);
                    try {
                      VerifyReceiverOtp.s = await otp;
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text(
                    'Resend OTP',
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
