import 'package:deliveryx/Users/Users_screen/Sender/main_sender.dart';
import 'package:deliveryx/Users/Users_screen/Sender/package_info.dart';
import 'package:deliveryx/Users/Users_screen/eventlogger.dart';
import 'package:deliveryx/services/auth.dart';
import 'package:deliveryx/services/maps.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_autocomplete_field/map_autocomplete_field.dart';
import '../../../services/firestore.dart';

late TabController tabController;
bool buttonclicked = false;
final _formKey_Sender = GlobalKey<FormState>();
final _formKey_Receiver = GlobalKey<FormState>();

class OrderDetails extends StatefulWidget {
  final String orderId;

  const OrderDetails({
    required this.orderId,
    super.key,
  });

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

//The main Page of Order
class _OrderDetailsState extends State<OrderDetails>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<OrderDetails> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  bool get wantKeepAlive => true;

  TextEditingController senderName = TextEditingController();
  TextEditingController senderPhone = TextEditingController();
  TextEditingController senderAddress = TextEditingController();
  TextEditingController senderCity = TextEditingController();
  TextEditingController senderState = TextEditingController();
  // TextEditingController senderRoom = TextEditingController();
  // TextEditingController senderBldg = TextEditingController();
  TextEditingController senderPincode = TextEditingController();
  TextEditingController senderInstruction = TextEditingController();

  TextEditingController receiverName = TextEditingController();
  TextEditingController receiverPhone = TextEditingController();
  TextEditingController receiverAddress = TextEditingController();
  TextEditingController receiverCity = TextEditingController();
  TextEditingController receiverState = TextEditingController();
  // TextEditingController receiverRoom = TextEditingController();
  // TextEditingController receiverBldg = TextEditingController();
  TextEditingController receiverPincode = TextEditingController();

  final PackageData packageData = PackageData();

  // User? currentUser;

  String senderId = '';
  String role = '';

