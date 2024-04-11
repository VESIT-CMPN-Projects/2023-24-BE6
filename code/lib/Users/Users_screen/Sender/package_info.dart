import 'package:deliveryx/Users/Users_screen/Sender/payment_summary.dart';
import 'package:deliveryx/Users/Users_screen/eventlogger.dart';
import 'package:deliveryx/provider/senderProvider.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/firestore.dart';
import '../tandc.dart';

class PackageInfo extends StatefulWidget {
  final String senderName;
  final String senderPhone;
  final String senderAddress;
  final String senderCity;
  final String senderState;
  final String senderPincode;
  final String senderInstruction;
  final String orderId;

  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final String receiverCity;
  final String receiverState;
  final String receiverPincode;
  final double senderGeocodeLat;
  final double senderGeocodeLon;

  const PackageInfo({
    super.key,
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.senderCity,
    required this.senderState,
    required this.senderPincode,
    required this.senderInstruction,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.receiverCity,
    required this.receiverState,
    required this.receiverPincode,
    required this.senderGeocodeLat,
    required this.senderGeocodeLon,
    required this.orderId,
  });

  @override
  State<StatefulWidget> createState() {
    return PackageFormState(this);
  }
}

class PackageFormState extends State<PackageInfo> {
  final FirestoreService _firestoreService = FirestoreService();
  final PackageInfo packageInfo;
  PackageFormState(this.packageInfo);
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
    fetchSenderId().then((_) {
      DateTime timestamp = DateTime.now();

      // Log the event when the login page is loaded
      EventLogger.logSenderOrderDetailsEvent(
        'low',
        timestamp.toString(),
        0,
        'sender',
        'PackageDetailsStarted',
        'Package Details started',
        {
          'senderid': senderId,
        },
      );
    });
    if (widget.orderId.isNotEmpty) {
      _fetchIncompleteOrderDetails();
    }
  }

  Future<void> _fetchIncompleteOrderDetails() async {
    try {
      final incompleteOrderData =
          await _firestoreService.getIncompleteDataToFirestore(widget.orderId);

      if (incompleteOrderData != null) {
        setState(() {
          _textEditingController.text =
              incompleteOrderData['Package Value']?.toString() ?? '';
          _dropdownValue1 = incompleteOrderData['Package Category'] as String?;
          dropdownValue2 = incompleteOrderData['Package Weight'] as String?;
          _dropdownValue3 = incompleteOrderData['Package Size'] as String?;
          isChecked = incompleteOrderData['acceptedTerms'] as bool? ?? false;

          if (_dropdownValue1 == "Other") {
            toggleVisibility();
            temp = 0;
          } else if (_dropdownValue1 != "Other" && temp == 0) {
            toggleVisibility();
            temp++;
          }
        });
      }
    } catch (e) {
      print("Error fetching incomplete order details: $e");
    }
  }

  bool isInput1Visible = false;
  bool isInput2Visible = false;
  bool isChecked = false;
  bool handleWithCare = false;
  var _dropdownValue1;
  var dropdownValue2;
  var _dropdownValue3;
  var temp = 1;
  var temp2 = 0;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingControllerDescription =
      TextEditingController();

  void showAlert() {
    if (_textEditingController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Package Value is 0'),
            content: const Text(
                "We won't be able to provide any insurance for your package"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  temp2--;

                  final FirestoreService firestoreService = FirestoreService();

                  // final result = firestoreService
                  //     .addIncompleteDataWithStatus(
                  //   packageInfo: packageInfo,
                  //   textEditingController: _textEditingController,
                  //   dropdownValue1: _dropdownValue1,
                  //   textEditingControllerDescription:
                  //       _textEditingControllerDescription,
                  //   dropdownValue2: dropdownValue2,
                  //   dropdownValue3: _dropdownValue3,
                  //   isChecked: isChecked,
                  //   orderId: widget.orderId,
                  //   status : 'incomplete',
                  // );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => payment_summary(
                              packageInfo: packageInfo,
                              textEditingController: _textEditingController,
                              dropdownValue1: _dropdownValue1,
                              textEditingControllerDescription:
                                  _textEditingControllerDescription,
                              dropdownValue2: dropdownValue2,
                              dropdownValue3: _dropdownValue3,
                              isChecked: isChecked,
                              orderId: widget.orderId,
                              handleWithCare: handleWithCare,
                            )),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Initial visibility state

  void toggleVisibility() {
    setState(() {
      isInput1Visible = !isInput1Visible; // Toggle visibility
    });
  }

  void toggleImage() {
    setState(() {
      isInput2Visible = !isInput2Visible; // Toggle visibility
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text("Package Details")),
      body: WillPopScope(
        onWillPop: () async {
          DateTime timestamp = DateTime.now();
          EventLogger.logSenderOrderDetailsEvent(
            'high',
            timestamp.toString(),
            0,
            'button',
            'b_LeftArrow',
            'Package Details cancelled',
            {
              'senderid': senderId,
            },
          );
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Value of Package",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: 'Enter value in INR',
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onTap: () {
                          DateTime timestamp = DateTime.now();
                          EventLogger.logSenderOrderDetailsEvent(
                            'low',
                            timestamp.toString(),
                            0,
                            'Textfield',
                            'tf_PackageValue',
                            'User entered the value of package for insurance purpose',
                            {
                              'senderid': senderId,
                            },
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the value';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Category",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        items: const [
                          DropdownMenuItem(
                            value: "Electronics",
                            child: Text("Electronics"),
                          ),
                          DropdownMenuItem(
                            value: "Food",
                            child: Text("Food"),
                          ),
                          DropdownMenuItem(
                            value: "Fabric",
                            child: Text("Fabric"),
                          ),
                          DropdownMenuItem(
                            value: "Document",
                            child: Text("Document"),
                          ),
                          DropdownMenuItem(
                            value: "Jewelery",
                            child: Text("Jewelery"),
                          ),
                          DropdownMenuItem(
                            value: "Other",
                            child: Text("Other"),
                          ),
                        ],
                        value: _dropdownValue1,
                        onChanged: (String? selectedValue1) {
                          if (selectedValue1 is String) {
                            setState(() {
                              _dropdownValue1 = selectedValue1;
                              if (selectedValue1 == "Other") {
                                toggleVisibility();
                                temp = 0;
                              } else if (selectedValue1 != "Other" &&
                                  temp == 0) {
                                toggleVisibility();
                                temp++;
                              }
                              // Size size = MediaQuery.sizeOf();
                            });
                            DateTime timestamp = DateTime.now();
                            EventLogger.logSenderOrderDetailsEvent(
                              'low',
                              timestamp.toString(),
                              0,
                              'DropDown',
                              'dd_Category',
                              'User selects the ${selectedValue1.toString()} item from dropdown',
                              {
                                'senderid': senderId,
                              },
                            );
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Select a category',
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Visibility(
                        visible: isInput1Visible,
                        child: TextFormField(
                            controller: _textEditingControllerDescription,
                            onTap: () {
                              DateTime timestamp = DateTime.now();
                              EventLogger.logSenderOrderDetailsEvent(
                                'low',
                                timestamp.toString(),
                                0,
                                'Textfield',
                                'tf_OtherPackageCategory',
                                'User fills Other Category',
                                {
                                  'senderid': senderId,
                                },
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please describe your parcel';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Describe your Package',
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            )),
                      ),
                      const SizedBox(height: 15),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Weight",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                          items: const [
                            DropdownMenuItem(
                              value: "Upto 1 kg",
                              child: Text("Upto 1 kg"),
                            ),
                            DropdownMenuItem(
                              value: "Upto 3 kg",
                              child: Text("Upto 3 kg"),
                            ),
                            DropdownMenuItem(
                              value: "Upto 5 kg",
                              child: Text("Upto 5 kg"),
                            ),
                          ],
                          value: dropdownValue2,
                          onChanged: (String? selectedValue2) {
                            if (selectedValue2 is String) {
                              setState(() {
                                dropdownValue2 = selectedValue2;
                              });
                              DateTime timestamp = DateTime.now();
                              EventLogger.logSenderOrderDetailsEvent(
                                'low',
                                timestamp.toString(),
                                0,
                                'DropDown',
                                'dd_Weight',
                                'User selects the ${selectedValue2.toString()} item from dropdown',
                                {
                                  'senderid': senderId,
                                },
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a weight category';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Select a category',
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          )),
                      const SizedBox(height: 15),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Size",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                          items: const [
                            DropdownMenuItem(
                              value: "Small",
                              child: Text("Small"),
                            ),
                            DropdownMenuItem(
                              value: "Medium",
                              child: Text("Medium"),
                            ),
                            DropdownMenuItem(
                              value: "Large",
                              child: Text("Large"),
                            ),
                            DropdownMenuItem(
                              value: "Xtra Large",
                              child: Text("Xtra Large"),
                            ),
                          ],
                          value: _dropdownValue3,
                          onChanged: (String? selectedValue3) {
                            if (selectedValue3 is String) {
                              setState(() {
                                _dropdownValue3 = selectedValue3;
                              });
                              DateTime timestamp = DateTime.now();
                              EventLogger.logSenderOrderDetailsEvent(
                                'low',
                                timestamp.toString(),
                                0,
                                'DropDown',
                                'dd_Size',
                                'User selects the ${selectedValue3.toString()} item from dropdown',
                                {
                                  'senderid': senderId,
                                },
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a size category';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Select a category',
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          )),
                      const SizedBox(height: 15),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          setState(() {
                            toggleImage();
                          });
                          DateTime timestamp = DateTime.now();
                          EventLogger.logSenderOrderDetailsEvent(
                            'low',
                            timestamp.toString(),
                            0,
                            'Textbutton',
                            'tb_SizeGuide',
                            'User taps to view the size guide',
                            {
                              'senderid': senderId,
                            },
                          );
                        },
                        child: Text(
                          'Size Guide',
                          style: TextStyle(fontSize: 14, color: AppColors.grey),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Visibility(
                        visible: isInput2Visible,
                        child: Image.asset(
                            'assets/third-party_images/images/sizeguide.jpg'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: handleWithCare,
                            onChanged: (newValue) {
                              setState(() {
                                handleWithCare = newValue!;
                              });
                              if (newValue == true) {
                                DateTime timestamp = DateTime.now();
                                EventLogger.logSenderOrderDetailsEvent(
                                  'low',
                                  timestamp.toString(),
                                  0,
                                  'CheckBox',
                                  'cb_Fragile',
                                  'Fragile item in package',
                                  {
                                    'senderid': senderId,
                                  },
                                );
                              }
                            },
                            activeColor: AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Image.asset(
                            'assets/third-party_images/images/fragiletag.jpg',
                            width: 144,
                            height: 80,
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  isChecked = newValue!;
                                });
                                if (newValue == true) {
                                  DateTime timestamp = DateTime.now();
                                  EventLogger.logSenderOrderDetailsEvent(
                                    'low',
                                    timestamp.toString(),
                                    0,
                                    'CheckBox',
                                    'cb_TnC',
                                    'Agrees with Terms and Conditions ',
                                    {
                                      'senderid': senderId,
                                    },
                                  );
                                }
                              },
                              activeColor: AppColors.primary,
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle navigation to the new page here
                                // For example:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const TermsAndConditionsPage()),
                                );

                                DateTime timestamp = DateTime.now();
                                EventLogger.logSenderOrderDetailsEvent(
                                  'low',
                                  timestamp.toString(),
                                  0,
                                  'Link',
                                  'cb_TnCLink',
                                  'Navigated to Terms and Conditions Screen',
                                  {
                                    'senderid': senderId,
                                  },
                                );
                              },
                              child: const Text(
                                'I accept the terms and conditions',
                                style: TextStyle(
                                  color:
                                      Colors.purple, // Set text color to purple
                                  decoration: TextDecoration
                                      .underline, // Underline the text
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Place Order Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: isChecked
                          ? () async {
                              print('Button pressed');
                              Sender newSender = Sender(
                                senderName: widget.senderName,
                                senderNumber: widget.senderPhone,
                                insuranceAmt:
                                    int.tryParse(_textEditingController.text) ??
                                        0,
                                location1: widget.senderAddress,
                                location2: widget.receiverAddress,
                                weight: dropdownValue2,
                                size: _dropdownValue3,
                              );
                              Provider.of<SenderProvider>(context,
                                      listen: false)
                                  .updateSender(newSender);
                              if (_formKey.currentState!.validate()) {
                                DateTime timestamp = DateTime.now();
                                EventLogger.logSenderOrderDetailsEvent(
                                  'high',
                                  timestamp.toString(),
                                  0,
                                  'button',
                                  'b_ProceedPayment',
                                  'User places the order and proceeds for payment',
                                  {
                                    'senderid': senderId,
                                  },
                                );
                                print('Event logged');
                                if (_textEditingController.text == '0') {
                                  showAlert();
                                  temp2++;
                                }
                                if (temp2 == 0) {
                                  final FirestoreService firestoreService =
                                      FirestoreService();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => payment_summary(
                                        packageInfo: packageInfo,
                                        textEditingController:
                                            _textEditingController,
                                        dropdownValue1: _dropdownValue1,
                                        textEditingControllerDescription:
                                            _textEditingControllerDescription,
                                        dropdownValue2: dropdownValue2,
                                        dropdownValue3: _dropdownValue3,
                                        isChecked: isChecked,
                                        orderId: widget.orderId,
                                        handleWithCare: handleWithCare,
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Text("Proceed for payment")),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      // ),
    );
  }
}
