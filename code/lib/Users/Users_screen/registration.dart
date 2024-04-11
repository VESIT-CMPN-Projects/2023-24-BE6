import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Onboarding.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../../services/auth.dart';
import '../../main.dart';
import '../../services/firestore.dart';
import '../../util/colors.dart';
import 'login_with_otp.dart';
import 'eventlogger.dart';

class RegisterScreen extends StatefulWidget {
  final PhoneAuthCredential _userCredits;
  const RegisterScreen(this._userCredits, {super.key});
  @override
  _RegisterScreenState createState() => _RegisterScreenState(_userCredits);
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> cities = [
    'Mumbai',
    'Nagpur',
    'Ahmedabad',
    'Bangalore',
    'Chennai',
    'Delhi',
    'Hyderabad',
    'Jaipur',
    'Kolkata',
    'Pune'
  ];

  String? selectedCity;
  // final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final PhoneAuthCredential _userCredits;
  final _db = FirebaseFirestore.instance;

  bool passwordVisible = false;
  _RegisterScreenState(this._userCredits);

  @override
  void initState() {
    super.initState();

    // Log the event when the login page is loaded
    EventLogger.logRegistrationEvent(
      'low',
      DateTime.now().toString(),
      -1,
      'user',
      'RegistrationStarted',
      'Registration started',
      {
        'userid': 'null',
        'email': '',
        'password': '',
      },
    );
  }

  @override
  void dispose() {
    EventLogger.logRegistrationEvent(
      'medium',
      DateTime.now().toString(),
      -1,
      'user',
      'RegistrationCancelled',
      'Registration cancelled',
      {},
    );
    super.dispose();
  }

  Future<void> dataindb(String email) async {
    final snapshot =
        await _db.collection("users").where("email", isEqualTo: email).get();
    if (snapshot.size != 0) {
      Fluttertoast.showToast(
          msg: "Email already in use",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.darkgrey,
          textColor: AppColors.white,
          fontSize: 16.0);
    } else {
      _submit();
    }
  }

