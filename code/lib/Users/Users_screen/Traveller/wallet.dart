import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Wallet> {
  bool isBalance = true;
  double totalBalance = 0;

  getWalletAmount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      var walletRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser!.uid)
          .collection("travelers")
          .doc(currentUser.uid)
          .get();
      var balance = walletRef['Wallet Balance'];
      setState(() {
        totalBalance = balance;
      });
    } catch (e) {
      setState(() {
        isBalance = false;
      });
    }
  }

  @override
  void initState() {
    getWalletAmount();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primary, title: const Text("My Wallet")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Balance:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${totalBalance.toInt()}', // Replace with actual balance value
                    style: TextStyle(
                      fontSize: 50,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rupees', // Replace with actual balance value
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add functionality for adding money to the wallet
                  // You can navigate to another screen or show a dialog for adding money
                },
                child: const Text('Add Money'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add functionality for making payments
                  // You can navigate to another screen or show a dialog for making payments
                },
                child: const Text('Withdraw Money'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
