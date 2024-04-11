import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/eventlogger.dart';
import 'package:deliveryx/Users/Users_screen/login_screen.dart';
import 'package:deliveryx/services/auth.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Onboarding.dart';
import 'registration.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class LoginScreenOTP extends StatefulWidget {
  const LoginScreenOTP({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenOTP> {
  final _formKey = GlobalKey<FormState>();
  String selectedCountryCode = '+91';
  bool _showPhoneNumberInput = true;
  bool allowNavigation = false;
  void _toggleView() {
    setState(() {
      _showPhoneNumberInput = !_showPhoneNumberInput;
    });
  }

  @override
  void initState() {
    super.initState();
    DateTime timestamp = DateTime.now();

    // Log the event when the login page is loaded
    EventLogger.logLoginWithOTPEvent(
      'low',
      timestamp.toString(),
      -1,
      'user',
      'LoginWithOTPStarted',
      'Login with OTP started',
      {
        'userid': 'null',
        'phone no.': '',
        'OTP': '',
      },
    );
  }

  @override
  void dispose() {
    DateTime timestamp = DateTime.now();
    EventLogger.logLoginWithEmailEvent(
      'medium',
      timestamp.toString(),
      -1,
      'user',
      'LoginWithOTPCancelled',
      'login with otp cancelled',
      {},
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 60),
                    Container(
                      alignment: Alignment.center,
                      child: FaIcon(
                        FontAwesomeIcons.personWalkingLuggage,
                        size: 90,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Cheaper and faster delivery',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get great experience with DeliveryX :)',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 35),
                    if (_showPhoneNumberInput)
                      PhoneNumberInputSection(
                        toggleView: _toggleView,
                      )
                    else
                      OTPInputSection(
                        toggleView: _toggleView,
                      ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text('Or'),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              DateTime timestamp = DateTime.now();
                              EventLogger.logLoginWithEmailEvent(
                                'low',
                                timestamp.toString(),
                                -1,
                                'button',
                                'b_LoginWithEmail',
                                'Login with Email button clicked',
                                {},
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.envelope,
                              color: AppColors.black,
                              size: 25,
                            ),
                            label: Text(
                              'Login with Email',
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 18,
                              ),
                            ),
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
                              minimumSize:
                                  const Size(double.infinity, 0), // Full width
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("New user? "),
                          TextButton(
                            onPressed: () {
                              DateTime timestamp = DateTime.now();
                              EventLogger.logLoginWithOTPEvent(
                                'low',
                                timestamp.toString(),
                                -1,
                                'textbutton',
                                'SignUp',
                                'Sign Up text clicked',
                                {},
                              );
                              Fluttertoast.showToast(
                                msg: "To proceed, verify your phone number",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: AppColors.darkgrey,
                                textColor: AppColors.white,
                                fontSize: 16.0,
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          if (allowNavigation) {
            return true; // Allow navigation
          } else {
            // Use SystemNavigator to exit the app.
            SystemNavigator.pop();
            return false; // Returning false to prevent default back button behavior.
          }
        });
  }
}

// toggle view one enter phone number
class PhoneNumberInputSection extends StatefulWidget {
  final void Function() toggleView;

  const PhoneNumberInputSection({super.key, required this.toggleView});

  @override
  _PhoneNumberInputSectionState createState() =>
      _PhoneNumberInputSectionState();
}

class _PhoneNumberInputSectionState extends State<PhoneNumberInputSection> {
  static final TextEditingController _phoneNumberController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedCountryCode = '+91';
  static late String verificationId;
  static late PhoneAuthCredential credential;
  final _db = FirebaseFirestore.instance;
// function to send the otp
  Future<void> sendOTP() async {
    try {
      String phoneNumber = _phoneNumberController.text;
      // Formatting the phonenumber in the required format
      String first = phoneNumber.substring(0, 4);
      String second = phoneNumber.substring(4, 7);
      String third = phoneNumber.substring(7, 10);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "$selectedCountryCode $first $second $third",
        verificationCompleted: (credential) {
          _PhoneNumberInputSectionState.credential = credential;
          setState(() {});
        },
        verificationFailed: (error) {
          print(error);
        },
        codeSent: (verificationId, forceResendingToken) {
          _PhoneNumberInputSectionState.verificationId = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _PhoneNumberInputSectionState.verificationId = verificationId;
          setState(() {});
          // print('Auto retrieval timeout');
        },
        timeout: const Duration(seconds: 30),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number ',
          style: TextStyle(
            // fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: const Color.fromARGB(255, 203, 195, 195),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCountryCode,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCountryCode = newValue!;
                      });
                    },
                    items: <String>['+91', '+1', '+44', '+81']
                        .map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
                child: TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                  return 'Please enter 10 digits';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 203, 195, 195)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () async {
            DateTime timestamp = DateTime.now();
            EventLogger.logLoginWithOTPEvent(
              'low',
              timestamp.toString(),
              -1,
              'button',
              'b_SendOTP',
              'Send OTP button clicked',
              {'phone no': _phoneNumberController.text},
            );
            if (_phoneNumberController.text.isEmpty) {
              Fluttertoast.showToast(
                  msg: "Please Enter Your Number",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: AppColors.darkgrey,
                  textColor: AppColors.white,
                  fontSize: 16.0);
            } else if (int.tryParse(_phoneNumberController.text.toString()) ==
                null) {
              Fluttertoast.showToast(
                  msg: "Please Enter Digits Only",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: AppColors.darkgrey,
                  textColor: AppColors.white,
                  fontSize: 16.0);
            } else if (_phoneNumberController.text.length != 10) {
              Fluttertoast.showToast(
                  msg: "Please Enter Correct Number",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: AppColors.darkgrey,
                  textColor: AppColors.white,
                  fontSize: 16.0);
            } else {
              // sendOTP();
              final snapshot = await _db
                  .collection("users")
                  .where("phone", isEqualTo: _phoneNumberController.text.trim())
                  .get();
              // ignore: unused_local_variable

              List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
                  snapshot.docs;

              // Process the documents
              List<int> role =
                  documents.map((doc) => doc['role'] as int).toList();
              if (snapshot.size != 0 && role[0] != -1) {
                // print("kamchooo majemaaa");
                Fluttertoast.showToast(
                    msg: "You are already logged in to other device",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: AppColors.darkgrey,
                    textColor: AppColors.white,
                    fontSize: 16.0);
                //  Navigator.push(
                //       context, MaterialPageRoute(builder: (c) => RegisterScreen()));
              } else {
                // print("helllllllllllllllllllllllllllo");
                widget.toggleView();
                // List<dynamic> tuple = await AuthService()
                //     .sendOTP(_phoneNumberController.text.trim());
                // _PhoneNumberInputSectionState.verificationId = tuple[0];
                // _PhoneNumberInputSectionState.credential = tuple[1];
                sendOTP();
                // widget.toggleView();
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.black,
            backgroundColor: AppColors.primary, // Text color
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            minimumSize: const Size(double.infinity, 0), // Full width
          ),
          child: Text(
            'Send OTP',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class OTPInputSection extends StatefulWidget {
  final void Function() toggleView;

  const OTPInputSection({super.key, required this.toggleView});

  @override
  _OTPInputSectionState createState() => _OTPInputSectionState();
}

class _OTPInputSectionState extends State<OTPInputSection> {
  final TextEditingController _otpController = TextEditingController();

  final _db = FirebaseFirestore.instance;

  Future<void> verifyOTP() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(_PhoneNumberInputSectionState.credential);
      // print(_PhoneNumberInputSectionState);
      // final user =
      //     AuthService().verifyOTP(_PhoneNumberInputSectionState.credential);
      final user = userCredential.user;

      final snapshot = await _db
          .collection("users")
          .where("phone",
              isEqualTo: _PhoneNumberInputSectionState
                  ._phoneNumberController.text
                  .trim())
          .get();
      if (snapshot.size == 0) {
        Fluttertoast.showToast(
            msg: "Welcome",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            fontSize: 16.0);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) =>
                    RegisterScreen(_PhoneNumberInputSectionState.credential)));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const Onboarding()));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // buildTextField('OTP', Icons.lock, 'Enter the OTP received'),
        const SizedBox(height: 20),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter Otp",
            prefixIcon: const Icon(Icons.lock),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onChanged: (value) {
            _PhoneNumberInputSectionState.credential =
                PhoneAuthProvider.credential(
              verificationId: _PhoneNumberInputSectionState.verificationId,
              smsCode: value,
            );
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            DateTime timestamp = DateTime.now();
            EventLogger.logLoginWithOTPEvent(
              'low',
              timestamp.toString(),
              -1,
              'button',
              'b_LoginWithOtp',
              'Login with OTP button clicked',
              {
                'phone no.':
                    _PhoneNumberInputSectionState._phoneNumberController,
                'user_otp': _otpController.text
              },
            );
            if (_otpController.text.isEmpty) {
              Fluttertoast.showToast(
                  msg: "Please Enter OTP",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: AppColors.darkgrey,
                  textColor: AppColors.white,
                  fontSize: 16.0);
            } else if (int.tryParse(_otpController.text.toString()) == null) {
              Fluttertoast.showToast(
                  msg: "Please Enter Digits Only",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: AppColors.darkgrey,
                  textColor: AppColors.white,
                  fontSize: 16.0);
            } else if (_otpController.text.length != 6) {
              Fluttertoast.showToast(
                  msg: "Please Enter Correct OTP",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: AppColors.darkgrey,
                  textColor: AppColors.white,
                  fontSize: 16.0);
            } else {
              verifyOTP();
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.black,
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            minimumSize: const Size(double.infinity, 0), // Full width
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          onPressed: () {
            widget.toggleView();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.black,
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            minimumSize: const Size(double.infinity, 0), // Full width
          ),
          child: Text(
            'Back',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
