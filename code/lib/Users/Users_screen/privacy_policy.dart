import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../services/firestore.dart';
import 'eventlogger.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
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
          'PrivacyPolicyPageStarted',
          'Privacy Policy Page Started',
          {'userid': user?.uid},
        );
      }
    } catch (e) {
      print("Error logging event on initialization: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final user = await _authService.getCurrentUser();
        final userData = await _firestoreService.getUserData();
        if (userData != null) {
          final role = userData["role"];
          DateTime timestamp = DateTime.now();
          EventLogger.logProfileEvent(
            'low',
            timestamp.toString(),
            role,
            'sender',
            'PrivacyPolicyPageCancelled',
            'Privacy Policy Page cancelled',
            {'userid': user?.uid},
          );
        }
        // Return true to allow back button press
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DeliveryX Privacy Policy'),
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final user = await _authService.getCurrentUser();
              final userData = await _firestoreService.getUserData();
              if (userData != null) {
                final role = userData["role"];
                DateTime timestamp = DateTime.now();
                EventLogger.logProfileEvent(
                    'low',
                    timestamp.toString(),
                    role,
                    'sender',
                    'PrivacyPolicyPageCancelled',
                    'Privacy Policy Page cancelled',
                    {'userid': user?.uid, 'role': role});
              }
              // Add your event logging here
              print("Back button pressed");
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction and General Privacy Policy
              Text(
                'Introduction',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Welcome to DeliveryX, the package delivery application. This privacy policy '
                'explains how we collect, use, and safeguard your information as a user of our service.'
                '\n\nBy using DeliveryX, you agree to the terms outlined in this policy.',
              ),

              // Sender Privacy Policy
              const SizedBox(height: 20.0),
              Text(
                'Privacy Policy for Senders',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 10.0),

              const Text(
                'As a sender using DeliveryX, we collect the following information:'
                '\n- Name'
                '\n- Email'
                '\n- Location'
                '\n- Phone Number'
                '\n- Parcel Details'
                '\n- Source and Destination Locations'
                '\n\nWe use this information solely for the purpose of managing and delivering your packages. '
                'We do not share this information with third parties except as required for the delivery process.'
                '\n\nFor any concerns or requests regarding your data, please contact us at delivery0x0@gmail.com.',
              ),

              // Traveler Privacy Policy
              const SizedBox(height: 20.0),
              Text(
                'Privacy Policy for Travelers',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'As a traveler using DeliveryX, we collect the following information:'
                '\n- Name'
                '\n- Email'
                '\n- Location'
                '\n- Parcel Details'
                '\n- Source and Destination Locations'
                '\n- Aadhaar Number'
                '\n- PAN'
                '\n- Live Face ID'
                '\n- Bank Details for Wallet'
                '\n\nThis information is collected for user verification and payment processing purposes. '
                'We take appropriate measures to secure and protect this sensitive information.'
                '\n\nFor any concerns or requests regarding your data, please contact us at delivery0x0@gmail.com.',
              ),

              // Conclusion
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
