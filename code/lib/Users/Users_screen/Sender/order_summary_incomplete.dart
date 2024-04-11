import 'package:deliveryx/Users/Users_screen/Sender/order_confirmation.dart';
import 'package:deliveryx/Users/Users_screen/Sender/order_details.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';

import '../eventlogger.dart';

class OrderClickI extends StatefulWidget {
  // final String? cost;
  final String? senderName;
  final String? receiverName;
  final String? senderAddress;
  final String? receiverAddress;
  final String? pCategory;
  final String? pweight;
  final String? pSize;
  final String? status;
  final String date;
  final bool showviewtravelerbutton;
  final String orderId;

  const OrderClickI({
    super.key,
    required this.senderName,
    required this.receiverName,
    required this.senderAddress,
    required this.receiverAddress,
    required this.pCategory,
    required this.pweight,
    required this.pSize,
    required this.status,
    required this.date,
    required this.showviewtravelerbutton,
    required this.orderId,
  });

  @override
  State<OrderClickI> createState() => _OrderClickIState();
}

class _OrderClickIState extends State<OrderClickI> {
  void onEditOrderClick(String orderId) {
    // Navigate to OrderDetails with orderId
    print("yes order");
    print(orderId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetails(
          orderId: orderId,
          // Add other parameters as needed
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'OrderSummaryViewed',
      'Order summary page viewed',
      {
        'orderid': widget.orderId,
        'status': widget.status,
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
      'OrderSummaryCancelled',
      'Order summary page cancelled',
      {},
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

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
                    Text("${widget.pCategory}",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),

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
                              Text("${widget.pweight}",
                                  style: const TextStyle(fontSize: 16)),
                              // const SizedBox(width: 20),
                              // Container(
                              //   height: 16,
                              //   width: 1,
                              //   color: AppColors.grey,
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
                              Text("${widget.pSize}",
                                  style: const TextStyle(fontSize: 16)),
                              // const SizedBox(width: 20),
                              // Container(
                              //   height: 16,
                              //   width: 1,
                              //   color: AppColors.grey,
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

              //CHILD-3 pickup location (sender's address)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pickup Location",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        "${widget.senderAddress}",
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        "${widget.receiverAddress}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),

              // // COST
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text("Cost -",
              //         style:
              //             TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              //     const SizedBox(width: 10),
              //     Text(
              //       "Rs ${widget.cost}",
              //       style: const TextStyle(fontSize: 18),
              //     ),
              //     const SizedBox(width: 5),
              //   ],
              // ),
              // const SizedBox(
              //   height: 16,
              // ),

              // "Edit Order" button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle "Edit Order" button press

                    EventLogger.logOrderSummaryEvent(
                      'medium',
                      DateTime.now().toString(),
                      0,
                      'button',
                      'b_EditOrder',
                      'Edit order button clicked',
                      {},
                    );
                    onEditOrderClick(widget.orderId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                    // minimumSize: const Size(double.infinity, 0), // Full width
                  ),
                  child: Text(
                    'Edit Order',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              if (widget.showviewtravelerbutton)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        _createPageRoute(widget.orderId, widget.date),
                      );
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
                      'View Traveler',
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
    );
  }
}

PageRouteBuilder _createPageRoute(String orderId, String date) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: Orderconfirmation(
          orderId: orderId,
          date: date,
        ),
      );
    },
  );
}
