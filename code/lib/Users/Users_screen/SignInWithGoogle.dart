import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth.dart';
import 'Onboarding.dart';

class SignInWithGoogle extends StatefulWidget {
  const SignInWithGoogle({super.key});

  @override
  State<SignInWithGoogle> createState() => _SignInWithGoogleState();
}

class _SignInWithGoogleState extends State<SignInWithGoogle> {
  final AuthService _authService = AuthService();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  bool passwordVisible = false;

  void _login() async {
    try {
      final user = await _authService.signInWithEmailAndPassword(
        emailTextEditingController.text.trim(),
        passwordTextEditingController.text.trim(),
      );

      if (user != null) {
        // await storage.write(key: "token", value: "your_token_here");
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const Onboarding()));
      } else {
        // Handle login failure
        _showDialog("Login Failed", "Invalid credentials. Please try again.");
      }
    } catch (error) {
      // Handle login error
      print(error);
      _showDialog("Login Error", "An error occurred while logging in.");
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

  final _formKey = GlobalKey<FormState>();
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
              children: <Widget>[
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
                buildTextField('Email', Icons.email, 'Enter your email',
                    emailTextEditingController, validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                          //r"^(?!.*(\.{1,}|[-!#$%&\'*+/=?^_`{|~]))[a-zA-Z0-9.!#$%&\'*+\/=?^_`{|~-]{1,64}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          r"^([a-zA-Z0-9\._]+)@([a-zA-Z0-9])+.([a-z]+)(.[a-z]+)?$")
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }),
                const SizedBox(height: 16),
                buildTextField(
                  'Password',
                  Icons.lock,
                  'Enter your password',
                  isPassword: true,
                  passwordTextEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Perform registration logic
                        _login();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Onboarding()),
                        );
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
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, String hint,
      TextEditingController controller,
      {bool isPassword = false,
      TextInputType? keyboardType,
      FormFieldValidator<String>? validator}) {
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
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator, // Validator function
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
