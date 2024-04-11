import 'package:deliveryx/Users/Users_screen/Sender/order_summary_incomplete.dart';
import 'package:deliveryx/Users/Users_screen/Sender/profilepage.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Sender/order_summary.dart';
import 'package:intl/intl.dart';
import '../../../services/firestore.dart';
import '../eventlogger.dart';

class MyOrdersSender extends StatefulWidget {
  const MyOrdersSender({super.key});

  @override
  State<MyOrdersSender> createState() => _MyOrderSender_State();
}

class _MyOrderSender_State extends State<MyOrdersSender>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    EventLogger.logSendersMyOrdersEvent(
      'medium',
      DateTime.now().toString(),
      0,
      'sender',
      'MyOrdersCancelled',
      '',
      {},
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // orders from location wala container
            Container(
              width: double.infinity,
              height: 170,
              decoration: BoxDecoration(color: AppColors.header),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("My Orders",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            )),
                        GestureDetector(
                          onTap: () {
                            // Navigate to another page when the image is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfilepageSender()), // Replace 'AnotherPage()' with the page you want to navigate to
                            );
                          },
                          child: const Image(
                            image: AssetImage(
                                "assets/third-party_images/icons/user.png"),
                            width: 50,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            //tabbar
            Container(
              child: TabBar(
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary,
                      width: 2.0,
                    ),
                  ),
                ),
                unselectedLabelColor: AppColors.grey,
                labelColor: AppColors.primary,
                tabs: const [
                  Tab(
                    text: 'Drafts',
                  ),
                  Tab(
                    text: 'Pending',
                  ),
                  Tab(
                    text: 'Ongoing',
                  ),
                  Tab(
                    text: 'Delivered',
                  )
                ],
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      DraftTab(),
                      PendingTab(),
                      OngoingTab(),
                      DeliveredTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DraftTab extends StatefulWidget {
  const DraftTab({super.key});

  @override
  State<DraftTab> createState() => _DraftTabState();
}

class _DraftTabState extends State<DraftTab> {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<QuerySnapshot>? _stream;
  String? senderId;

  @override
  void initState() {
    super.initState();
    _loadOrdersStream();
  }

  Future<void> _loadOrdersStream() async {
    senderId = await _firestoreService.getUserId(); // Retrieve senderId
    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'tab_Draft',
      'Draft tab clicked',
      {'senderid': senderId},
    );
    try {
      final ordersStream =
          await _firestoreService.getIncompleteOrdersStreamForCurrentUser();
      setState(() {
        _stream = ordersStream;
      });
    } catch (e) {
      // Handle the exception
      print("Error loading orders stream: $e");
      // Show a user-friendly message, for example, using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading orders. Please try again."),
        ),
      );
    }
  }

  // Function to log draft tile clicked event
  void logDraftTileClicked(
      String orderId,
      // String travelerId,
      int cost,
      String pCategory,
      String pweight,
      String pSize,
      String senderAddress,
      String receiverAddress,
      Timestamp orderPlacedAt) async {
    EventLogger.logSendersMyOrdersEvent(
      'high',
      DateTime.now().toString(),
      0,
      'sender',
      'tile_Draft',
      'Draft tile clicked',
      {
        'senderid': senderId,
        'orderid': orderId,
        // 'travelerid': travelerId,
        'cost': cost.toString(),
        'pCategory': pCategory,
        'pweight': pweight,
        'pSize': pSize,
        'senderAddress': senderAddress,
        'receiverAddress': receiverAddress,
        'order_placed_at': orderPlacedAt.toDate().toString()
      },
    );
  }

  late String location;
  late String date;
  // late String cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(
                    //   width: 10,
                    // ),
                    Text("Draft Results",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),

              // //listview
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  // height: MediaQuery.of(context).size.height,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        // Display an error message if there's an error with the stream
                        return Center(
                            child: Text(
                                "Error loading orders: ${snapshot.error}"));
                      }

                      final orders = snapshot.data!.docs;

                      if (orders.isEmpty) {
                        return const Center(child: Text("No recent orders"));
                      }

                      return ListView.builder(
                        itemCount: orders.length,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        // itemCount: 17,

                        itemBuilder: (BuildContext context, int index) {
                          final Random random = Random();
                          // final int cost = random.nextInt(601) + 701;
                          final orderData =
                              orders[index].data() as Map<String, dynamic>;
                          final orderId = orders[index].id;
                          final cost = orderData['Package Cost'] != null
                              ? (orderData['Package Cost']).ceil()
                              : (random.nextInt(601) + 701);
                          final senderName =
                              orderData['Sender Name'] as String?;
                          final hashedOrderId =
                              orderData['hashedOrderId'] as String?;
                          final status = orderData['Status'] as String?;
                          final receiverName =
                              orderData['Receiver Name'] as String?;
                          final receiverAddress =
                              orderData['Receiver Address'] as String?;
                          final senderAddress =
                              orderData['Sender Address'] as String?;
                          final pCategory =
                              orderData['Package Category'] as String?;
                          final pSize = orderData['Package Size'] as String?;
                          final pweight =
                              orderData['Package Weight'] as String?;
                          //  final travelerId = orderData['travelerId'] as String?;
                          // final pCost = orderData[Package Cost];
                          final orderPlacedAt =
                              orderData['Timestamp'] as Timestamp;
                          final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                              .format(orderPlacedAt.toDate());

                          return SingleChildScrollView(
                            child: Card(
                              child: GestureDetector(
                                onTap: () {
                                  logDraftTileClicked(
                                      orderId,
                                      // travelerId!,
                                      cost,
                                      pCategory!,
                                      pweight!,
                                      pSize!,
                                      senderAddress!,
                                      receiverAddress!,
                                      orderPlacedAt);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderClickI(
                                        orderId: orderId,
                                        senderName: senderName,
                                        receiverName: receiverName,
                                        senderAddress: senderAddress,
                                        receiverAddress: receiverAddress,
                                        pCategory: pCategory,
                                        pSize: pSize,
                                        status: status,
                                        pweight: pweight,
                                        showviewtravelerbutton: false,
                                        date: formattedDate,
                                      ),
                                    ),
                                  );
                                  //navigate logic code
                                },
                                child: ListTile(
                                  leading: Image.asset(
                                    'assets/third-party_images/icons/package.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  title: Text("$hashedOrderId"),
                                  subtitle: Text(formattedDate),
                                  // trailing: Text('Rs. $cost'),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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

class PendingTab extends StatefulWidget {
  const PendingTab({super.key});

  @override
  State<PendingTab> createState() => PendingTabState();
}

class PendingTabState extends State<PendingTab> {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<QuerySnapshot>? _stream;
  String? senderId;

  @override
  void initState() {
    super.initState();
    _loadPendingStream();
  }

  Future<void> _loadPendingStream() async {
    senderId = await _firestoreService.getUserId();
    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'tab_Pending',
      'Pending tab clicked',
      {'senderid': senderId},
    );
    try {
      final ordersStream =
          await _firestoreService.getOrdersStreamForCurrentUserStatus('Active');

      setState(() {
        _stream = ordersStream;
      });
    } catch (e) {
      // Handle the exception
      print("Error loading pending orders stream: $e");
      // Show a user-friendly message, for example, using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading pending orders. Please try again."),
        ),
      );
    }
  }

  // Function to log pending tile clicked event
  void logPendingTileClicked(
      String orderId,
      // String travelerId,
      String cost,
      String pCategory,
      String pweight,
      String pSize,
      String senderAddress,
      String receiverAddress,
      Timestamp orderPlacedAt) async {
    EventLogger.logSendersMyOrdersEvent(
      'medium',
      DateTime.now().toString(),
      0,
      'sender',
      'tile_Pending',
      'Pending tile clicked',
      {
        'senderid': senderId,
        'orderid': orderId,
        // 'travelerid': travelerId,
        'cost': cost.toString(),
        'pCategory': pCategory,
        'pweight': pweight,
        'pSize': pSize,
        'senderAddress': senderAddress,
        'receiverAddress': receiverAddress,
        'order_placed_at': orderPlacedAt.toDate().toString()
      },
    );
  }

  late String location;
  late String date;
  late String cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: SingleChildScrollView(
            child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Pending Results",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),

            // //listview
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      // Display an error message if there's an error with the stream
                      return Center(
                          child:
                              Text("Error loading orders: ${snapshot.error}"));
                    }

                    final orders = snapshot.data!.docs;

                    if (orders.isEmpty) {
                      return const Center(child: Text("No pending orders"));
                    }

                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Random random = Random();
                        // final int cost = random.nextInt(601) + 701;
                        final orderData =
                            orders[index].data() as Map<String, dynamic>;
                        final cost = orderData['Package Cost'] != null
                            ? (orderData['Package Cost']).ceil()
                            : (random.nextInt(601) + 701);
                        final hashedOrderId =
                            orderData['hashedOrderId'] as String?;
                        final orderId = orders[index].id;
                        final senderName = orderData['Sender Name'] as String?;
                        final status = orderData['Status'] as String?;
                        final receiverName =
                            orderData['Receiver Name'] as String?;
                        final receiverAddress =
                            orderData['Receiver Address'] as String?;
                        final senderAddress =
                            orderData['Sender Address'] as String?;
                        final pCategory =
                            orderData['Package Category'] as String?;
                        final pSize = orderData['Package Size'] as String?;
                        // final pCost = orderData[Package Cost];
                        final pweight = orderData['Package Weight'] as String?;
                        //  final travelerId = orderData['travelerId'] as String?;
                        final orderPlacedAt =
                            orderData['Timestamp'] as Timestamp;
                        final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                            .format(orderPlacedAt.toDate());

                        return SingleChildScrollView(
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                logPendingTileClicked(
                                    orderId,
                                    // travelerId!,
                                    cost,
                                    pCategory!,
                                    pweight!,
                                    pSize!,
                                    senderAddress!,
                                    receiverAddress!,
                                    orderPlacedAt);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderClickS(
                                      orderId: orderId,
                                      senderName: senderName,
                                      receiverName: receiverName,
                                      senderAddress: senderAddress,
                                      receiverAddress: receiverAddress,
                                      pCategory: pCategory,
                                      pSize: pSize,
                                      status: status,
                                      pweight: pweight,
                                      cost: cost,
                                      showviewtravelerbutton: false,
                                      date: formattedDate,
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: Image.asset(
                                  'assets/third-party_images/icons/package.png',
                                  width: 40,
                                  height: 40,
                                ),
                                title: Text("$hashedOrderId"),
                                subtitle: Text(formattedDate),
                                trailing: Text('Rs. $cost'),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class OngoingTab extends StatefulWidget {
  const OngoingTab({super.key});

  @override
  State<OngoingTab> createState() => OngoingTabState();
}

class OngoingTabState extends State<OngoingTab> {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<QuerySnapshot>? _stream;
  String? senderId;

  @override
  void initState() {
    super.initState();

    _loadOngoingStream();
  }

  Future<void> _loadOngoingStream() async {
    senderId = await _firestoreService.getUserId(); // Retrieve senderId
    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'tab_Ongoing',
      'Ongoing tab clicked',
      {'senderid': senderId},
    );
    try {
      final ordersStream = await _firestoreService
          .getOrdersProcessingPendingStreamForCurrentUserStatus(
              'Processing', 'Picked');
      setState(() {
        _stream = ordersStream;
      });
    } catch (e) {
      // Handle the exception
      print("Error loading ongoing orders stream: $e");
      // Show a user-friendly message, for example, using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading ongoing orders. Please try again."),
        ),
      );
    }
  }

  // Function to log ongoing tile clicked event
  void logOngoingTileClicked(
      String orderId,
      String travelerId,
      int cost,
      String pCategory,
      String pweight,
      String pSize,
      String senderAddress,
      String receiverAddress,
      Timestamp orderPlacedAt) async {
    EventLogger.logSendersMyOrdersEvent(
      'medium',
      DateTime.now().toString(),
      0,
      'sender',
      'tile_Ongoing',
      'Ongoing tile clicked',
      {
        'senderid': senderId,
        'orderid': orderId,
        'travelerid': travelerId,
        // 'travelerid': status == 'processing' ? travelerId : null,
        'cost': cost.toString(),
        'pCategory': pCategory,
        'pweight': pweight,
        'pSize': pSize,
        'senderAddress': senderAddress,
        'receiverAddress': receiverAddress,
        'order_placed_at': orderPlacedAt.toDate().toString()
      },
    );
  }

  late String location;
  late String date;
  late String cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: SingleChildScrollView(
            child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ongoing Results",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),

            // //listview
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      // Display an error message if there's an error with the stream
                      return Center(
                          child:
                              Text("Error loading orders: ${snapshot.error}"));
                    }

                    final orders = snapshot.data!.docs;

                    if (orders.isEmpty) {
                      return const Center(child: Text("No ongoing orders"));
                    }

                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Random random = Random();
                        // final int cost = random.nextInt(601) + 701;

                        final orderData =
                            orders[index].data() as Map<String, dynamic>;
                        final cost = orderData['Package Cost'] != null
                            ? (orderData['Package Cost']).ceil()
                            : (random.nextInt(601) + 701);
                        final orderId = orders[index].id;
                        final hashedOrderId =
                            orderData['hashedOrderId'] as String?;
                        final senderName = orderData['Sender Name'] as String?;
                        final status = orderData['Status'] as String?;
                        final receiverName =
                            orderData['Receiver Name'] as String?;
                        final receiverAddress =
                            orderData['Receiver Address'] as String?;
                        final senderAddress =
                            orderData['Sender Address'] as String?;
                        final pCategory =
                            orderData['Package Category'] as String?;
                        final pSize = orderData['Package Size'] as String?;
                        final pweight = orderData['Package Weight'] as String?;
                        // final status = orderData['Status'] as String?;
                        final travelerId = orderData['travelerId'] as String?;
                        // final pCost = orderData[Package Cost];
                        final orderPlacedAt =
                            orderData['Timestamp'] as Timestamp;
                        final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                            .format(orderPlacedAt.toDate());

                        return SingleChildScrollView(
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                logOngoingTileClicked(
                                    orderId,
                                    travelerId!,
                                    cost,
                                    pCategory!,
                                    pweight!,
                                    pSize!,
                                    senderAddress!,
                                    receiverAddress!,
                                    orderPlacedAt);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderClickS(
                                      orderId: orderId,
                                      senderName: senderName,
                                      receiverName: receiverName,
                                      senderAddress: senderAddress,
                                      receiverAddress: receiverAddress,
                                      pCategory: pCategory,
                                      pSize: pSize,
                                      status: status,
                                      pweight: pweight,
                                      cost: cost,
                                      showviewtravelerbutton: true,
                                      date: formattedDate,
                                    ),
                                  ),
                                );
                                //navigate code
                              },
                              child: ListTile(
                                leading: Image.asset(
                                  'assets/third-party_images/icons/package.png',
                                  width: 40,
                                  height: 40,
                                ),
                                title: Text("$hashedOrderId"),
                                subtitle: Text(formattedDate),
                                trailing: Text('Rs. $cost'),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class DeliveredTab extends StatefulWidget {
  const DeliveredTab({super.key});

  @override
  State<DeliveredTab> createState() => DeliveredTabState();
}

class DeliveredTabState extends State<DeliveredTab> {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<QuerySnapshot>? _stream;
  String? senderId;

  @override
  void initState() {
    super.initState();
    _loadDeliveredStream();
  }

  Future<void> _loadDeliveredStream() async {
    senderId = await _firestoreService.getUserId();
    EventLogger.logSendersMyOrdersEvent(
      'low',
      DateTime.now().toString(),
      0,
      'sender',
      'tab_Delivered',
      'Delivered tab clicked',
      {'senderid': senderId},
    );
    try {
      final ordersStream = await _firestoreService
          .getOrdersStreamForCurrentUserStatus('Completed');
      setState(() {
        _stream = ordersStream;
      });
    } catch (e) {
      // Handle the exception
      print("Error loading delivered orders stream: $e");
      // Show a user-friendly message, for example, using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading delivered orders. Please try again."),
        ),
      );
    }
  }

  // Function to log Delivered tile clicked event
  void logDeliveredTileClicked(
      String orderId,
      String travelerId,
      int cost,
      String pCategory,
      String pweight,
      String pSize,
      String senderAddress,
      String receiverAddress,
      Timestamp orderPlacedAt) async {
    EventLogger.logSendersMyOrdersEvent(
      'medium',
      DateTime.now().toString(),
      0,
      'sender',
      'tile_Delivered',
      'Delivered tile clicked',
      {
        'senderid': senderId,
        'orderid': orderId,
        'travelerid': travelerId,
        'cost': cost.toString(),
        'pCategory': pCategory,
        'pweight': pweight,
        'pSize': pSize,
        'senderAddress': senderAddress,
        'receiverAddress': receiverAddress,
        'order_placed_at': orderPlacedAt.toDate().toString()
      },
    );
  }

  late String location;
  late String date;
  late String cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: SingleChildScrollView(
            child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Delivered Results",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),

            // //listview
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      // Display an error message if there's an error with the stream
                      return Center(
                          child:
                              Text("Error loading orders: ${snapshot.error}"));
                    }

                    final orders = snapshot.data!.docs;

                    if (orders.isEmpty) {
                      return const Center(child: Text("No delivered orders"));
                    }

                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Random random = Random();
                        // final int cost = random.nextInt(601) + 701;
                        final orderData =
                            orders[index].data() as Map<String, dynamic>;
                        final orderId = orders[index].id;
                        final cost = orderData['Package Cost'] != null
                            ? (orderData['Package Cost']).ceil()
                            : (random.nextInt(601) + 701);
                        final senderName = orderData['Sender Name'] as String?;
                        final status = orderData['Status'] as String?;
                        final hashedOrderId =
                            orderData['hashedOrderId'] as String?;
                        final receiverName =
                            orderData['Receiver Name'] as String?;
                        final receiverAddress =
                            orderData['Receiver Address'] as String?;
                        final senderAddress =
                            orderData['Sender Address'] as String?;
                        final pCategory =
                            orderData['Package Category'] as String?;
                        final pSize = orderData['Package Size'] as String?;
                        // final pCost = orderData[Package Cost];
                        final pweight = orderData['Package Weight'] as String?;
                        final travelerId = orderData['travelerId'] as String?;
                        final orderPlacedAt =
                            orderData['Timestamp'] as Timestamp;
                        final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                            .format(orderPlacedAt.toDate());

                        return SingleChildScrollView(
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                logDeliveredTileClicked(
                                    orderId,
                                    travelerId!,
                                    cost,
                                    pCategory!,
                                    pweight!,
                                    pSize!,
                                    senderAddress!,
                                    receiverAddress!,
                                    orderPlacedAt);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderClickS(
                                      orderId: orderId,
                                      senderName: senderName,
                                      receiverName: receiverName,
                                      senderAddress: senderAddress,
                                      receiverAddress: receiverAddress,
                                      pCategory: pCategory,
                                      pSize: pSize,
                                      status: status,
                                      pweight: pweight,
                                      cost: cost,
                                      showviewtravelerbutton: false,
                                      date: formattedDate,
                                    ),
                                  ),
                                );
                                //navigate code
                              },
                              child: ListTile(
                                leading: Image.asset(
                                  'assets/third-party_images/icons/package.png',
                                  width: 40,
                                  height: 40,
                                ),
                                title: Text("$hashedOrderId"),
                                subtitle: Text(formattedDate),
                                trailing: Text('Rs. $cost'),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