  void _submit() async {
    final snapshot = await _db
        .collection("users")
        .where("email", isEqualTo: emailTextEditingController.text.trim())
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;

    // Process the documents
    List<int> role = documents.map((doc) => doc['role'] as int).toList();

    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        try {
          await _firestoreService.addUserToFirestore(
            userId: FirebaseAuth.instance.currentUser!.uid,
            name: nameTextEditingController.text.trim(),
            email: emailTextEditingController.text.trim(),
            phone: phoneTextEditingController.text.trim(),
            location: selectedCity!,
          );

          final emailCredential = EmailAuthProvider.credential(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          );

          // String userId = user.uid;

          await Fluttertoast.showToast(
              msg: "Successfully Registered",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: AppColors.darkgrey,
              textColor: AppColors.white,
              fontSize: 16.0);

          EventLogger.logRegistrationEvent('low', DateTime.now().toString(), -1,
              'button', 'b_CreateAccount', 'Account created successfully', {
            'user_id': FirebaseAuth.instance.currentUser!.uid,
            'name': nameTextEditingController.text.trim(),
            'email': emailTextEditingController.text.trim(),
            'phone': phoneTextEditingController.text.trim(),
            'password': '*' *
                passwordTextEditingController.text.trim().length, //masking
            'location': selectedCity!,
          });

          final User? currentUser = FirebaseAuth.instance.currentUser;
          print(currentUser);
          if (currentUser != null) {
            currentUser.linkWithCredential(_userCredits).then((userCredential) {
              // Linking successful
              print('Successfully linked phone authentication');
              EventLogger.logRegistrationEvent(
                  'high',
                  DateTime.now().toString(),
                  -1,
                  'button',
                  'b_CreateAccount',
                  'Successfully linked phone authentication', {
                'user_id': FirebaseAuth.instance.currentUser!.uid,
                'name': nameTextEditingController.text.trim(),
                'email': emailTextEditingController.text.trim(),
                'phone': phoneTextEditingController.text.trim(),
                'password': '*' *
                    passwordTextEditingController.text.trim().length, //masking
                'location': selectedCity!,
              });
            }).catchError((error) {
              // Handle linking errors
              print('Failed to link phone authentication: $error');
              EventLogger.logRegistrationEvent(
                  'high',
                  DateTime.now().toString(),
                  -1,
                  'button',
                  'b_CreateAccount',
                  error.toString(), {
                'user_id': FirebaseAuth.instance.currentUser!.uid,
                'name': nameTextEditingController.text.trim(),
                'email': emailTextEditingController.text.trim(),
                'phone': phoneTextEditingController.text.trim(),
                'password': '*' *
                    passwordTextEditingController.text.trim().length, //masking
                'location': selectedCity!,
              });
            });

            currentUser
                .linkWithCredential(emailCredential)
                .then((userCredential) {
              // Linking successful
              print('Successfully linked email/password authentication');
            }).catchError((error) {
              // Handle exception error

              EventLogger.logRegistrationEvent(
                'high',
                DateTime.now().toString(),
                -1,
                'user',
                'CreateAccountFailed',
                error.toString(),
                {
                  'userid': 'null',
                  'name': nameTextEditingController.text.trim(),
                  'email': emailTextEditingController.text.trim(),
                  'phone': phoneTextEditingController.text.trim(),
                  'password':
                      '*' * passwordTextEditingController.text.trim().length,
                  'location': selectedCity!,
                },
              );
              // Handle linking errors
              print('Failed to link email/password authentication: $error');
            });
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const Onboarding()),
          );
          // }
        } catch (error) {
          // Handle exception error

          EventLogger.logRegistrationEvent(
            'high',
            DateTime.now().toString(),
            -1,
            'user',
            'CreateAccountFailed',
            error.toString(),
            {
              'userid': 'null',
              'name': nameTextEditingController.text.trim(),
              'email': emailTextEditingController.text.trim(),
              'phone': phoneTextEditingController.text.trim(),
              'password':
                  '*' * passwordTextEditingController.text.trim().length,
              'location': selectedCity!,
            },
          );
          Fluttertoast.showToast(msg: "Error occurred:\n$error");
        }
      } else {
        Fluttertoast.showToast(msg: "Not all fields are valid");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Container(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.inputBorder,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.arrowLeft,
                        color: AppColors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 30,
                    ),
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
                buildTextField('Full Name (AS PER AADHAR)', Icons.person,
                    'Enter your name', controller: nameTextEditingController,
                    validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (!RegExp(r"^[a-zA-Z ]+$").hasMatch(value)) {
                    return 'Name should only contain alphabets';
                  }
                  return null;
                }),
                const SizedBox(height: 16),
                const Text(
                  'City/Province',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  // onTap: () {},
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                      // Log the event when the city is selected
                      EventLogger.logRegistrationEvent(
                          'low',
                          DateTime.now().toString(),
                          -1,
                          'dropdown',
                          'dd_City',
                          'City textfield entered', {});
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a city/province';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.location_city, color: AppColors.primary),
                    hintText: 'Select a city/province',
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.inputBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                buildTextField(
                  'Phone Number',
                  Icons.phone,
                  'Enter your number',
                  controller: phoneTextEditingController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Please enter 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                buildTextField('Email', Icons.email, 'Enter your email',
                    controller: emailTextEditingController, validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                          r"^([a-zA-Z0-9\._]+)@([a-zA-Z0-9])+.([a-z]+)(.[a-z]+)?$")
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }),
                const SizedBox(height: 16),
                PasswordTextField(
                  label: 'Password',
                  icon: Icons.lock,
                  hint: 'Create your password',
                  controller: passwordTextEditingController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    if (!RegExp(
                            r'^(?=.*?[A-Za-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$')
                        .hasMatch(value)) {
                      return 'Must include letters, numbers and special characters';
                    }
                    return null;
                  },
                  isPasswordVisible: passwordVisible,
                  onVisibilityChanged: (isVisible) {
                    setState(() {
                      passwordVisible = isVisible;
                    });
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      dataindb(emailTextEditingController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      backgroundColor: AppColors.primary, // Text color
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                      minimumSize: const Size(double.infinity, 0), // Full width
                    ),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Implement Already Have Account logic here
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const LoginScreenOTP()));

                    EventLogger.logRegistrationEvent(
                      'low',
                      DateTime.now().toString(),
                      -1,
                      'textbutton',
                      'Sign in',
                      'Sign in text clicked',
                      {},
                    );
                  },
                  child: Center(
                    child: Text(
                      'Already have an account? Sign in',
                      style: TextStyle(color: AppColors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          onTap: () {
            // Trigger event log when the text field is selected
            EventLogger.logRegistrationEvent(
              'low',
              DateTime.now().toString(),
              -1,
              'textfield',
              'tf_$label',
              '$label textfield tapped',
              {},
            );
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            hintText: hint,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool isPasswordVisible;
  final Function(bool) onVisibilityChanged;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.validator,
    required this.isPasswordVisible,
    required this.onVisibilityChanged,
  });
  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: !widget.isPasswordVisible, // Toggle password visibility
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onTap: () {
            EventLogger.logRegistrationEvent(
              'low',
              DateTime.now().toString(),
              -1,
              'textfield',
              'tf_Password',
              'password textfield tapped',
              {},
            );
          },
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, color: AppColors.primary),
            hintText: widget.hint,
            suffixIcon: IconButton(
              icon: Icon(
                widget.isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: AppColors.primary,
              ),
              onPressed: () {
                widget.onVisibilityChanged(!widget.isPasswordVisible);
                EventLogger.logRegistrationEvent(
                  'low',
                  DateTime.now().toString(),
                  -1,
                  'button',
                  'b_visiblity',
                  'password visibilty button pressed',
                  {},
                );
              },
            ),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}
