import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import './proceed_traveler_page.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/main_traveller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FaceDetector extends StatefulWidget {
  const FaceDetector({super.key});

  @override
  State<FaceDetector> createState() => _FaceDetectorState();
}

class _FaceDetectorState extends State<FaceDetector> {
  GlobalKey<FormState> key = GlobalKey();

  String imageUrl = '';
  bool isImageCaptured = false;
  File? capturedImage;
  bool isUploading =
      false; // to track whether the image is currently being uploaded

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
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages =
          referenceRoot.child('traveler_check_face_liveliness_images');

      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);

      // Store the file
      await referenceImageToUpload.putFile(capturedImage!);

      // Set metadata
      SettableMetadata metadata = SettableMetadata(contentType: 'image/png');

// Store the file with metadata
      await referenceImageToUpload.putFile(capturedImage!, metadata);

      // Success: get the download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();

      navigate();

      // After uploading image, make API call and handle the response
      if (imageUrl.isNotEmpty) {
        await sendPhotoForLivenessCheck(imageUrl);
      }

      print("imageurl:\n$imageUrl");
    } catch (error) {
      print("error: $error");
    } finally {
      //  hide the progress indicator
      setState(() {
        isUploading = false;
      });
    }
  }

  void navigate() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc =
          FirebaseFirestore.instance.collection("users").doc(currentUser.uid);

      final userData = await userDoc.get();

      if (userData.exists) {
        final role = userData.get("role");
        final traveler = userData.get("traveler");

        // if (role == -1 && !traveler) {
        if (!traveler) {
          // Update role to 1 and traveler to true
          // await userDoc.update({"role": 1, "traveler": true});

          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .get();

          if (userSnapshot.exists) {
            // we Get user data from the snapshot
            String email = userSnapshot.get("email");
            String name = userSnapshot.get("name");
            String phone = userSnapshot.get("phone");
            String location = userSnapshot.get("location");

            // we Add user information to the "travelers" subcollection
            await FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.uid)
                .collection("travelers")
                .doc(currentUser.uid)
                .set({
              "email": email,
              "name": name,
              "phone": phone,
              "location": location,
              "image_liveface": imageUrl,
            });

            // await FirebaseFirestore.instance
            //     .collection("users")
            //     .doc(currentUser.uid)
            //     .collection("travelers")
            //     .doc(currentUser.uid)
            //     .collection("wallet")
            //     .add({
            //   "balance": 50,
            // });
          }
        }
      }
    }
  }

