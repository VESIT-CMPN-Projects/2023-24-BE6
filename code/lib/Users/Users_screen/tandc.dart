import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../services/firestore.dart';
import 'eventlogger.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
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
          'T&CPageStarted',
          'Terms and Conditions Page Started',
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
            'T&CPageCancelled',
            'T&C Page Cancelled',
            {'userid': user?.uid},
          );
        }
        // Return true to allow back button press
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Terms and Conditions'),
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
                    'T&CPageCancelled',
                    'Terms and Conditions Page Cancelled',
                    {'userid': user?.uid});
              }
              // Add your event logging here
              print("Back button pressed");
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Service Usage:'),
              _buildSectionContent(
                  'WeFast provides a platform to connect users with reliable delivery services. Users are required to provide accurate information for successful delivery.'),
              _buildSectionTitle('2. Account Registration:'),
              _buildSectionContent(
                  'To access our services, users must create an account. It is the user\'s responsibility to maintain the confidentiality of their account information.'),
              _buildSectionTitle('3. Package Content:'),
              _buildSectionContent(
                  'Users are responsible for the content of their packages. Prohibited items include illegal substances, hazardous materials, and items violating local laws.'),
              _buildSectionTitle('4. Delivery Timelines:'),
              _buildSectionContent(
                  'While we strive for timely deliveries, external factors may affect delivery times. WeFast is not liable for delays caused by unforeseen circumstances.'),
              _buildSectionTitle('5. Service Fees:'),
              _buildSectionContent(
                  'Users agree to pay the designated service fees for each delivery. Fees are determined based on the delivery distance and package size.'),
              _buildSectionTitle('6. User Conduct:'),
              _buildSectionContent(
                  'Users are expected to behave respectfully and refrain from engaging in any unlawful or harmful activities while using our services.'),
              _buildSectionTitle('7. Privacy Policy:'),
              _buildSectionContent(
                  'Our Privacy Policy governs the collection and use of user data. By using our services, users agree to the terms outlined in our Privacy Policy.'),
              _buildSectionTitle('8. Termination of Services:'),
              _buildSectionContent(
                  'WeFast reserves the right to terminate services for users violating the terms and conditions.'),
              _buildSectionTitle('9. Modifications:'),
              _buildSectionContent(
                  'These terms and conditions may be updated from time to time. Users will be notified of any changes.'),
              _buildSectionTitle('Contact Us:'),
              _buildSectionContent(
                  'For any questions or concerns, please contact our customer support.'),
              const SizedBox(height: 20),
              const Text(
                'Thank you for choosing DeliveryX for your package delivery needs!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(content),
    );
  }
}
