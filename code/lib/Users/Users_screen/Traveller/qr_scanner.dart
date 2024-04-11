import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/scan_package_sender.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../../services/auth.dart';
import '../eventlogger.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final AuthService _authService = AuthService();

  String _scanBarcode = 'Unknown';
  bool scanSuccess = false;

  @override
  void initState() {
    super.initState();
    EventLogger.logQRScannerEvent(
      'low',
      DateTime.now().toString(),
      1,
      'traveler',
      'QRScanPageViewed',
      'QR Scan Page viewed',
      {'travelerid': ''},
    );
  }

  void logQRScannerbuttonclicked() {
    EventLogger.logQRScannerEvent(
      'low',
      DateTime.now().toString(),
      1,
      'traveler',
      'b_ScanQR',
      'QR scanner button clicked',
      {
        'travelerid': '',
      },
    );
  }

  void logQRScannerResult(String eventType, String message) {
    EventLogger.logQRScannerEvent(
      'high',
      DateTime.now().toString(),
      1,
      'traveler',
      eventType,
      message,
      {
        'travelerid': '',
      },
    );
  }

  Future<void> scanQR() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    String barcodeScanRes;
    // Log the event for starting qr scan
    EventLogger.logQRScannerEvent(
      'low',
      DateTime.now().toString(),
      1,
      'traveler',
      'QRScanStarted',
      'QR scan started',
      {'travelerid': ''},
    );
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
      print(currentUser?.uid);

      // Check if the scanned order ID exists in the AcceptedOrders collection
      var acceptedOrderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('travelers')
          .doc(currentUser?.uid)
          .collection('Accepted orders')
          .doc(barcodeScanRes)
          .get();

      // print(acceptedOrderDoc);
      print(acceptedOrderDoc.id);
      // print(barcodeScanRes);

      if (acceptedOrderDoc.exists && acceptedOrderDoc.id == barcodeScanRes) {
        //if scanner matches
        scanSuccess = true;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ScanPackageSender(barcodeScanRes: barcodeScanRes)),
        );
      } else {
        //if scanner doesn't match
        Navigator.pop(context);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(scanSuccess ? 'Scan successful' : 'Scan failed'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Log the event based on scan success or failure
    if (scanSuccess) {
      logQRScannerResult('QRScanSuccessfull', 'QR scanner successful');
    } else {
      logQRScannerResult('QRScanFailed', 'QR scanner failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final user = await _authService.getCurrentUser();
        EventLogger.logQRScannerEvent(
            'medium',
            DateTime.now().toString(),
            1,
            'traveler',
            'QRScanCancelled',
            'QR Scan Page Cancelled',
            {'travelerid': user?.uid});
        return true;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('QR Scanner'),
            backgroundColor: AppColors.primary,
            toolbarHeight: 80,
          ),
          backgroundColor: Colors.grey[200],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 100,
                  ),
                  const Icon(Icons.qr_code_scanner, size: 80),
                  const SizedBox(height: 20),
                  // ElevatedButton.icon(
                  //   onPressed: () async {
                  //     await scanQR();
                  //   },
                  //   icon: Icon(Icons.camera_alt),
                  //   label: Text('Start QR Scan'),
                  //   style: ElevatedButton.styleFrom(
                  //     primary: Colors.blue,
                  //     onPrimary: Colors.white,
                  //     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  //     textStyle: TextStyle(fontSize: 20),
                  //   ),
                  // ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(20),
                      side: const BorderSide(
                        width: 2,
                        color: Color(0xFFA084E8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                      minimumSize: const Size(double.infinity, 0), // Full width
                    ),
                    onPressed: () async {
                      logQRScannerbuttonclicked();
                      await scanQR();
                    },
                    child: const Text(
                      'Scan QR',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 250,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _scanBarcode == 'Unknown'
                          ? Colors.transparent
                          : const Color(0xFFA084E8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        'Scan result : $_scanBarcode\n',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
