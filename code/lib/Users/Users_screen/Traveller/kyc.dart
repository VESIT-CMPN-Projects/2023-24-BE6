import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/backend/kycapi.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'face_detector.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  _KYCScreenState createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  String? aadharVerificationResult;
  String? panVerificationResult;
  TextEditingController aadhaarController = TextEditingController();
  TextEditingController panController = TextEditingController();

  @override
  void dispose() {
    aadhaarController.dispose();
    panController.dispose();
    super.dispose();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.black,
      textColor: AppColors.white,
      fontSize: 16.0,
    );
  }

  Future<String?> checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    print(user);
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final name = userData['name'];
        return name;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        backgroundColor: AppColors.primary,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              InkWell(
                onTap: () async {
                  // final currentUser = FirebaseAuth.instance.currentUser;
                  // await FirebaseFirestore.instance
                  //     .collection("users")
                  //     .doc(currentUser!.uid)
                  //     .collection("wallet")
                  //     .add({
                  //   "balance": 50,
                  // });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FaceDetector()),
                  );
                },
                child: const Text(
                  'Aadhaar Verification',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your Aadhaar and PAN details',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 35),
              buildTextField('Aadhaar Number', Icons.credit_card,
                  'Enter your Aadhaar number', TextInputType.number, (value) {
                if (value == null || value.isEmpty) {
                  return 'Aadhar is required';
                }
                if (int.tryParse(value) == null || value.length != 12) {
                  return 'Invalid Aadhar Number';
                }
                return null;
              }, aadhaarController),
              const SizedBox(height: 16),
              buildTextField('PAN Number', Icons.person,
                  'Enter your PAN number', TextInputType.text, (value) {
                if (value == null || value.isEmpty) {
                  return 'PAN is required';
                }
                if (value.length != 10) {
                  return 'Invalid PAN Number';
                }
                return null;
              }, panController),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Verifying Aadhar...'),
                              SizedBox(height: 10),
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      });
                  String aadhaarNumber = aadhaarController.text;
                  String panNumber = panController.text;
                  print(aadhaarNumber);

                  aadharVerificationResult = await verifyAadhar(aadhaarNumber);

                  Map<String, String?> panVerificationResultMap =
                      await verifyPan(panNumber);

                  String? panName =
                      panVerificationResultMap['fullName']?.toLowerCase();
                  String? maskedAadhaar =
                      panVerificationResultMap['maskedAadhaar'];

                  final name = await checkUserRole();
                  final CollectionName = name?.toLowerCase();

                  bool last4DigitsMatch = false;
                  print("masked");
                  print(maskedAadhaar);
                  if (maskedAadhaar != null && aadhaarNumber.length >= 4) {
                    String last4Input =
                        aadhaarNumber.substring(aadhaarNumber.length - 4);
                    print("last4");
                    print(last4Input);
                    String last4Masked =
                        maskedAadhaar.substring(maskedAadhaar.length - 4);
                    print("last4masked");
                    print(last4Masked);
                    last4DigitsMatch = last4Input == last4Masked;
                  }

                  if (aadharVerificationResult == 'completed' &&
                      panName == CollectionName &&
                      last4DigitsMatch) {
                    Navigator.of(context).pop();
                    showToast('Aadhar and PAN verified successfully');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FaceDetector()),
                    );

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final userRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid);

                      await userRef.update({
                        'Aadhar Number': aadhaarNumber,
                        'PAN Number': panNumber,
                      });
                    }
                  } else {
                    if (aadharVerificationResult != 'completed') {
                      Navigator.of(context).pop();
                      showToast('Aadhar is invalid');
                    } else if (panName != CollectionName) {
                      Navigator.of(context).pop();
                      showToast(
                          'PAN verification failed or Name is not as per Aadhar');
                    } else if (!last4DigitsMatch) {
                      Navigator.of(context).pop();
                      showToast('Aadhar verification failed.');
                    }
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
                child: const Text(
                  'Verify Aadhaar and PAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      IconData icon,
      String hint,
      TextInputType? keyboardType,
      FormFieldValidator<String>? validator,
      TextEditingController controller,
      {bool isPassword = false}) {
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
          keyboardType: keyboardType,
          validator: validator,
          controller: controller,
          obscureText: isPassword,
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
