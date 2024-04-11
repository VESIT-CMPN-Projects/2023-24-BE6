import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/current_user_location.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/main_traveller.dart';
import 'package:deliveryx/services/firestore.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

import '../../../services/auth.dart';
import '../eventlogger.dart';

class OrderClickT extends StatefulWidget {
  final String? senderId;
  final String? orderId;
  // final String? status;
  final bool showdeliverbutton;

  const OrderClickT(
      {super.key,
      required this.senderId,
      // required this.status,
      required this.orderId,
      required this.showdeliverbutton});

  @override
  State<OrderClickT> createState() => _OrderClickTState();
}

class _OrderClickTState extends State<OrderClickT> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final currentUser = FirebaseAuth.instance.currentUser;

  String senderAddress = '';
  String senderName = '';
  String senderInstruction = '';
  String receiverAddress = '';
  String receiverName = '';
  String pCategory = '';
  String pDescription = '';
  String pWeight = '';
  String pSize = '';
  //random cost generation--we will later replace by actual calcualted costs
  var cost = Random().nextInt(100) + 100;
  String senderId = '';
  bool handleWithCare = true; /////////for displaying tag
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _logOrderSummaryViewed();
    getInfo();
  }

  void toggleImage() {
    setState(() {
      isVisible = !isVisible; // Toggle visibility
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logOrderSummaryViewed() async {
    final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logOrderSummaryEvent(
        'low',
        DateTime.now().toString(),
        role,
        'traveler',
        'OrderSummaryViewed',
        'Order summary page viewed',
        {
          'orderid': widget.orderId,
          'travelerid': travelerId
          // 'status': widget.status,
        },
      );
    }
  }

  Future<bool?> checkOrderStatus() async {
    try {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.senderId)
          .collection('orders')
          .doc(widget.orderId)
          .get();

      print("Currentuser ID");
      print(currentUser?.uid);

      print("TRAVELER ID");
      print(docSnapshot['travelerId']);

      if (docSnapshot['travelerId'] == currentUser?.uid &&
          docSnapshot['Status'] == 'Processing') {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 5), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GetUserCurrentLocationScreen(
                    prevPage: 1,
                    orderId: widget.orderId,
                    senderId: senderId,
                  ),
                ),
              );
            });

            return GiffyDialog.image(
              Image.network(
                "https://media.giphy.com/media/H2Q7zcxQfbCIUNlLHe/giphy.gif?cid=ecf05e47lctjjc5w1vwew0rgfkokt6bof5uk5hlozs5dk32f&ep=v1_gifs_search&rid=giphy.gif&ct=g",
                height: 200,
                fit: BoxFit.cover,
              ),
              title: const Text(
                'Successful',
                textAlign: TextAlign.center,
              ),
              content: const Text(
                'Your Delivery Request has been Confirmed',
                textAlign: TextAlign.center,
              ),
            );
          },
        );

        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Handle errors here
      print('Error: $e');
    }
    return false;
  }

  Future<void> getInfo() async {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.senderId)
          .collection('orders')
          .doc(widget.orderId);
      DocumentSnapshot documentSnapshot = await documentReference.get();

      setState(() {
        senderAddress = documentSnapshot['Sender Address'];
        senderName = documentSnapshot['Sender Name'];
        try {
          senderInstruction = documentSnapshot['Instruction for Traveler'];
        } catch (e) {
          print(e);
        }
        receiverAddress = documentSnapshot['Receiver Address'];
        receiverName = documentSnapshot['Receiver Name'];
        pCategory = documentSnapshot['Package Category'];
        pDescription = documentSnapshot['Package Description'];
        pWeight = documentSnapshot['Package Weight'];
        pSize = documentSnapshot['Package Size'];
        senderId = documentSnapshot['userid'];
      });
    } catch (error) {
      print('Error fetching document data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final user = await _authService.getCurrentUser();
        EventLogger.logContinueDeliveringEvent(
            'medium',
            DateTime.now().toString(),
            1,
            'traveler',
            'OrderSummaryCancelled',
            'Order Summary Page Cancelled',
            {'travelerid': user?.uid});
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: const Text("Order Summary")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //CHILD-1 Category and Item Name
                const Text("Category",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(
                  height: 10,
                ),

                // Category Details
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.inputBorder,
                        width: 1,
                      )),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/third-party_images/icons/box.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 16),
                      Text(pCategory, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                //CHILD-2 (optional) Package Description
                if (pDescription.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Package Description",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.inputBorder,
                              width: 1,
                            )),
                        child: Text(
                          pDescription,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                //CHILD-3 (optional) Instruction for Traveler
                if (senderInstruction.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Instruction for Traveler",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.inputBorder,
                              width: 1,
                            )),
                        child: Text(
                          senderInstruction,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (handleWithCare) // Show image if handleWithCare is true
                        Image.asset(
                          'assets/third-party_images/images/fragiletag.jpg',
                          width: 144,
                          height: 60,
                        ),
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.inputBorder,
                              width: 1,
                            )),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              toggleImage();
                            });
                          },
                          child: const Text('Size Guide',
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Visibility(
                        visible: isVisible,
                        child: Image.asset(
                            'assets/third-party_images/images/sizeguide.jpg'),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),

                // const SizedBox(height: 16),

                //CHILD-4 (2 COLUMNs INSIDE ROW)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //COLUMN 1 weight
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Weight",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),

                          // Weight Details
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.inputBorder,
                                  width: 1,
                                )),
                            child: Row(
                              children: [
                                Text(pWeight,
                                    style: const TextStyle(fontSize: 16)),
                                // const SizedBox(width: 20),
                                // Container(
                                //   height: 16,
                                //   width: 1,
                                //   color: Colors.grey,
                                // ),
                                // const SizedBox(width: 8),
                                // const Text('kg', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 30,
                    ),

                    //COLUMN 2 size
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Dimension:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),

                          // dimension Details
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.inputBorder,
                                  width: 1,
                                )),
                            child: Row(
                              children: [
                                Text(pSize,
                                    style: const TextStyle(fontSize: 16)),
                                // const SizedBox(width: 20),
                                // Container(
                                //   height: 16,
                                //   width: 1,
                                //   color: Colors.grey,
                                // ),
                                // const SizedBox(width: 8),
                                // const Text('cm', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),

                //CHILD 5- orderid
                const Text("Order ID",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(
                  height: 10,
                ),

                // CHILD 6- Category Details(Pick up and Drop)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.inputBorder,
                        width: 1,
                      )),
                  child: Row(
                    children: [
                      const Icon(Icons.numbers_outlined, size: 18),
                      const SizedBox(width: 16),
                      Text("${widget.orderId}",
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),

                //CHILD-6 pickup location (sender's address)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pickup Location",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.inputBorder,
                            width: 1,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          senderAddress,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),

                //CHILD-7 Drop Location (receiver's address)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Drop Location",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.inputBorder,
                            width: 1,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          receiverAddress,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),

                //COST
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Cost -",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    const Text(
                      "Rs",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "$cost",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),

                //button
                if (widget.showdeliverbutton)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text(
                                      "Do you want to deliver this order?"),
                                  // content: Text(
                                  //   "drop at $receiverAddress for ₹$cost",
                                  //   style: const TextStyle(fontSize: 16),
                                  // ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (handleWithCare) // Show image if handleWithCare is true
                                        Image.asset(
                                          'assets/third-party_images/images/fragiletag.jpg',
                                          width: 144,
                                          height: 100,
                                        ),
                                      Text(
                                        "drop at $receiverAddress for ₹$cost",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: AppColors.grey),
                                        padding: const EdgeInsets.all(14),
                                        child: Text(
                                          "Go Back",
                                          style:
                                              TextStyle(color: AppColors.black),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const Center(
                                            child:
                                                CircularProgressIndicator(), // Display loader
                                          ),
                                        );
                                        //-------------------------------------
                                        var docSnapshot =
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(widget.senderId)
                                                .collection('orders')
                                                .doc(widget.orderId)
                                                .get();
                                        if (docSnapshot['Status'] == 'Active') {
                                          if (await _firestoreService
                                              .acceptOrder(
                                                  senderId, widget.orderId)) {
                                            await Future.delayed(
                                                const Duration(seconds: 5));
                                            Navigator.of(context).pop();

                                            Future<bool?> Status =
                                                checkOrderStatus();
                                            if (Status == true) {
                                              Future.delayed(
                                                  const Duration(seconds: 4),
                                                  () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          GetUserCurrentLocationScreen(
                                                            prevPage: 1,
                                                            orderId:
                                                                widget.orderId,
                                                            senderId: senderId,
                                                          )), // Navigate to Home
                                                );
                                              });
                                            }
                                            //else {
                                            //   showDialog(
                                            //     context: context,
                                            //     builder: (BuildContext context) {
                                            //       return GiffyDialog.image(
                                            //         Image.network(
                                            //           "https://media.giphy.com/media/5BLIUJbZfDzIPv0EpL/giphy.gif",
                                            //           height: 200,
                                            //           fit: BoxFit.cover,
                                            //         ),
                                            //         title: Text(
                                            //           'Unsuccessful',
                                            //           textAlign: TextAlign.center,
                                            //         ),
                                            //         content: Text(
                                            //           'This package was taken. Try delivering another item.',
                                            //           textAlign: TextAlign.center,
                                            //         ),
                                            //         actions: [
                                            //           TextButton(
                                            //             onPressed: () =>
                                            //                 Navigator.push(
                                            //               context,
                                            //               MaterialPageRoute(
                                            //                   builder: (context) =>
                                            //                       MainTraveller(
                                            //                           getIndex:
                                            //                               0)),
                                            //             ),
                                            //             child: const Text('OK'),
                                            //           ),
                                            //         ],
                                            //       );
                                            //     },
                                            //   );
                                            // }

                                            // Future.delayed(Duration(seconds: 4),
                                            //     () {
                                            //   Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             GetUserCurrentLocationScreen(
                                            //               prevPage: 1,
                                            //               orderId: widget.orderId,
                                            //               senderId: senderId,
                                            //             )), // Navigate to Home
                                            //   );
                                            // });
                                          }
                                        } else {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return GiffyDialog.image(
                                                Image.network(
                                                  "https://media.giphy.com/media/5BLIUJbZfDzIPv0EpL/giphy.gif",
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                                title: const Text(
                                                  'Unsuccessful',
                                                  textAlign: TextAlign.center,
                                                ),
                                                content: const Text(
                                                  'This package was taken. Try delivering another item.',
                                                  textAlign: TextAlign.center,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const MainTraveller(
                                                                  getIndex: 0)),
                                                    ),
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        //------------------------------------------
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        // color: AppColors.primary,
                                        padding: const EdgeInsets.all(14),
                                        child: Text(
                                          "Confirm",
                                          style:
                                              TextStyle(color: AppColors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        backgroundColor: AppColors.primary, // Text color
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize:
                            const Size(double.infinity, 0), // Full width
                      ),
                      child: const Text(
                        'Deliver',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