  Future<void> fetchSenderId() async {
    final userData = await _firestoreService.getUserData();
    if (userData != null) {
      setState(() {
        // Set the initial values for the sender's info fields
        senderId = userData['id'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    fetchSenderId().then((_) {
      DateTime timestamp = DateTime.now();

      // Log the event when the login page is loaded
      EventLogger.logSenderOrderDetailsEvent(
        'low',
        timestamp.toString(),
        0,
        'sender',
        'OrderDetailsStarted',
        'Order Details started',
        {
          'senderid': senderId,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text("Order Details")),
      backgroundColor: AppColors.white,
      body: WillPopScope(
        onWillPop: () async {
          DateTime timestamp = DateTime.now();
          EventLogger.logSenderOrderDetailsEvent(
            'high',
            timestamp.toString(),
            0,
            'button',
            'b_LeftArrow',
            'Order Details cancelled',
            {
              'senderid': senderId,
            },
          );
          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //tabs
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.lightwhite,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TabBar(
                            unselectedLabelColor: AppColors.black,
                            labelColor: AppColors.primary,
                            indicatorColor: AppColors.white,
                            indicatorWeight: 2,
                            indicator: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            controller: tabController,
                            onTap: (value) {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus &&
                                  currentFocus.focusedChild != null) {
                                currentFocus.focusedChild!.unfocus();
                              }
                              setState(() {
                                tabController.index = value;
                                // Set the role based on the value
                                role = value == 0 ? 'Sender' : 'Receiver';
                              });
                              print(value);

                              DateTime timestamp = DateTime.now();
                              EventLogger.logSenderOrderDetailsEvent(
                                'low',
                                timestamp.toString(),
                                0,
                                'tabcontroller',
                                'toggle_${role}Info',
                                'Sender filling $role details',
                                {
                                  'senderid': senderId,
                                },
                              );
                            },
                            tabs: const [
                              Tab(
                                text: 'Senders Info',
                              ),
                              Tab(
                                text: 'Recievers Info',
                              ),
                            ]),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: MediaQuery.of(context).size.height + 36,
                      constraints: const BoxConstraints(),
                      child: TabBarView(
                          controller: tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            SenderInfoTab(
                              nameController: senderName,
                              phoneController: senderPhone,
                              addressController: senderAddress,
                              cityController: senderCity,
                              stateController: senderState,
                              pincodeController: senderPincode,
                              instructionController: senderInstruction,
                              packageData: packageData,
                              orderId: widget.orderId,
                            ),
                            ReceiverInfoTab(
                              nameController: receiverName,
                              phoneController: receiverPhone,
                              addressController: receiverAddress,
                              cityController: receiverCity,
                              stateController: receiverState,
                              pincodeController: receiverPincode,
                              packageData: packageData,
                              orderId: widget.orderId,
                            ),
                          ]),
                    ),
                  ]),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            setState(() {
              buttonclicked = true;
            });
            if (_formKey_Sender.currentState != null &&
                _formKey_Receiver.currentState != null) {
              if (_formKey_Sender.currentState!.validate() &&
                  !_formKey_Receiver.currentState!.validate()) {
                setState(() {
                  tabController.index = 1;
                });
                // tabController.animateTo(1);
              }
              if (_formKey_Receiver.currentState!.validate() &&
                  !_formKey_Sender.currentState!.validate()) {
                setState(() {
                  tabController.index = 0;
                });
                // tabController.animateTo(0);
              }
              if ((_formKey_Sender.currentState!.validate() &&
                  _formKey_Receiver.currentState!.validate())) {
                try {
                  print("packageeeeee");
                  print(packageData.senderAddress);
                  final senderLocations =
                      await locationFromAddress(packageData.senderAddress);
                  final receiverLocations =
                      await locationFromAddress(packageData.receiverAddress);
                  print(packageData.receiverAddress);
                  if (senderLocations.isNotEmpty &&
                      receiverLocations.isNotEmpty) {
                    final getSenderPincode = await getPostalCodeFromLocation(
                        senderLocations.first.latitude,
                        senderLocations.first.longitude);
                    final getReceiverPincode = await getPostalCodeFromLocation(
                        receiverLocations.first.latitude,
                        receiverLocations.first.longitude);
                    if (packageData.senderAddress ==
                        packageData.receiverAddress) {
                      DateTime timestamp = DateTime.now();
                      EventLogger.logSenderOrderDetailsEvent(
                        'high',
                        timestamp.toString(),
                        0,
                        'alert',
                        'alert_identicalAddressInOrderDetails',
                        'User filled identical address details',
                        {
                          'senderid': senderId,
                        },
                      );
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Address Discrepancy Resolution"),
                          content: const Text(
                              "Ensure that identical addresses are not assigned."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5))),
                                // color: AppColors.primary,
                                padding: const EdgeInsets.all(14),
                                child: Text(
                                  "Fill",
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      if ((getSenderPincode.toString() !=
                              packageData.senderPincode) ||
                          (getReceiverPincode.toString() !=
                              packageData.receiverPincode)) {
                        DateTime timestamp = DateTime.now();
                        EventLogger.logSenderOrderDetailsEvent(
                          'high',
                          timestamp.toString(),
                          0,
                          'alert',
                          'alert_wrongPincode',
                          'User filled wrong pincode details',
                          {
                            'senderid': senderId,
                          },
                        );
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Wrong Pincode"),
                            content:
                                const Text("Please Fill the correct pincode"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5))),
                                  // color: AppColors.primary,
                                  padding: const EdgeInsets.all(14),
                                  child: Text(
                                    "Fill",
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final packageInfoWidget = PackageInfo(
                          senderName: packageData.senderName,
                          senderPhone: packageData.senderPhone,
                          senderAddress: packageData.senderAddress,
                          senderCity: packageData.senderCity,
                          senderState: packageData.senderState,
                          senderPincode: packageData.senderPincode,
                          senderInstruction: packageData.senderInstruction,
                          receiverName: packageData.receiverName,
                          receiverPhone: packageData.receiverPhone,
                          receiverAddress: packageData.receiverAddress,
                          receiverCity: packageData.receiverCity,
                          receiverState: packageData.receiverState,
                          receiverPincode: packageData.receiverPincode,
                          senderGeocodeLat: senderLocations.first.latitude,
                          senderGeocodeLon: senderLocations.first.longitude,
                          orderId: widget.orderId,
                        );

                        DateTime timestamp = DateTime.now();
                        EventLogger.logSenderOrderDetailsEvent(
                          'high',
                          timestamp.toString(),
                          0,
                          'button',
                          'b_PackageDetails',
                          'Package Details Button clicked ',
                          {
                            'senderid': senderId,
                          },
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => packageInfoWidget),
                        );
                      }
                    }
                  }
                } catch (e) {
                  print(e);
                  print(
                      'Sender Address in packageData: ${packageData.senderAddress}');
                  print(
                      'Receiver Address in packageData: ${packageData.receiverAddress}');
                  DateTime timestamp = DateTime.now();
                  EventLogger.logSenderOrderDetailsEvent(
                    'high',
                    timestamp.toString(),
                    0,
                    'alert',
                    'alert_wrongAddressFilled',
                    'User filled wrong address',
                    {
                      'senderid': senderId,
                    },
                  );
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Address Not Found"),
                      content: const Text("Please Fill the correct address"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            // color: AppColors.primary,
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              "Fill",
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              if (!_formKey_Sender.currentState!.validate() ||
                  !_formKey_Receiver.currentState!.validate()) {
                DateTime timestamp = DateTime.now();
                EventLogger.logSenderOrderDetailsEvent(
                  'high',
                  timestamp.toString(),
                  0,
                  'alert',
                  'alert_unfilledOrderDetails',
                  'User not filled the sender details',
                  {
                    'senderid': senderId,
                  },
                );
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("You have not filled the details"),
                    content: const Text("Please Fill all details"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          // color: AppColors.primary,
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            "Fill",
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
            // tabController.animateTo(1);
            if (_formKey_Receiver.currentState == null) {
              if (_formKey_Sender.currentState!.validate()) {
                setState(() {
                  tabController.index = 1;
                });
              }
              DateTime timestamp = DateTime.now();
              EventLogger.logSenderOrderDetailsEvent(
                'high',
                timestamp.toString(),
                0,
                'alert',
                'alert_unfilledOrderDetails',
                'User not filled the reciever details',
                {
                  'senderid': senderId,
                },
              );
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("You have not filled the details"),
                  content: const Text("Please Fill all the details"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        // color: AppColors.primary,
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          "Fill",
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            // Handle button press here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "Enter Package Details",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class SenderInfoTab extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pincodeController;
  final TextEditingController instructionController;
  final PackageData packageData;
  final String orderId;

  const SenderInfoTab({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
    required this.stateController,
    required this.pincodeController,
    required this.instructionController,
    required this.packageData,
    required this.orderId,
  }) : super(key: key);

  @override
  State<SenderInfoTab> createState() => _SenderInfoTabState();
}

class _SenderInfoTabState extends State<SenderInfoTab>
    with AutomaticKeepAliveClientMixin<SenderInfoTab> {
  final FirestoreService _firestoreService = FirestoreService();
  // final _formKey_Sender = GlobalKey<FormState>();
  @override
  bool get wantKeepAlive => true;

  String senderId = '';
  String role = '';

  Future<void> _fetchSenderDeets() async {
    try {
      final userData = await _firestoreService.getUserData();

      if (userData != null) {
        setState(() {
          // Set the initial values for the sender's info fields
          widget.nameController.text = userData['name'] ?? '';
          widget.phoneController.text = userData['phone'] ?? '';
          senderId = userData['id'] ?? '';
          // Set other sender's info fields as needed
        });
      }

      widget.packageData.senderName = widget.nameController.text;
      widget.packageData.senderPhone = widget.phoneController.text;

      // Check if name and phone are empty, and show specific messages
      if (widget.nameController.text.isEmpty &&
          widget.phoneController.text.isEmpty) {
        DateTime timestamp = DateTime.now();
        EventLogger.logSenderOrderDetailsEvent(
          'high',
          timestamp.toString(),
          0,
          'alert',
          'alert_senderNameAndPhone',
          'Sender Name and Phone not available',
          {
            'senderid': senderId,
          },
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Warning"),
              content: const Text("Sender Name and Phone not available."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainSender(
                                getIndex: 0,
                              )),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else if (widget.nameController.text.isEmpty) {
        DateTime timestamp = DateTime.now();
        EventLogger.logSenderOrderDetailsEvent(
          'high',
          timestamp.toString(),
          0,
          'alert',
          'alert_senderNameUnavailable',
          'Sender Name not available',
          {
            'senderid': senderId,
          },
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Warning"),
              content: const Text("Sender Name not available."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainSender(
                                getIndex: 0,
                              )),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else if (widget.phoneController.text.isEmpty) {
        DateTime timestamp = DateTime.now();
        EventLogger.logSenderOrderDetailsEvent(
          'high',
          timestamp.toString(),
          0,
          'alert',
          'alert_senderPhoneUnavailable',
          'SenderPhone not available',
          {
            'senderid': senderId,
          },
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Warning"),
              content: const Text("Sender Phone not available."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainSender(
                                getIndex: 0,
                              )),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle the exception
      print("Error fetching sender details: $e");
      DateTime timestamp = DateTime.now();
      EventLogger.logSenderOrderDetailsEvent(
        'high',
        timestamp.toString(),
        0,
        'alert',
        'alert_senderUnfetchedDetails',
        'Sender details couldnt fetch',
        {
          'senderid': senderId,
        },
      );

      // Show an alert dialog with an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "Couldn't fetch sender details. Please try again later."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainSender(
                              getIndex: 0,
                            )),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSenderDeets();
    print("widgetto");
    print(widget.orderId);
    if (widget.orderId.isNotEmpty) {
      print("widget");
      // Fetch incomplete order details from Firestore and populate text controllers
      _fetchIncompleteOrderDetails();
    }
  }

  Future<void> _fetchIncompleteOrderDetails() async {
    try {
      print("Hello");
      final incompleteOrderData =
          await _firestoreService.getIncompleteDataToFirestore(widget.orderId);

      if (incompleteOrderData != null) {
        setState(() {
          // widget.nameController.text = incompleteOrderData['Sender Name'] ?? '';
          // widget.phoneController.text = incompleteOrderData['Sender Phone'] ?? '';
          widget.addressController.text =
              incompleteOrderData['Sender Address'] ?? '';
          widget.packageData.senderAddress =
              incompleteOrderData['Sender Address'] ?? '';
          widget.pincodeController.text =
              incompleteOrderData['Sender Pincode'] ?? '';
          widget.packageData.senderPincode =
              incompleteOrderData['Sender Pincode'] ?? '';
          widget.instructionController.text =
              incompleteOrderData['Instruction for Traveler'] ?? '';
          widget.packageData.senderInstruction =
              incompleteOrderData['Instruction for Traveler'] ?? '';
          widget.cityController.text = incompleteOrderData['Sender Room'] ?? '';
          widget.packageData.senderCity =
              incompleteOrderData['Sender Room'] ?? '';
          widget.stateController.text =
              incompleteOrderData['Sender Building'] ?? '';
          widget.packageData.senderState =
              incompleteOrderData['Sender Building'] ?? '';
        });
      }
    } catch (e) {
      // Handle the exception
      print("Error fetching incomplete order details: $e");
    }
  }

  TextEditingController senderAddressCtrl =
      TextEditingController(); // New controller for map auto-complete

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey_Sender,
        onChanged: () {},
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildTextField(
            'Name',
            Icons.person,
            widget.nameController.text,
            widget.nameController,
          ),
          const SizedBox(height: 16),
          buildTextField(
            'Phone Number',
            Icons.phone,
            widget.phoneController.text,
            widget.phoneController,
          ),
          const SizedBox(height: 16),
          ////
          const Text(
            "Enter Senders House Address ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: TextFormField(
                controller: widget.cityController,
                onTap: () {
                  DateTime timestamp = DateTime.now();
                  EventLogger.logSenderOrderDetailsEvent(
                    'low',
                    timestamp.toString(),
                    0,
                    'Textfield',
                    'tf_SenderFlatNo',
                    'Sender filling Sender Flat No.',
                    {
                      'senderid': senderId,
                    },
                  );
                },
                onChanged: (value) {
                  widget.packageData.senderCity = value;
                },
                // keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  // prefixIcon: Icon(Icons.alarm, color: AppColors.primary),
                  hintText: "Flat No.",
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: TextFormField(
                controller: widget.stateController,
                onTap: () {
                  DateTime timestamp = DateTime.now();
                  EventLogger.logSenderOrderDetailsEvent(
                    'low',
                    timestamp.toString(),
                    0,
                    'Textfield',
                    'tf_SendersBuilding',
                    'Sender filling Sender buiding name',
                    {
                      'senderid': senderId,
                    },
                  );
                },
                onChanged: (value) {
                  widget.packageData.senderState = value;
                },
                // keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  // prefixIcon: Icon(Icons.alarm, color: AppColors.primary),
                  hintText: "Building",
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          buildTextField(
            'Address',
            Icons.map_rounded,
            'Enter Building Number/Block/Landmark',
            widget.addressController,
            isMapAutoComplete: true, // Enable map autocomplete
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Location is required';
              }
              widget.packageData.senderAddress = value;
              return null;
            },
          ),

          const SizedBox(height: 16),
          buildTextField(
            'Pin Code',
            Icons.pin_rounded,
            'Enter Senders Pin Code',
            widget.pincodeController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'PinCode is required';
              }
              if (int.tryParse(value) == null || value.length != 6) {
                return 'Invalid PinCode';
              }
              widget.packageData.senderPincode = value;
              return null;
            },
          ),
          const SizedBox(height: 16),
          buildTextField(
            'Instruction for Traveler',
            Icons.chat_bubble,
            'Enter Any Instruction For Traveler...',
            widget.instructionController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                // Validate if the value is a string
              }
              widget.packageData.senderInstruction == value;
              return null; // No validation error if value is empty or a string
            },
          ),
          // SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget buildTextField(
    String label,
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator, // New parameter
    bool isMapAutoComplete = false,
  }) {
    bool isEnabled = true;

    // Check if the label is "Name" or "Phone Number" and disable those fields
    if (label == 'Name' || label == 'Phone Number') {
      isEnabled = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (isMapAutoComplete) // Check if it's a map autocomplete field
          MapAutoCompleteField(
            googleMapApiKey: "AIzaSyCfyl3MjY06VKC5br1KixRV2fYeEqLfC9I",
            controller: controller,
            itemBuilder: (BuildContext context, suggestion) {
              return ListTile(
                title: Text(suggestion.description),
              );
            },
            onSuggestionSelected: (suggestion) {
              if (label == 'Address') {
                controller.text = suggestion.description;
                widget.packageData.senderAddress = suggestion.description;
                DateTime timestamp = DateTime.now();
                EventLogger.logSenderOrderDetailsEvent(
                  'low',
                  timestamp.toString(),
                  0,
                  'DropDown',
                  'dd_SendersAddress',
                  'Sender filling Sender Address: ${suggestion.description} ',
                  {
                    'senderid': senderId,
                  },
                );
              }
            },
          )
        else
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            enabled: isEnabled,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            controller: controller, // Add this line to bind the controller
            onTap: () {
              DateTime timestamp = DateTime.now();
              EventLogger.logSenderOrderDetailsEvent(
                'low',
                timestamp.toString(),
                0,
                'Textfield',
                'tf_Sender$label',
                'Sender filling Sender $label',
                {
                  'senderid': senderId,
                },
              );
            },
            onChanged: (value) {
              // Update the corresponding field in packageData
              if (label == 'Name') {
                widget.packageData.senderName = widget.nameController.text;
              } else if (label == 'Phone Number') {
                widget.packageData.senderPhone = value;
              } else if (label == 'Address') {
                print('Autocompleted senderAddress: $value');
                widget.packageData.senderAddress = value;
              } else if (label == 'City') {
                widget.packageData.senderCity = value;
              } else if (label == 'State') {
                widget.packageData.senderState = value;
              } else if (label == 'Pin Code') {
                widget.packageData.senderPincode = value;
              } else if (label == 'Instruction for Traveler') {
                widget.packageData.senderInstruction = value;
              }
            }, // Validator function
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary),
              hintText: hint,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
      ],
    );
  }
}

class ReceiverInfoTab extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pincodeController;
  final PackageData packageData;
  final String orderId;

  const ReceiverInfoTab(
      {Key? key,
      required this.nameController,
      required this.phoneController,
      required this.addressController,
      required this.cityController,
      required this.stateController,
      required this.pincodeController,
      required this.packageData,
      required this.orderId})
      : super(key: key);

  @override
  State<ReceiverInfoTab> createState() => _ReceiverInfoTabState();
}

class _ReceiverInfoTabState extends State<ReceiverInfoTab>
    with AutomaticKeepAliveClientMixin<ReceiverInfoTab> {
  final FirestoreService _firestoreService = FirestoreService();

  String senderId = '';
  String role = '';

  Future<void> fetchSenderId() async {
    try {
      final userData = await _firestoreService.getUserData();
      if (userData != null) {
        setState(() {
          // Set the initial values for the sender's info fields
          senderId = userData['id'] ?? '';
        });
      }
    } catch (e) {
      // Handle the exception
      print("Error fetching sender details: $e");
      DateTime timestamp = DateTime.now();
      EventLogger.logSenderOrderDetailsEvent(
        'high',
        timestamp.toString(),
        0,
        'alert',
        'alert_senderUnfetchedDetails',
        'Sender details couldnt fetch',
        {
          'senderid': senderId,
        },
      );

      // Show an alert dialog with an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "Couldn't fetch sender details. Please try again later."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainSender(
                              getIndex: 0,
                            )),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSenderId();
    print("widgettoR");
    print(widget.orderId);
    print("Before setting nameController.text: ${widget.nameController.text}");
    if (widget.orderId.isNotEmpty) {
      print("widget");
      // Fetch incomplete order details from Firestore and populate text controllers
      _fetchIncompleteOrderDetailsR();
    }
  }

  Future<void> _fetchIncompleteOrderDetailsR() async {
    try {
      final incompleteOrderData =
          await _firestoreService.getIncompleteDataToFirestore(widget.orderId);

      if (incompleteOrderData != null) {
        // print(incompleteOrderData['Receiver Name']);
        setState(() {
          widget.nameController.text =
              incompleteOrderData['Receiver Name'] ?? '';
          widget.packageData.receiverName =
              incompleteOrderData['Receiver Name'] ?? '';
          widget.phoneController.text =
              incompleteOrderData['Receiver Phone'] ?? '';
          widget.packageData.receiverPhone =
              incompleteOrderData['Receiver Phone'] ?? '';
          widget.addressController.text =
              incompleteOrderData['Receiver Address'] ?? '';
          widget.packageData.receiverAddress =
              incompleteOrderData['Receiver Address'] ?? '';
          widget.pincodeController.text =
              incompleteOrderData['Receiver Pincode'] ?? '';
          widget.packageData.receiverPincode =
              incompleteOrderData['Receiver Pincode'] ?? '';
          widget.cityController.text =
              incompleteOrderData['Receiver Room'] ?? '';
          widget.packageData.receiverCity =
              incompleteOrderData['Receiver Room'] ?? '';
          widget.stateController.text =
              incompleteOrderData['Receiver Building'] ?? '';
          widget.packageData.receiverState =
              incompleteOrderData['Receiver Building'] ?? '';
        });
      }
    } catch (e) {
      // Handle the exception
      print("Error fetching incomplete order details: $e");
    }
  }

  // final _formKey_Receiver = GlobalKey<FormState>();
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        onChanged: () {},
        key: _formKey_Receiver,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.nameController,
                onChanged: (value) {
                  widget.packageData.receiverName = value;
                },
                onTap: () {
                  DateTime timestamp = DateTime.now();
                  EventLogger.logSenderOrderDetailsEvent(
                    'low',
                    timestamp.toString(),
                    0,
                    'Textfield',
                    'tf_ReceiverName',
                    'Sender filling Reciever name',
                    {
                      'senderid': senderId,
                    },
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: AppColors.primary),
                  hintText: 'Enter Receivers Name',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.phoneController,
                keyboardType: TextInputType.number,
                onTap: () {
                  DateTime timestamp = DateTime.now();
                  EventLogger.logSenderOrderDetailsEvent(
                    'low',
                    timestamp.toString(),
                    0,
                    'Textfield',
                    'tf_ReceiverPhone',
                    'Sender filling Reciever phone number',
                    {
                      'senderid': senderId,
                    },
                  );
                },
                onChanged: (value) {
                  widget.packageData.receiverPhone = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone Number is required';
                  }
                  if (int.tryParse(value) == null || value.length != 10) {
                    return 'Enter a Valid Number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                  hintText: 'Enter Receivers number',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            "Enter Receivers House Address ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: TextFormField(
                controller: widget.cityController,
                onTap: () {
                  DateTime timestamp = DateTime.now();
                  EventLogger.logSenderOrderDetailsEvent(
                    'low',
                    timestamp.toString(),
                    0,
                    'Textfield',
                    'tf_ReceiverFlat',
                    'Sender filling Reciever flat number',
                    {
                      'senderid': senderId,
                    },
                  );
                },
                onChanged: (value) {
                  widget.packageData.receiverCity = value;
                },
                // keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  // prefixIcon: Icon(Icons.alarm, color: AppColors.primary),
                  hintText: "Flat No.",
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: TextFormField(
                onTap: () {
                  DateTime timestamp = DateTime.now();
                  EventLogger.logSenderOrderDetailsEvent(
                    'low',
                    timestamp.toString(),
                    0,
                    'Textfield',
                    'tf_ReceiverBuilding',
                    'Sender filling Reciever building name',
                    {
                      'senderid': senderId,
                    },
                  );
                },
                onChanged: (value) {
                  widget.packageData.receiverState = value;
                },
                controller: widget.stateController,
                // keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  // prefixIcon: Icon(Icons.alarm, color: AppColors.primary),
                  hintText: "Building",
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          buildTextField(
            'Address',
            Icons.map_rounded,
            'Enter Building Number/Block/Landmark',
            widget.addressController,
            isMapAutoComplete: true, // Enable map autocomplete
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Location is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pin Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.pincodeController,
                onTap: () {
                  DateTime timestamp = DateTime.now();
                  EventLogger.logSenderOrderDetailsEvent(
                    'low',
                    timestamp.toString(),
                    0,
                    'Textfield',
                    'tf_ReceiverPinCode',
                    'Sender filling Reciever Pincode',
                    {
                      'senderid': senderId,
                    },
                  );
                },
                onChanged: (value) {
                  widget.packageData.receiverPincode = value;
                },
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'PinCode is required';
                  }
                  if (int.tryParse(value) == null || value.length != 6) {
                    return 'Invalid PinCode';
                  }
                  widget.packageData.receiverPincode = value;
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.pin_rounded, color: AppColors.primary),
                  hintText: 'Enter Receivers Pin Code',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          const SizedBox(height: 16),
          // const Text(
          //   "Enter Receivers Available time ",
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const SizedBox(height: 8),
          // Row(children: [
          //   SizedBox(
          //     width: MediaQuery.of(context).size.width / 3,
          //     child: TextFormField(
          //       keyboardType: TextInputType.number,
          //       decoration: InputDecoration(
          //         prefixIcon: Icon(Icons.alarm, color: AppColors.primary),
          //         hintText: "11:00",
          //         border: const OutlineInputBorder(),
          //         enabledBorder: OutlineInputBorder(
          //           borderSide: BorderSide(color: AppColors.inputBorder),
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         focusedBorder: OutlineInputBorder(
          //           borderSide: BorderSide(color: AppColors.primary),
          //           borderRadius: BorderRadius.circular(15),
          //         ),
          //       ),
          //     ),
          //   ),
          //   const SizedBox(width: 8),
          //   const Text(
          //     "to",
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   const SizedBox(width: 8),
          //   SizedBox(
          //     width: MediaQuery.of(context).size.width / 3,
          //     child: TextFormField(
          //       keyboardType: TextInputType.number,
          //       decoration: InputDecoration(
          //         prefixIcon: Icon(Icons.alarm, color: AppColors.primary),
          //         hintText: "21:00",
          //         border: const OutlineInputBorder(),
          //         enabledBorder: OutlineInputBorder(
          //           borderSide: BorderSide(color: AppColors.inputBorder),
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         focusedBorder: OutlineInputBorder(
          //           borderSide: BorderSide(color: AppColors.primary),
          //           borderRadius: BorderRadius.circular(15),
          //         ),
          //       ),
          //     ),
          //   ),
          // ]),
        ]),
      ),
    );
  }

  Widget buildTextField(
    String label,
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
    bool isMapAutoComplete = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (isMapAutoComplete) // Check if it's a map autocomplete field
          MapAutoCompleteField(
            googleMapApiKey: "AIzaSyCfyl3MjY06VKC5br1KixRV2fYeEqLfC9I",
            controller: controller,
            itemBuilder: (BuildContext context, suggestion) {
              return ListTile(
                title: Text(suggestion.description),
              );
            },
            onSuggestionSelected: (suggestion) {
              if (label == 'Address') {
                controller.text = suggestion.description;
                widget.packageData.receiverAddress = suggestion.description;
                DateTime timestamp = DateTime.now();
                EventLogger.logSenderOrderDetailsEvent(
                  'low',
                  timestamp.toString(),
                  0,
                  'DropDown',
                  'dd_ReceiverAddress',
                  'Sender filling Receiver Address: ${suggestion.description} ',
                  {
                    'senderid': senderId,
                  },
                );
              }
            },
          )
        else
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            onTap: () {
              DateTime timestamp = DateTime.now();
              EventLogger.logSenderOrderDetailsEvent(
                'low',
                timestamp.toString(),
                0,
                'Textfield',
                'tf_Receiver$label',
                'Sender filling Receiver $label',
                {
                  'senderid': senderId,
                },
              );
            },
            onChanged: (value) {
              // Update the corresponding field in packageData
              if (label == 'Name') {
                widget.packageData.receiverName = value;
              } else if (label == 'Phone Number') {
                widget.packageData.receiverPhone = value;
              } else if (label == 'Address') {
                print('Autocompleted recieverAddress: $value');
                widget.packageData.receiverAddress = value;
              } else if (label == 'City') {
                widget.packageData.receiverCity = value;
              } else if (label == 'State') {
                widget.packageData.receiverState = value;
              } else if (label == 'Pin Code') {
                widget.packageData.receiverPincode = value;
              }
            }, // Validator function
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary),
              hintText: hint,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
      ],
    );
  }
}
// .
