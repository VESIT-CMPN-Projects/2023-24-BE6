// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:deliveryx/provider/senderProvider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:flutter/material.dart';

// class SenderPayment extends StatefulWidget {
//   final double totalCost;

//   const SenderPayment({Key? key, required this.totalCost}) : super(key: key);

//   @override
//   _SenderPaymentState createState() => _SenderPaymentState();
// }

// class _SenderPaymentState extends State<SenderPayment> {
//   Razorpay? _razorpay;
//   late Sender sender;
//   Future<void> addCostToOrder(String orderId, double totalCost) async {
//     try {
//       print('order id inside the addCostToOrder Function is $orderId');
//       final currentUser = FirebaseAuth.instance.currentUser;
//       final orderInfo = FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser?.uid)
//           .collection('orders')
//           .doc(orderId)
//           .set({'Package Cost': totalCost});
//     } catch (e) {
//       print('here is the errorrrrrrrr $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       sender = Provider.of<SenderProvider>(context).sender;
//     });
//     _razorpay = Razorpay();
//     _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

//     //openPaymentPortal();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _razorpay?.clear();
//   }

//   void openPaymentPortal() async {
//     var options = {
//       'key': 'rzp_test_Vw073g37PkRRx0',
//       'amount': (widget.totalCost * 100).toInt(), // Convert totalCost to paisa
//       'name': 'jhon',
//       'description': 'Payment',
//       'prefill': {'contact': '9999999999', 'email': 'jhon@razorpay.com'},
//       'external': {
//         'wallets': ['paytm']
//       }
//     };
//     try {
//       _razorpay?.open(options);
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     addCostToOrder(sender.orderId, widget.totalCost);
//     print("------------->inside handlePaymentSuccess wala ");
//     print(sender.orderId);
//     Fluttertoast.showToast(
//         msg: "SUCCESS PAYMENT: ${response.paymentId}", timeInSecForIosWeb: 4);
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     Fluttertoast.showToast(
//         msg: "ERROR HERE: ${response.code} - ${response.message}",
//         timeInSecForIosWeb: 4);
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Fluttertoast.showToast(
//         msg: "EXTERNAL_WALLET IS : ${response.walletName}",
//         timeInSecForIosWeb: 4);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Loading Animation'),
//       ),
//       body: const Center(
//         child:
//             CircularProgressIndicator(), // Display circular progress indicator
//       ),
//     );
//     // return Scaffold(
//     //   appBar: AppBar(
//     //     elevation: 0,
//     //     backgroundColor: Colors.white,
//     //     centerTitle: true,
//     //     leading: IconButton(
//     //       icon: Icon(Icons.arrow_back, color: Colors.blue.shade900),
//     //       onPressed: () {
//     //         Navigator.of(context).pop();
//     //       },
//     //     ),
//     //     title: const Text('Payment',
//     //         style: TextStyle(fontSize: 22.0, color: Color(0xFF545D68))),
//     //   ),
//     //   body: Column(children: [
//     //     const SizedBox(height: 16.0),
//     //     Center(
//     //       child: Padding(
//     //         padding: const EdgeInsets.all(8.0),
//     //         child: Card(
//     //           child: Column(
//     //             children: <Widget>[
//     //               Text(
//     //                 '${widget.totalCost}',
//     //                 style: TextStyle(
//     //                     fontSize: 22.0,
//     //                     fontWeight: FontWeight.bold,
//     //                     color: Colors.blue.shade900),
//     //               ),
//     //               const SizedBox(height: 10.0),
//     //               const Text("Fish",
//     //                   style: TextStyle(color: Colors.grey, fontSize: 24.0)),
//     //             ],
//     //           ),
//     //         ),
//     //       ),
//     //     ),
//     //     const SizedBox(height: 18.0),
//     //     InkWell(
//     //         onTap: () {
//     //           openPaymentPortal();
//     //         },
//     //         child: Padding(
//     //           padding: const EdgeInsets.only(left: 18.0, right: 18),
//     //           child: Container(
//     //               width: MediaQuery.of(context).size.width - 60.0,
//     //               height: 50.0,
//     //               decoration: BoxDecoration(
//     //                   borderRadius: BorderRadius.circular(20.0),
//     //                   color: Colors.blue.shade900),
//     //               child: Center(
//     //                   child: Text('Pay',
//     //                       style: TextStyle(
//     //                           fontSize: 16.0,
//     //                           fontWeight: FontWeight.w900,
//     //                           color: Colors.blue.shade50)))),
//     //         ))
//     //   ]),
//     // );
//   }
// }
