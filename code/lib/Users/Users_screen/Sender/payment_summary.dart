import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Sender/main_sender.dart';
import 'package:deliveryx/provider/senderProvider.dart';
import 'package:deliveryx/services/firestore.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';

class payment_summary extends StatefulWidget {
  // final orderId;
  final String? orderId;
  final packageInfo;
  final textEditingController;
  final dropdownValue1;
  final textEditingControllerDescription;
  final dropdownValue2;
  final dropdownValue3;
  final isChecked;
  final handleWithCare;
  const payment_summary(
      {required this.packageInfo,
      required this.textEditingController,
      required this.dropdownValue1,
      required this.textEditingControllerDescription,
      required this.dropdownValue2,
      required this.dropdownValue3,
      required this.isChecked,
      required this.orderId,
      required this.handleWithCare,
      super.key});

  @override
  State<payment_summary> createState() => _payment_summaryState();
}

class _payment_summaryState extends State<payment_summary> {
  Razorpay? _razorpay;
  late Sender sender;
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    Sender sender = Provider.of<SenderProvider>(context, listen: false).sender;
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    calculateDistance();
  }

  Future<void> _showExitDialog(BuildContext context) async {
    int? selectedOption;
    String? selectedReason;
    TextEditingController reasonController = TextEditingController();

    selectedOption = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Choose an option")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding: const EdgeInsets.all(20),
                side: BorderSide(
                  width: 2,
                  color: AppColors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 0), // Full width
              ),
              onPressed: () {
                Navigator.pop(context, 1);
              },
              child: Text(
                'Draft Order',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pop(context, 2);
            //   },
            //   child: const Text("Edit Order"),
            // ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding: const EdgeInsets.all(20),
                side: BorderSide(
                  width: 2,
                  color: AppColors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 0), // Full width
              ),
              onPressed: () {
                Navigator.pop(context, 3);
              },
              child: Text(
                'Cancel Draft',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedOption == 1 || selectedOption == 3) {
      selectedReason = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(child: Text("Select Reason")),
          content: SizedBox(
            height: 200, // Adjust the height as needed
            child: CupertinoPicker(
              itemExtent: 80,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedReason = index == 0 ? "Reason 1" : "Reason 2";
                });
              },
              children: const <Widget>[
                Center(
                  child: SizedBox(
                    width: 200,
                    child: Text(
                      "Reason 1 gvbh fcgvhb dxfcgvh dgvh fcgvh",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines:
                          3, // Set the maximum number of lines you want to display
                    ),
                  ),
                ),
                Center(child: Text("Reason 2")),
                Center(child: Text("Reason 3")),
                Center(child: Text("Reason 4")),
                Center(child: Text("Reason 5")),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                  // minimumSize: const Size(double.infinity, 0), // Full width
                ),
                onPressed: () async {
                  print(selectedReason);
                  print(selectedOption);
                  if (selectedOption == 1 && selectedReason != null) {
                    addOrderToIncompleteOrdersDraft(selectedReason!);
                  }

                  if (selectedOption == 3 && selectedReason != null) {
                    addOrderToIncompleteOrdersCancel(selectedReason!);
                  }

                  Navigator.pop(context, selectedReason);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainSender(
                        getIndex: 0,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      );

      print("Selected Reason: $selectedReason");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay?.clear();
  }

  void openPaymentPortal() async {
    Sender sender = Provider.of<SenderProvider>(context, listen: false).sender;

    var options = {
      'key': 'rzp_test_Vw073g37PkRRx0',
      'amount': (totalPrice * 100).toInt(), // Convert totalCost to paisa
      'name': sender.senderName,
      'description': 'Payment',
      'prefill': {'contact': sender.senderNumber},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addCostToOrder(String orderId, double totalCost) async {
    try {
      print('order id inside the addCostToOrder Function is $orderId');
      final currentUser = FirebaseAuth.instance.currentUser;
      final orderInfo = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('orders')
          .doc(orderId)
          .set({'Package Cost': double.parse(totalCost.toStringAsFixed(2))});
    } catch (e) {
      print('here is the errorrrrrrrr $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final FirestoreService firestoreService = FirestoreService();

    final result = firestoreService.addDataToFirestore(
      packageInfo: widget.packageInfo,
      textEditingController: widget.textEditingController,
      dropdownValue1: widget.dropdownValue1,
      textEditingControllerDescription: widget.textEditingControllerDescription,
      dropdownValue2: widget.dropdownValue2,
      dropdownValue3: widget.dropdownValue3,
      isChecked: widget.isChecked,
      totalCost: double.parse(totalPrice.toStringAsFixed(2)),
      orderId: widget.orderId,
      handleWithCare: widget.handleWithCare,
    );

    if (widget.orderId != null) {
      await firestoreService.updateStatusInIncompleteOrders(widget.orderId);
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MainSender(
                      getIndex: 0,
                    )),
          );
        });

        return GiffyDialog.image(
          Image.network(
            "https://media.giphy.com/media/YlSR3n9yZrxfgVzagm/giphy.gif",
            height: 150,
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
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    final FirestoreService firestoreService = FirestoreService();

    await firestoreService.addIncompleteDataWithStatus(
      packageInfo: widget.packageInfo,
      textEditingController: widget.textEditingController,
      dropdownValue1: widget.dropdownValue1,
      textEditingControllerDescription: widget.textEditingControllerDescription,
      dropdownValue2: widget.dropdownValue2,
      dropdownValue3: widget.dropdownValue3,
      isChecked: widget.isChecked,
      orderId: widget.orderId,
      status: 'Payment Failure',
    );
    Fluttertoast.showToast(
        msg: "ERROR HERE: ${response.code} - ${response.message}",
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET IS : ${response.walletName}",
        timeInSecForIosWeb: 4);
  }

  String weightClass = "";
  String sizeClass = "";
  double totalPrice = 0.0;
  double distance = 0.0;

  // Function to add order to Incomplete Orders collection
  void addOrderToIncompleteOrdersDraft(String? selectedReasons) {
    final FirestoreService firestoreService = FirestoreService();
    final result = firestoreService.addIncompleteDataWithStatus(
        packageInfo: widget.packageInfo,
        textEditingController: widget.textEditingController,
        dropdownValue1: widget.dropdownValue1,
        textEditingControllerDescription:
            widget.textEditingControllerDescription,
        dropdownValue2: widget.dropdownValue2,
        dropdownValue3: widget.dropdownValue3,
        isChecked: widget.isChecked,
        orderId: widget.orderId,
        reason: selectedReasons,
        status: 'incomplete');
  }

  void addOrderToIncompleteOrdersCancel(String? selectedReasons) {
    final FirestoreService firestoreService = FirestoreService();
    final result = firestoreService.addIncompleteDataWithStatus(
        packageInfo: widget.packageInfo,
        textEditingController: widget.textEditingController,
        dropdownValue1: widget.dropdownValue1,
        textEditingControllerDescription:
            widget.textEditingControllerDescription,
        dropdownValue2: widget.dropdownValue2,
        dropdownValue3: widget.dropdownValue3,
        isChecked: widget.isChecked,
        orderId: widget.orderId,
        reason: selectedReasons,
        status: 'cancelled');
  }

//1
  Future<void> calculateDistance() async {
    Sender sender = Provider.of<SenderProvider>(context, listen: false).sender;
    String location1 = sender.location1;
    String location2 = sender.location2;

    List<Location> firstLocation = await locationFromAddress(location1);
    List<Location> secondLocation = await locationFromAddress(location2);

    double lat1 = firstLocation[0].latitude;
    double long1 = firstLocation[0].longitude;
    double lat2 = secondLocation[0].latitude;
    double long2 = secondLocation[0].longitude;

    double calculatedDistance = Geolocator.distanceBetween(
      lat1,
      long1,
      lat2,
      long2,
    );

    setState(() {
      distance = calculatedDistance / 1000;
    });
    calculateTotalPrice(context);
  }

//2
  double calculateDistanceFactor(int distance, {double factor = 0.80}) {
    if (distance <= 0) {
      return factor;
    } else {
      return calculateDistanceFactor(distance - 1, factor: factor + 0.20);
    }
  }

  calculateTotalPrice(context) {
    try {
      Sender sender =
          Provider.of<SenderProvider>(context, listen: false).sender;
      print('------->');
      print(sender.size);
      print(sender.weight);

      // Initialize weightClass and sizeClass
      // You can modify this based on your requirements
      // setState(() {
      //   weightClass = sender.weight;
      //   sizeClass = sender.size;
      // });

      double w;
      if (sender.weight == "Upto 1 kg") {
        w = 0;
      } else if (sender.weight == "Upto 3 kg") {
        w = 0;
      } else if (sender.weight == "Upto 5 kg") {
        w = 75.0;
      } else {
        setState(() {
          totalPrice = 0.0;
        });
        return;
      }

      double s;
      if (sender.size == "Small") {
        s = 0;
      } else if (sender.size == "Medium") {
        s = 0;
      } else if (sender.size == "Large") {
        s = 25.0;
      } else if (sender.size == "Xtra Large") {
        s = 50.0;
      } else {
        setState(() {
          totalPrice = 0.0;
        });

        return;
      }
      double i = sender.insuranceAmt / 100;
      double distanceFactor = calculateDistanceFactor(distance.toInt());
      double basePrice = 40;

      double total = basePrice * (distanceFactor) + s + w + i;

      setState(() {
        totalPrice = total;
      });
      print("------------->$totalPrice");
      // Push the total price to SenderPayment screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => SenderPayment(
      //       totalCost: totalPrice,
      //     ),
      //   ),
      // );
    } catch (e) {
      setState(() {
        print("------------>catch ${e.toString()}");
        totalPrice = 0.0;
      });
    }
  }

  //------>

  @override
  Widget build(BuildContext context) {
    Sender sender = Provider.of<SenderProvider>(context).sender;
    int? selectedOption;
    String? selectedReason;
    TextEditingController reasonController = TextEditingController();

    return WillPopScope(
        onWillPop: () async {
          await _showExitDialog(context);
          return false; // Return false to prevent back navigation
        },
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: const Text("Order Payment Summary")),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //CHILD-1 Category and Item Name
                  // Text("Category",
                  //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  // SizedBox(
                  //   height: 10,
                  // ),

                  // Category Details
                  // Container(
                  //   padding: EdgeInsets.all(16.0),
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(10),
                  //       border: Border.all(
                  //         color: AppColors.inputBorder,
                  //         width: 1,
                  //       )),
                  //   child: Row(
                  //     children: [
                  //       Image.asset(
                  //         'assets/third-party_images/icons/box.png',
                  //         width: 20,
                  //         height: 20,
                  //       ),
                  //       SizedBox(width: 16),
                  //       Text("${widget.pCategory}", style: TextStyle(fontSize: 16)),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 16,
                  // ),

                  //CHILD-2 (2 COLUMNs INSIDE ROW)
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
                                  Text(" ${sender.weight}",
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 20),
                                  Container(
                                    height: 16,
                                    width: 1,
                                    color: AppColors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('kg',
                                      style: TextStyle(fontSize: 16)),
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
                                  Text(sender.size,
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 20),
                                  Container(
                                    height: 16,
                                    width: 1,
                                    color: AppColors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('cm',
                                      style: TextStyle(fontSize: 16)),
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

                  //CHILD-3 pickup location (sender's address)
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
                            " ${sender.location1}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  //CHILD-4 Drop Location (receiver's address)
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
                            sender.location2,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Distance",
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
                            " ${distance.toStringAsFixed(2)} Km",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  // COST
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Cost -",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Text(
                        totalPrice.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        openPaymentPortal();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         SenderPayment(totalCost: totalPrice),
                        //   ),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: Text(
                        'Pay ${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
