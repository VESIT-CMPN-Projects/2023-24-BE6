import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth.dart';
import '../../util/colors.dart';
import 'login_with_otp.dart';
import 'onboarding.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'eventlogger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  bool passwordVisible = false;
  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    // Log the event when the login page is loaded
    EventLogger.logLoginWithEmailEvent(
      'low',
      DateTime.now().toString(),
      -1,
      'user',
      'LoginWithEmailStarted',
      'Login with email started',
      {
        'userid': 'null',
        'email': '',
        'password': '',
      },
    );
  }

  // @override
  // void dispose() {
  //
  //   EventLogger.logLoginWithEmailEvent(
  //     'medium',
  //     DateTime.now().toString(),
  //     -1,
  //     'user',
  //     'LoginWithEmailCancelled',
  //     '',
  //     {},
  //   );
  //   super.dispose();
  // }

  void _login() async {
    final snapshot = await _db
        .collection("users")
        .where("email", isEqualTo: emailTextEditingController.text.trim())
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;

    // Process the documents
    List<int> role = documents.map((doc) => doc['role'] as int).toList();

    // Log the event when the login button is clicked
    EventLogger.logLoginWithEmailEvent('low', DateTime.now().toString(), role[0],
        'button', 'b_LoginWithEmail', 'Login with email button clicked', {
      'email': emailTextEditingController.text.trim(),
      'password':
          '*' * passwordTextEditingController.text.trim().length, //masking
    });

    if (snapshot.size != 0 && role[0] != -1) {
      EventLogger.logLoginWithEmailEvent(
        'high',
        DateTime.now().toString(),
        role[0],
        'user',
        'LoginWithEmailFailed',
        'User logged in to other device',
        {
          'userid': 'null',
          'email': emailTextEditingController.text.trim(),
          'password': '*' * passwordTextEditingController.text.trim().length,
        },
      );

      Fluttertoast.showToast(
          msg: "You are already logged in to other device",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.darkgrey,
          textColor: AppColors.white,
          fontSize: 16.0);
    } else {
      try {
        final user = await _authService.signInWithEmailAndPassword(
          emailTextEditingController.text.trim(),
          passwordTextEditingController.text.trim(),
        );

        if (user != null) {
          String userId = user.uid;

          // Log the event when the login is successfull
          EventLogger.logLoginWithEmailEvent(
              'medium',
              DateTime.now().toString(),
              role[0],
              'user',
              'LoginWithEmailSuccessful',
              'Login with email successful', {
            'userid': userId,
            'email': emailTextEditingController.text.trim(),
            'password': '*' *
                passwordTextEditingController.text.trim().length, //masking
          });

          Navigator.push(
              context, MaterialPageRoute(builder: (c) => const Onboarding()));
        } else {
          // Handle login failure

          EventLogger.logLoginWithEmailEvent(
            'high',
            DateTime.now().toString(),
            role[0],
            'user',
            'LoginWithEmailFailed',
            'Invalid Credentials',
            {
              'userid': 'null',
              'email': emailTextEditingController.text.trim(),
              'password':
                  '*' * passwordTextEditingController.text.trim().length,
            },
          );
          _showDialog("Login Failed", "Invalid credentials. Please try again.");
        }
      } catch (error) {
        // Handle exception error

        EventLogger.logLoginWithEmailEvent(
          'high',
          DateTime.now().toString(),
          role[0],
          'user',
          'LoginWithEmailFailed',
          error.toString(),
          {
            'userid': 'null',
            'email': emailTextEditingController.text.trim(),
            'password': '*' * passwordTextEditingController.text.trim().length,
          },
        );

        _showDialog("Login Error", "An error occurred while logging in.");
      }
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          EventLogger.logLoginWithEmailEvent(
            'medium',
            DateTime.now().toString(),
            -1,
            'user',
            'LoginWithEmailCancelled',
            '',
            {},
          );
          return true; // Return true to allow the navigation
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    alignment: Alignment.center,
                    child: FaIcon(
                      FontAwesomeIcons.truckFast,
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
                  TextFormField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: AppColors.primary),
                      hintText: "Email",
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordTextEditingController,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                      hintText: "Password",
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (passwordTextEditingController.text
                                  .toString()
                                  .isEmpty &&
                              emailTextEditingController.text
                                  .toString()
                                  .isEmpty) {
                            _showDialog("Enter your Login Credentials",
                                "Please Enter your Email and Password");
                          } else if (passwordTextEditingController.text
                              .toString()
                              .isEmpty) {
                            _showDialog("Enter your Login Credentials",
                                "Please Enter your Password");
                          } else if (emailTextEditingController.text
                              .toString()
                              .isEmpty) {
                            _showDialog("Enter your Login Credentials",
                                "Please Enter your Email");
                          } else if (!RegExp(
                                  r"^([a-zA-Z0-9\._]+)@([a-zA-Z0-9])+.([a-z]+)(.[a-z]+)?$")
                              .hasMatch(
                                  emailTextEditingController.text.toString())) {
                            _showDialog("Incorrect Email",
                                "Please Enter a Valid Email");
                          } else {
                            _login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.black,
                          backgroundColor: AppColors.primary, // Text color
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                          //minimumSize: Size(double.infinity, 0), // Full width
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          EventLogger.logLoginWithEmailEvent(
                            'low',
                            DateTime.now().toString(),
                            -1,
                            'button',
                            'b_LoginWithOTP',
                            'Login with OTP button clicked',
                            {},
                          );

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const LoginScreenOTP()));
                        },
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
                          //minimumSize: Size(double.infinity, 0), // Full width
                        ),
                        child: Text(
                          'Login with Phone Number',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New user? "),
                      TextButton(
                        onPressed: () {
                          EventLogger.logLoginWithEmailEvent(
                            'low',
                            DateTime.now().toString(),
                            -1,
                            'textbutton',
                            'SignUp',
                            'Sign Up text clicked',
                            {},
                          );

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const LoginScreenOTP()));
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
