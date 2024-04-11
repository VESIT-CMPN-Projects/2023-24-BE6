import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../services/firestore.dart';
import 'eventlogger.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
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
          'FAQPageStarted',
          'FAQ Page Started',
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
            'FAQPageCancelled',
            'FAQ Page Cancelled',
            {'userid': user?.uid},
          );
        }
        // Return true to allow back button press
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FAQ'),
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
                    'FAQPageCancelled',
                    'FAQ Page Cancelled',
                    {'senderid': user?.uid, 'role': role});
              }
              // Add your event logging here
              print("Back button pressed");
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFAQItem(
              question: 'Q. How can I track my package?',
              answer:
                  '- You can track your package by logging into your account on our app. Find the "Track Package" option in the menu. Enter the tracking number provided to you during shipment.',
            ),
            _buildFAQItem(
              question: 'Q. What happens if I miss a package delivery?',
              answer:
                  '- If you miss a delivery, a notification will be sent to reschedule. Depending on the courier, they might attempt delivery again or provide instructions for pick-up at a nearby location.',
            ),
            _buildFAQItem(
              question:
                  'Q. Can I change the delivery address after placing an order?',
              answer:
                  '- Changing the delivery address after placing an order may not be possible in certain cases. Please contact our customer support for assistance, and we will do our best to help.',
            ),
            _buildFAQItem(
              question: 'Q. How do I report a missing or damaged package?',
              answer:
                  '- In case of a missing or damaged package, please contact our customer support immediately. Provide detailed information about the issue, and we will initiate an investigation.',
            ),
            _buildFAQItem(
              question:
                  'Q. What are the delivery timeframes for standard shipping?',
              answer:
                  '- The delivery timeframes for standard shipping vary based on your location and the courier service used. You can check the estimated delivery date during the checkout process.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary,
          width: 2, // You can adjust the width of the border as needed
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
