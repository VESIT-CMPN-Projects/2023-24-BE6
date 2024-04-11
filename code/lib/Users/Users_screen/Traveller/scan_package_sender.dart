import 'package:deliveryx/Users/Users_screen/Traveller/current_user_location.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../eventlogger.dart';

class ScanPackageSender extends StatefulWidget {
  final String barcodeScanRes;
  const ScanPackageSender({Key? key, required this.barcodeScanRes})
      : super(key: key);

  @override
  State<ScanPackageSender> createState() => _ScanPackageSenderState();
}

class _ScanPackageSenderState extends State<ScanPackageSender> {
  String imageUrl = '';
  String currentuserId = FirebaseAuth.instance.currentUser!.uid;
  File? capturedImage;
  bool isUploading =
      false; // to track whether the image is currently being uploaded

  @override
  void initState() {
    super.initState();
    EventLogger.logScanPackageEvent(
      'low',
      DateTime.now().toString(),
      1,
      'traveler',
      'SenderPackageScanViewed',
      'Sender side package scan page viewed',
      {'travelerid': ''},
    );
  }

  // Function to upload the captured image to Firebase Storage and get download url
  Future<void> uploadImage() async {
    if (capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture an image')),
      );
      return;
    }

    // for progress indicator
    setState(() {
      isUploading = true;
    });

