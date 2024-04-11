import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/continue_deliver.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/order_summary.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/profilepage_traveller.dart';
import 'package:deliveryx/services/firestore.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/auth.dart';
import '../eventlogger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  Stream<QuerySnapshot>? _stream;

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
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    getWalletAmount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> logBContinueDelivering() async {
    final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logHomepageEvent(
        'low',
        DateTime.now().toString(),
        role,
        'traveler',
        'b_ContinueDelivering',
        'Continue Delivering button clicked',
        {'travelerid': travelerId},
      );
    }
  }

  bool allowNavigation = false;
  late String location;
  late String date;
  late String cost;
  String? travelerId;
  bool isBalance = true;
  double totalBalance = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
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
                  children: [
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // children: [
                      //   Text("Orders",
                      //       style: TextStyle(
                      //         fontSize: 22,
                      //         fontWeight: FontWeight.w800,
                      //         color: AppColors.white,
                      //       )),
                      //   Text(
                      //     '${totalBalance.toInt()}', // Replace with actual balance value
                      //     style: TextStyle(
                      //       fontSize: 50,
                      //       color: AppColors.primary,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      //   const SizedBox(height: 8),
                      //   GestureDetector(
                      //     onTap: () {
                      //       // Navigate to another page when the image is tapped
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) =>
                      //                 const ProfilepageTraveler()), // Replace 'AnotherPage()' with the page you want to navigate to
                      //       );
                      //     },
                      //     child: const Image(
                      //       image: AssetImage(
                      //           "assets/third-party_images/icons/user.png"),
                      //       width: 50,
                      //     ),
                      //   )
                      // ],
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Orders",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${totalBalance.toInt()}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () async {
                            // Navigate to profile page when the image is tapped
                            final user = await _authService.getCurrentUser();
                            final userData =
                                await _firestoreService.getUserData();
                            if (userData != null) {
                              final role = userData["role"];
                              DateTime timestamp = DateTime.now();
                              EventLogger.logProfileEvent(
                                'low',
                                timestamp.toString(),
                                role,
                                'traveler',
                                'headericon_profile',
                                'Header icon profile clicked',
                                {'travelerid': user?.uid},
                              );
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfilepageTraveler(),
                              ),
                            );
                          },
                          child: const Image(
                            image: AssetImage(
                                "assets/third-party_images/icons/user.png"),
                            width: 50,
                          ),
                        ),
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
                    text: 'Available',
                  ),
                  Tab(
                    text: 'Active',
                  ),
                  Tab(
                    text: 'Completed',
                  )
                ],
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      AvailableTab(),
                      ActiveTab(),
                      CompletedTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              logBContinueDelivering();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => const ContinueDelivery()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.black,
              backgroundColor: AppColors.primary, // Text color
              padding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 5,
              //minimumSize: Size(double.infinity, 0), // Full width
            ),
            child: Text(
              'Continue Delivering',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AvailableTab extends StatefulWidget {
  const AvailableTab({super.key});

  @override
  State<AvailableTab> createState() => _AvailableTabState();
}

class _AvailableTabState extends State<AvailableTab> {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    _logAvailableTab();
    _loadAvailableOrdersStream();
  }

  // Function to log available tab clicked event
  Future<void> _logAvailableTab() async {
    final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logHomepageEvent(
        'low',
        DateTime.now().toString(),
        1,
        'traveler',
        'tab_Available',
        'Available tab clicked',
        {'travelerid': travelerId},
      );
    }
  }

  Future<void> _loadAvailableOrdersStream() async {
    try {
      final ordersStream =
          await _firestoreService.getOrdersStreamForAvailable();
      setState(() {
        _stream = ordersStream;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading available orders: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to log available tile clicked event
  void logAvailableTileClicked(String orderId, int cost, String senderAddress,
      String receiverAddress, Timestamp orderPlacedAt) async {
    final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logHomepageEvent(
        'low',
        DateTime.now().toString(),
        role,
        'traveler',
        'tile_Available',
        'Available tile clicked',
        {
          'travelerid': travelerId,
          'orderid': orderId,
          'cost': cost.toString(),
          'senderAddress': senderAddress,
          'receiverAddress': receiverAddress,
          'order_placed_at': orderPlacedAt.toDate().toString()
        },
      );
    }
  }

  late String location;
  late String date;
  late String cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Available Results",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),

          // //listview
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              // height: MediaQuery.of(context).size.height,
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
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

                      final cost = orderData['Package Cost'] != null
                          ? ((orderData['Package Cost'] * 0.7).ceil())
                          : (random.nextInt(601) + 701);

                      final orderId = orders[index].id;
                      final senderId = orderData['userid'] as String?;
                      final senderAddress =
                          orderData['Sender Address'] as String?;
                      final receiverAddress =
                          orderData['Receiver Address'] as String?;
                      final orderPlacedAt = orderData['Timestamp'] as Timestamp;
                      final status = orderData['Status'] as String?;
                      final timestamp = orderData['Timestamp'] as Timestamp;
                      final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                          .format(timestamp.toDate());

                      return Card(
                        child: GestureDetector(
                          onTap: () async {
                            logAvailableTileClicked(
                                orderId,
                                cost,
                                senderAddress!,
                                receiverAddress!,
                                orderPlacedAt);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderClickT(
                                  orderId: orderId,
                                  senderId: senderId,
                                  //  status: status,
                                  showdeliverbutton: true,
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
                            title: Text("$receiverAddress"),
                            subtitle: Text(formattedDate),
                            trailing: Text('+Rs. $cost'),
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
    );
  }
}

class ActiveTab extends StatefulWidget {
  const ActiveTab({super.key});

  @override
  State<ActiveTab> createState() => ActiveTabState();
}

class ActiveTabState extends State<ActiveTab> {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<QuerySnapshot>? _stream;
  String? travelerId;

  @override
  void initState() {
    super.initState();
    _logActiveTab();
    _loadActiveOrdersStream();
  }

// Function to log active tab clicked event
  Future<void> _logActiveTab() async {
    final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logHomepageEvent(
        'low',
        DateTime.now().toString(),
        role,
        'traveler',
        'tab_Active',
        'Active tab clicked',
        {'travelerid': travelerId},
      );
    }
  }

  Future<void> _loadActiveOrdersStream() async {
    try {
      final ordersStream = await _firestoreService.getOrdersStreamForActive();
      setState(() {
        _stream = ordersStream;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading active orders: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to log active tile clicked event
  void logActiveTileClicked(String orderId, int cost, String senderAddress,
      String receiverAddress, Timestamp orderPlacedAt) async {
    final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logHomepageEvent(
        'low',
        DateTime.now().toString(),
        role,
        'traveler',
        'tile_Active',
        'Active tile clicked',
        {
          'travelerid': travelerId,
          'orderid': orderId,
          'cost': cost.toString(),
          'senderAddress': senderAddress,
          'receiverAddress': receiverAddress,
          'order_placed_at': orderPlacedAt.toDate().toString()
        },
      );
    }
  }

  late String location;
  late String date;
  late String cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Active Results",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final orders = snapshot.data!.docs;

                  if (orders.isEmpty) {
                    return const Center(child: Text("No recent orders"));
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Random random = Random();
                      //  final int cost = random.nextInt(601) + 701;
                      final orderData =
                          orders[index].data() as Map<String, dynamic>;
                      final cost = orderData['Package Cost'] != null
                          ? ((orderData['Package Cost'] * 0.7).ceil())
                          : (random.nextInt(601) + 701);

                      final orderId = orders[index].id;
                      final senderId = orderData['userid'] as String?;
                      final receiverAddress =
                          orderData['Receiver Address'] as String?;
                      final timestamp = orderData['Timestamp'] as Timestamp;
                      final senderAddress =
                          orderData['Sender Address'] as String?;
                      final orderPlacedAt = orderData['Timestamp'] as Timestamp;
                      final status = orderData['Status'] as String?;
                      final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                          .format(timestamp.toDate());

                      return SingleChildScrollView(
                        child: Card(
                          child: GestureDetector(
                            onTap: () async {
                              logActiveTileClicked(
                                  orderId,
                                  cost,
                                  senderAddress!,
                                  receiverAddress!,
                                  orderPlacedAt);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderClickT(
                                    orderId: orderId,
                                    senderId: senderId,
                                    // status: status,
                                    showdeliverbutton: false,
                                  ),
                                ),
                              );
                              //navigate wala code
                            },
                            child: ListTile(
                              leading: Image.asset(
                                'assets/third-party_images/icons/package.png',
                                width: 40,
                                height: 40,
                              ),
                              title: Text("$receiverAddress"),
                              subtitle: Text(formattedDate),
                              trailing: Text('+Rs. $cost'),
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
    );
  }
}

class CompletedTab extends StatefulWidget {
  const CompletedTab({super.key});

  @override
  State<CompletedTab> createState() => CompletedTabState();
}

class CompletedTabState extends State<CompletedTab> {
  Stream<QuerySnapshot>? _stream;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _logCompletedTab();
    _loadCompleteOrdersStream();
  }

  Future<void> _logCompletedTab() async {
    final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logHomepageEvent(
        'low',
        DateTime.now().toString(),
        role,
        'traveler',
        'tab_Completed',
        'Completed tab clicked',
        {'travelerid': travelerId},
      );
    }
  }

  Future<void> _loadCompleteOrdersStream() async {
    try {
      final ordersStream = await _firestoreService.getOrdersStreamForComplete();
      setState(() {
        _stream = ordersStream;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading completed orders: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to log completed tile clicked event
  void logCompletedTileClicked(
      String orderId,
      // String travelerId,
      int cost,
      String senderAddress,
      String receiverAddress,
      Timestamp orderPlacedAt) async {
    final travelerId = await _firestoreService.getUserId();
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];
      EventLogger.logHomepageEvent(
        'low',
        DateTime.now().toString(),
        role,
        'traveler',
        'tile_Completed',
        'Completed tile clicked',
        {
          'travelerid': travelerId,
          'orderid': orderId,
          'cost': cost.toString(),
          'senderAddress': senderAddress,
          'receiverAddress': receiverAddress,
          'order_placed_at': orderPlacedAt.toDate().toString()
        },
      );
    }
  }

  late String location;
  late String date;
  late String cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Completed Results",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final orders = snapshot.data!.docs;

                  if (orders.isEmpty) {
                    return const Center(child: Text("No recent orders"));
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Random random = Random();
                      //final int cost = random.nextInt(601) + 701;
                      final orderData =
                          orders[index].data() as Map<String, dynamic>;
                      final cost = orderData['Package Cost'] != null
                          ? ((orderData['Package Cost'] * 0.7).ceil())
                          : (random.nextInt(601) + 701);

                      final orderId = orders[index].id;
                      final senderId = orderData['userid'] as String?;
                      final receiverAddress =
                          orderData['Receiver Address'] as String?;
                      final senderAddress =
                          orderData['Sender Address'] as String?;
                      final timestamp = orderData['Timestamp'] as Timestamp;
                      final orderPlacedAt = orderData['Timestamp'] as Timestamp;
                      final status = orderData['Status'] as String?;
                      final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                          .format(timestamp.toDate());

                      return SingleChildScrollView(
                        child: Card(
                          child: GestureDetector(
                            onTap: () {
                              logCompletedTileClicked(
                                  orderId,
                                  cost,
                                  senderAddress!,
                                  receiverAddress!,
                                  orderPlacedAt);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderClickT(
                                    orderId: orderId,
                                    senderId: senderId,
                                    // status: status,
                                    showdeliverbutton: false,
                                  ),
                                ),
                              );
                              //navigate wala code
                            },
                            child: ListTile(
                              leading: Image.asset(
                                'assets/third-party_images/icons/package.png',
                                width: 40,
                                height: 40,
                              ),
                              title: Text("$receiverAddress"),
                              subtitle: Text(formattedDate),
                              trailing: Text('+Rs. $cost'),
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
    );
  }
}
