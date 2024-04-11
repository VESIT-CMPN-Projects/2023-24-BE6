import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../services/firestore.dart';

import '../eventlogger.dart';

class QRCodeGenerator extends StatefulWidget {
  final String orderId;

  const QRCodeGenerator({Key? key, required this.orderId}) : super(key: key);

  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  final FirestoreService _firestoreService = FirestoreService();
  String? senderId;

  @override
  void initState() {
    super.initState();
    _getSenderId();
  }

  Future<void> _getSenderId() async {
    senderId = await _firestoreService.getUserId();

    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'ViewQR',
      'QR page viewed',
      {
        'senderid': senderId,
        'orderid': widget.orderId,
      },
    );
  }

  @override
  void dispose() {
    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'ViewQRCanceled',
      'QR view canceled',
      {'senderid': senderId},
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        backgroundColor:
            const Color(0xFFA084E8), // Set the background color to purple
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: widget.orderId,
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
            const SizedBox(height: 20.0) // Display the encoded data
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: QRCodeGenerator(orderId: 'Your QR Code Data'),
    ),
  );
}
