import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/Users/Users_screen/Sender/order_details.dart';
import 'package:deliveryx/Users/Users_screen/Sender/order_summary.dart';
import 'package:deliveryx/Users/Users_screen/Sender/profilepage.dart';
import 'package:deliveryx/services/firestore.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:deliveryx/Users/Users_screen/Sender/botpage.dart';
import '../../../services/auth.dart';
import '../eventlogger.dart';
import 'dart:math';

class ChatbotButton extends StatefulWidget {
  const ChatbotButton({Key? key}) : super(key: key);

  @override
  _ChatbotButtonState createState() => _ChatbotButtonState();
}

class _ChatbotButtonState extends State<ChatbotButton> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25.0),
      child: FloatingActionButton(
        onPressed: () async {
          final user = await _authService.getCurrentUser();

          EventLogger.logChatbotEvent(
            'low',
            DateTime.now().toString(),
            0,
            'button',
            'b_ChatbotButton',
            'Chatbot button clicked',
            {'senderid': user?.uid},
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BotPage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class HomepageSender extends StatefulWidget {
  const HomepageSender({Key? key}) : super(key: key);

  @override
  State<HomepageSender> createState() => _HomepageSenderState();
}

class _HomepageSenderState extends State<HomepageSender> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  bool allowNavigation = false;
  String? location = "";

  Stream<QuerySnapshot>? _ordersStream;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _loadOrdersStream();
    logEventOnInitialization();
  }

  void logEventOnInitialization() async {
    try {
      // Get current user
      final user = await _authService.getCurrentUser();
      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        final role = userData["role"];

        // Log the event
        DateTime timestamp = DateTime.now();
        EventLogger.logHomepageEvent(
          'low',
          timestamp.toString(),
          role,
          'sender',
          'HomepageStarted',
          'Sender Homepage Started',
          {'senderid': user?.uid},
        );
      }
    } catch (e) {
      print("Error logging event on initialization: $e");
    }
  }

  Future<void> fetchUserData() async {
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      setState(() {
        // Set the initial values for the sender's info fields
        location = userData['location'] ?? 'Default';

        // Set other sender's info fields as needed
      });
    }
  }

  Future<void> _loadOrdersStream() async {
    try {
      final ordersStream =
          await _firestoreService.getOrdersStreamForCurrentUser();
      setState(() {
        _ordersStream = ordersStream;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool confirmed = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Exit'),
              content: const Text('Do you really want to exit the app?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () async {
                    await logExitDialogEvent('No');
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () async {
                    // Log event when the user clicks "Yes"
                    await logExitDialogEvent('Yes');
                    SystemNavigator.pop();
                  },
                ),
              ],
            );
          },
        );

        if (!confirmed) {
          // Log event when the back button is pressed
          await logBackButtonEvent();
        }

        return confirmed;
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              // grey container on top
              child: Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(color: AppColors.header),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Your location",
                                      style: TextStyle(
                                        fontSize: 15,
                                        // fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                      )),
                                  Text("$location, India",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                      )),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              final user = await _authService.getCurrentUser();
                              final userData =
                                  await _firestoreService.getUserData();
                              if (userData != null) {
                                final role = userData["role"];
                                DateTime timestamp = DateTime.now();
                                EventLogger.logHomepageEvent(
                                    'low',
                                    timestamp.toString(),
                                    role,
                                    'button',
                                    'b_sender_profile',
                                    'Sender Profile Button Clicked',
                                    {'userid': user?.uid});
                              }

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
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(
                  height: 30,
                ),

                //recent packages text
                const Padding(
                  // padding: const EdgeInsets.all(16.0),
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text("Recent packages sent",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                ),

                // List of items using ListView.builder
                // StreamBuilder to fetch data from Firestore
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _ordersStream ??
                          const Stream
                              .empty(), // Replace with your Firestore stream
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          // Display an error message if there's an error with the stream
                          return Center(
                              child: Text(
                                  "Error fetching orders: ${snapshot.error}"));
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final orders = snapshot.data!.docs;

                        if (orders.isEmpty) {
                          return const Center(child: Text("No recent orders"));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          itemCount: orders.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Random random = Random();
                            // final int cost = random.nextInt(601) + 701;
                            final orderData =
                                orders[index].data() as Map<String, dynamic>;
                            final orderId = orders[index].id;
                            final cost = '${orderData['Package Cost']}' ??
                                random.nextInt(601) + 701;
                            final senderName =
                                orderData['Sender Name'] as String?;
                            final hashedOrderId =
                                orderData['hashedOrderId'] as String?;
                            final receiverName =
                                orderData['Receiver Name'] as String?;
                            final status = orderData['Status'] as String?;
                            final receiverAddress =
                                orderData['Receiver Address'] as String?;
                            final senderAddress =
                                orderData['Sender Address'] as String?;
                            final pCategory =
                                orderData['Package Category'] as String?;
                            final pSize = orderData['Package Size'] as String?;
                            final pweight =
                                orderData['Package Weight'] as String?;
                            // final pCost = orderData['Package Cost'];
                            final timestamp =
                                orderData['Timestamp'] as Timestamp;
                            final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                                .format(timestamp.toDate());

                            return Card(
                              child: GestureDetector(
                                onTap: () async {
                                  DateTime timestamp = DateTime.now();

                                  final userData =
                                      await _firestoreService.getUserData();
                                  if (userData != null) {
                                    final role = userData["role"];
                                    EventLogger.logHomepageEvent(
                                        'low',
                                        timestamp.toString(),
                                        role,
                                        'sender',
                                        'tile_HomePage',
                                        'Sender Home Page tile cliked', {
                                      'orderId': orderId,
                                      'Sender Name': senderName,
                                      'Receiver Name': receiverName,
                                      'Sender Address': senderAddress,
                                      'Receiver Address': receiverAddress,
                                      'Package Category': pCategory,
                                      'Date': formattedDate,
                                      'Package Size': pSize,
                                      'Package Weight': pweight,
                                      'Cost': cost
                                    });
                                  }

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
                                        date: formattedDate,
                                        pSize: pSize,
                                        status: status,
                                        pweight: pweight,
                                        cost: cost,
                                        showviewtravelerbutton: false,
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
                                  title: Text(hashedOrderId ?? ''),
                                  subtitle: Text(formattedDate),
                                  trailing: Text(orderData['Status'] ?? ''),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = await _authService.getCurrentUser();
                      DateTime timestamp = DateTime.now();
                      final userData = await _firestoreService.getUserData();
                      if (userData != null) {
                        final role = userData["role"];
                        EventLogger.logHomepageEvent(
                            'medium',
                            timestamp.toString(),
                            role,
                            'button',
                            'b_SendPackage',
                            'Send a package button clicked',
                            {'userid': user?.uid});
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrderDetails(
                                  orderId: '',
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      backgroundColor: AppColors.primary, // Text color
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size(double.infinity, 0), // Full width
                    ),
                    child: Text(
                      'Send Package',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
        floatingActionButton: const ChatbotButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }
}

Future<void> logExitDialogEvent(String action) async {
  try {
    // Get current user
    final FirestoreService firestoreService = FirestoreService();
    final AuthService authService = AuthService();
    final user = await authService.getCurrentUser();

    final userData = await firestoreService.getUserData();
    if (userData != null) {
      final role = userData["role"];

      // Log the event
      DateTime timestamp = DateTime.now();
      EventLogger.logHomepageEvent(
        'low',
        timestamp.toString(),
        role,
        'button',
        'b_ExitApp_$action',
        'User clicked $action on exit app dialog',
        {'userid': user?.uid},
      );
    }
  } catch (e) {
    print("Error logging exit dialog event: $e");
  }
}

Future<void> logBackButtonEvent() async {
  try {
    // Get current user
    final FirestoreService firestoreService = FirestoreService();
    final AuthService authService = AuthService();
    final user = await authService.getCurrentUser();
    final userData = await firestoreService.getUserData();

    if (userData != null) {
      final role = userData["role"];

      // Log the event
      DateTime timestamp = DateTime.now();
      EventLogger.logHomepageEvent(
        'low',
        timestamp.toString(),
        role,
        'button',
        'b_BackButton',
        'User clicked the back button to exit the page',
        {'userid': user?.uid},
      );
    }
  } catch (e) {
    print("Error logging back button event: $e");
  }
}