    try {
      // Get a reference to storage root
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages =
          referenceRoot.child('scan_package(traveler-sender)');

      // Create a reference for the image to be stored using the barcodeScanRes
      String barcodeScanRes = widget.barcodeScanRes;
      Reference referenceImageToUpload =
          referenceDirImages.child('$barcodeScanRes.png');

      // Store the file
      await referenceImageToUpload.putFile(capturedImage!);

      // Success: get the download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();
      print("imageurl:\n$imageUrl");

      // Log the event for image upload successful
      EventLogger.logScanPackageEvent(
        'medium',
        DateTime.now().toString(),
        1,
        'traveler',
        'SenderImageUploadSuccess',
        'Sender side image upload successful',
        {'travelerid': ''},
      );

      await getSenderId(imageUrl);

      // Log the event for package scan successful
      EventLogger.logScanPackageEvent(
        'high',
        DateTime.now().toString(),
        1,
        'traveler',
        'SenderPackageScanSuccessfull',
        'Sender side package scan successful',
        {'travelerid': ''},
      );
    } catch (error) {
      print("error: $error");

      // Log the event for image upload failure
      EventLogger.logScanPackageEvent(
        'medium',
        DateTime.now().toString(),
        1,
        'traveler',
        'SenderImageUploadFailed',
        'Sender side image upload failed',
        {'travelerid': ''},
      );

      // Log the event for package scan failure
      EventLogger.logScanPackageEvent(
        'high',
        DateTime.now().toString(),
        1,
        'traveler',
        'SenderPackageScanFailed',
        'Sender side package scan failed',
        {'travelerid': ''},
      );
    } finally {
      //  hide the progress indicator
      setState(() {
        isUploading = false;
      });
    }
  }

  // Function to get the senderid
  Future<void> getSenderId(String imageUrl) async {
    try {
      print("currentuserid:$currentuserId");
      String orderId = widget.barcodeScanRes;

      // Query the accepted orders collection to get the senderId
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentuserId)
              .collection('travelers')
              .doc(currentuserId)
              .collection('Accepted orders')
              .where('orderId', isEqualTo: orderId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        String senderId = querySnapshot.docs.first['senderId'];

        print('Sender ID: $senderId');

        await updateOrderWithImageUrl(senderId, orderId, imageUrl);

        // Log the event for getting senderId and updating order image URL successfully
        EventLogger.logScanPackageEvent(
          'medium',
          DateTime.now().toString(),
          1,
          'traveler',
          'GetSenderAndImageUpdateSuccess',
          'Sender ID obtained and order image URL updated successfully',
          {'travelerid': ''},
        );
      } else {
        // Log the event for failure to find order ID
        EventLogger.logScanPackageEvent(
          'medium',
          DateTime.now().toString(),
          1,
          'traveler',
          'OrderIDNotFound',
          'Order ID not found in accepted orders',
          {'travelerid': ''},
        );

        // Show a snackbar if the orderId is not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order ID not found')),
        );
      }
    } catch (error) {
      print("Error updating sender's collection with imageurl: $error");
      // Log the event for failure to get sender ID and update order image URL
      EventLogger.logScanPackageEvent(
        'high',
        DateTime.now().toString(),
        1,
        'traveler',
        'GetSenderAndImageUpdateFailed',
        'Failed to get sender ID or update order image URL',
        {'travelerid': ''},
      );
    }
  }

  Future<void> updateOrderWithImageUrl(
      String senderId, String orderId, String imageUrl) async {
    try {
      CollectionReference ordersCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('orders');

      DocumentReference orderDocument = ordersCollection.doc(orderId);

      await orderDocument.update({
        'scan_package_sender': imageUrl,
      });

      print('Image URL updated successfully for order $orderId');
    } catch (error) {
      // Log the event for failure to update order image URL
      EventLogger.logScanPackageEvent(
        'high',
        DateTime.now().toString(),
        1,
        'traveler',
        'UpdateImageURLFailed',
        'Failed to update order image URL',
        {'travelerid': ''},
      );
      Navigator.pop(context);
      print('Error updating image URL: $error');
    }
  }

  Future<String> getSenderFromOrder(orderId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(currentuserId)
        .collection('travelers')
        .doc(currentuserId)
        .collection('Accepted orders')
        .where('orderId', isEqualTo: orderId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String senderId = querySnapshot.docs.first['senderId'];
      return senderId;
    }
    return "null";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Package',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        toolbarHeight: 80,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                  child: Text(
                      'Ensure that the package is clearly visible and in good condition',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                      ))),

              const SizedBox(height: 50),

              // Display the captured image
              capturedImage != null
                  ? Image.file(
                      capturedImage!,
                      height: 300,
                      width: 300,
                    )
                  : Container(),

              const SizedBox(height: 20),

              Container(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Log the event for clicking on the capture button
                          EventLogger.logScanPackageEvent(
                            'low',
                            DateTime.now().toString(),
                            1,
                            'traveler',
                            'b_CapturePackageImage',
                            'Capture package image button clicked',
                            {'travelerid': ''},
                          );

                          // Log the event for starting package scan
                          EventLogger.logScanPackageEvent(
                            'low',
                            DateTime.now().toString(),
                            1,
                            'traveler',
                            'SenderPackageScanStarted',
                            'Sender side package scan started',
                            {'travelerid': ''},
                          );

                          // 1. capture image
                          ImagePicker imagePicker = ImagePicker();
                          XFile? file = await imagePicker.pickImage(
                              source: ImageSource.camera);
                          print('${file?.path}');

                          if (file == null) return;

                          // Store the captured image file
                          setState(() {
                            capturedImage = File(file.path);
                          });
                        },
                        icon: Icon(Icons.camera_alt_rounded,
                            color: AppColors.black),
                        label: Text(
                          'Capture',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          side: BorderSide(
                            width: 2,
                            color: AppColors.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                          minimumSize:
                              const Size(double.infinity, 0), // Full width
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA084E8),
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      onPressed: isUploading
                          ? null // Disable button while uploading
                          : () async {
                              // Log the event for clicking on the submit button
                              EventLogger.logScanPackageEvent(
                                'low',
                                DateTime.now().toString(),
                                1,
                                'traveler',
                                'b_SubmitPackageImage',
                                'Submit package image button clicked',
                                {'travelerid': ''},
                              );
                              await uploadImage();
                              // Check if the image was uploaded successfully
                              // String senderId = await getSenderFromOrder(
                              //     widget.barcodeScanRes);
                              if (imageUrl.isNotEmpty) {
                                // Navigate to the next page only if the image was uploaded
                                String senderId = await getSenderFromOrder(
                                    widget.barcodeScanRes);
                                final orderInfo = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(senderId)
                                    .collection('orders')
                                    .doc(widget.barcodeScanRes)
                                    .set({'Status': 'Picked'},
                                        SetOptions(merge: true));
                                final travelerStatus = FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(currentuserId)
                                    .collection('travelers')
                                    .doc(currentuserId)
                                    .collection('Accepted orders')
                                    .doc(widget.barcodeScanRes)
                                    .set({'Status': 'Picked'},
                                        SetOptions(merge: true));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GetUserCurrentLocationScreen(
                                      orderId: widget.barcodeScanRes,
                                      senderId: senderId,
                                      prevPage: 2,
                                    ),
                                  ),
                                );
                              }
                            },
                      child: isUploading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