//   void showLoadingDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
//     builder: (BuildContext context) {
//       return const AlertDialog(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Uploading and processing..."),
//           ],
//         ),
//       );
//     },
//   );
// }

  Future<void> sendPhotoForLivenessCheck(String imageUrl) async {
    const apiUrl =
        'https://eve.idfy.com/v3/tasks/sync/check_photo_liveness/face';
    final headers = {
      'Content-Type': 'application/json',
      'api-key': '493baded-2128-4268-aa76-5f23d7eafa38',
      'account-id': 'b3ec58295bd0/cba752d8-cad6-4c0e-9bdb-498e143edd91'
    };

    final body = jsonEncode({
      'task_id': '74f4c926-250c-43ca-9c53-453e87ceacd1',
      'group_id': '8e16424a-58fc-4ba4-ab20-5bc8e7c3c41e',
      'data': {
        'document1': imageUrl,
        'detect_face_mask': true,
        'detect_front_facing': true,
        'detect_nsfw': true,
      },
    });

    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: body);
    if (response.statusCode == 200) {
      final apiResponse = jsonDecode(response.body);
      // Handle the API response
      handleApiResponse(apiResponse);
    } else {
      // Handle API error
      // Show error message or take appropriate action
      print("Error: ${response.statusCode}");
    }
  }

  // Function to handle API response and show results in a modal bottom sheet
  void handleApiResponse(Map<String, dynamic> apiResponse) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ResultSheet(
            apiResponse: apiResponse,
            onTryAgain: () {
              Navigator.pop(context); // Close the bottom sheet
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Face Liveliness Detection',
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

              InkWell(
                child: Text(
                  'Ensure that your face is clearly visible and not blurr/cropped',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

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
                          if (isImageCaptured) {
                            // Open gallery to upload another picture
                            ImagePicker imagePicker = ImagePicker();
                            XFile? file = await imagePicker.pickImage(
                              source: ImageSource.camera,
                            );
                            print('${file?.path}');

                            if (file == null) return;

                            // Update the captured image file
                            setState(() {
                              capturedImage = File(file.path);
                            });
                          } else {
                            // Capture image
                            ImagePicker imagePicker = ImagePicker();
                            XFile? file = await imagePicker.pickImage(
                              source: ImageSource.camera,
                            );
                            print('${file?.path}');

                            if (file == null) return;

                            // Store the captured image file
                            setState(() {
                              capturedImage = File(file.path);
                              isImageCaptured = true;
                            });
                          }
                        },
                        icon: Icon(Icons.camera_alt_rounded,
                            color: AppColors.black),
                        label: Text(
                          // 'Capture',
                          isImageCaptured ? 'Recapture' : 'Capture',
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
                              await uploadImage();
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

class ResultSheet extends StatelessWidget {
  final Map<String, dynamic> apiResponse;
  final VoidCallback onTryAgain;

  const ResultSheet(
      {super.key, required this.apiResponse, required this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    // Extracting values from the API response
    bool isLive = apiResponse['result']['is_live'];
    bool areEyesOpen = apiResponse['result']['are_eyes_open'];
    bool faceMaskDetected = apiResponse['result']['face_mask_detected'];
    bool isFaceCropped = apiResponse['result']['is_face_cropped'];
    bool isFrontFacing = apiResponse['result']['is_front_facing'];
    bool isNsfw = apiResponse['result']['is_nsfw'];
    bool multipleFacesDetected =
        apiResponse['result']['multiple_faces_detected'];

    // Professional text and condition for result
    String resultText;
    bool canProceed = true; // Flag to check if all conditions are met

    // Print the boolean values to the console
    print('isLive: $isLive');
    print('areEyesOpen: $areEyesOpen');
    print('faceMaskDetected: $faceMaskDetected');
    print('isFaceCropped: $isFaceCropped');
    print('isFrontFacing: $isFrontFacing');
    print('isNsfw: $isNsfw');
    print('multipleFacesDetected: $multipleFacesDetected');
    if (isLive &&
        areEyesOpen &&
        !faceMaskDetected &&
        !isFaceCropped &&
        isFrontFacing &&
        !isNsfw &&
        !multipleFacesDetected) {
      // All conditions are met
      resultText = "All conditions are met. You are ready to proceed!";
    } else {
      canProceed = false;

      if (multipleFacesDetected) {
        resultText = "Multiple faces detected.";
      } else if (!areEyesOpen) {
        resultText = "Your eyes should be open.";
      } else if (faceMaskDetected) {
        resultText = "Remove any kind of covering from your face.";
      } else if (isFaceCropped) {
        resultText = "Face is cropped.";
      } else if (isFrontFacing) {
        resultText = "Look front in your camera.";
      } else if (isNsfw) {
        resultText = "Image not safe for work.";
      } else {
        resultText =
            "There is an issue with the captured image. Please try again.";
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Liveness Check Result',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            resultText,
            style: TextStyle(
              fontSize: 16,
              color: canProceed ? Colors.green : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (canProceed)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 0), // Full width
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainTraveller(
                      getIndex: 0,
                    ),
                  ),
                );

                // Update role to 1 and traveler to true
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  final userDoc = FirebaseFirestore.instance
                      .collection("users")
                      .doc(currentUser.uid);

                  await userDoc.update({
                    "role": 1,
                    "traveler": true,
                  });
                }
              },
              child: Text(
                'Proceed',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 0), // Full width
              ),
              onPressed: onTryAgain,
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
