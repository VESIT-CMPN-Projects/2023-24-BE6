import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:deliveryx/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Users/Users_screen/Sender/package_info.dart';

class PackageData {
  String senderName = '';
  String senderPhone = '';
  String senderAddress = '';
  String senderCity = '';
  String senderState = '';
  String senderPincode = '';
  String senderInstruction = '';

  String receiverName = '';
  String receiverPhone = '';
  String receiverAddress = '';
  String receiverCity = '';
  String receiverState = '';
  String receiverPincode = '';
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

//Switch of Roles
  Future<void> updateUserRole(String userId, int newRole) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection("users").doc(userId);

      await userDoc.update({"role": newRole});
    } catch (e, stackTrace) {
      print("Error updating user role: $e");
      print(stackTrace);
      rethrow;
    }
  }

//Get any Data from Users Collection
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        return null;
      }

      final userDoc =
          FirebaseFirestore.instance.collection("users").doc(currentUser.uid);
      print(userDoc);

      final userData = await userDoc.get();
      print(userData);

      if (userData.exists) {
        return userData.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      // Handle the exception
      print("Error getting orders stream: $e");
      print(stackTrace);
      rethrow;
    }
  }

//get All orders for the current user (sender)
  Future<Stream<QuerySnapshot>?> getOrdersStreamForCurrentUser() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        return FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('orders')
            .orderBy('Timestamp', descending: true)
            .snapshots();
      } else {
        return null; // Handle the case when currentUser is null
      }
    } catch (e, stackTrace) {
      // Handle the exception and log the stack trace for debugging
      print("Error getting orders stream: $e");
      print(stackTrace);
      rethrow;
      // You might want to throw a custom exception or return an error state
    }
  }

  Future<Stream<QuerySnapshot>?>
      getIncompleteOrdersStreamForCurrentUser() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        return FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('Incomplete Orders')
            .where('Status', whereIn: ['incomplete', 'Payment Failure'])
            .orderBy('Timestamp', descending: true)
            .snapshots();
      } else {
        return null; // Handle the case when currentUser is null
      }
    } catch (e, stackTrace) {
      // Handle the exception and log the stack trace for debugging
      print("Error getting orders stream: $e");
      print(stackTrace);
      rethrow;
      // You might want to throw a custom exception or return an error state
    }
  }

//get orders according to status for Current user (Sender) - Pending,Ongoing,Completed tabs
  Future<Stream<QuerySnapshot>?> getOrdersStreamForCurrentUserStatus(
      String status) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        return FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('orders')
            .where('Status', isEqualTo: status)
            .orderBy('Timestamp', descending: true)
            .snapshots();
      } else {
        return null; // Handle the case when currentUser is null
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print("Error getting orders stream for status '$status': $e");
      print(stackTrace);
      rethrow;
    }
  }

  Future<Stream<QuerySnapshot>?>
      getOrdersProcessingPendingStreamForCurrentUserStatus(
          String status1, String status2) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        return FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('orders')
            .where('Status', whereIn: [status1, status2])
            .orderBy('Timestamp', descending: true)
            .snapshots();
      } else {
        return null; // Handle the case when currentUser is null
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print("Error getting orders stream for status '$status1': $e");
      print(stackTrace);
      rethrow;
    }
  }

//add completely filled order to firestore
  Future<void> addDataToFirestore({
    required PackageInfo packageInfo,
    required TextEditingController textEditingController,
    required String dropdownValue1,
    required TextEditingController textEditingControllerDescription,
    required String dropdownValue2,
    required String dropdownValue3,
    required bool isChecked,
    required double totalCost,
    String? orderId, // Add orderId as a parameter
    required bool handleWithCare,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      final data = {
        'Sender Name': packageInfo.senderName,
        'Sender Phone': packageInfo.senderPhone,
        'Sender Address': packageInfo.senderAddress,
        'Sender Room': packageInfo.senderCity,
        'Sender Building': packageInfo.senderState,
        'Sender Pincode': packageInfo.senderPincode,
        'Instruction for Traveler': packageInfo.senderInstruction,
        'Receiver Name': packageInfo.receiverName,
        'Receiver Phone': packageInfo.receiverPhone,
        'Receiver Address': packageInfo.receiverAddress,
        'Receiver Room': packageInfo.receiverCity,
        'Receiver Building': packageInfo.receiverState,
        'Receiver Pincode': packageInfo.receiverPincode,
        'Package Value': textEditingController.text,
        'Package Category': dropdownValue1,
        'Package Description': textEditingControllerDescription.text,
        'Package Weight': dropdownValue2,
        'Package Size': dropdownValue3,
        'acceptedTerms': isChecked,
        'userid': user?.uid,
        'Status': 'Active',
        'Timestamp': FieldValue.serverTimestamp(),
        'Sender Geocode Lat': packageInfo.senderGeocodeLat,
        'Sender Geocode Lon': packageInfo.senderGeocodeLon,
        'Package Cost': totalCost,
        'Handle With Care': handleWithCare
      };

      final packageSubcollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('orders');

      String newOrderId;

      if (orderId != null && orderId.trim().isNotEmpty) {
        // If orderId exists, use it as docId
        newOrderId = orderId;
      } else {
        // If orderId is null, create a new document
        final documentReference = await packageSubcollectionRef.add(data);
        newOrderId = documentReference.id;
      }

      final hashedOrderId = generateOrderIdHash(newOrderId);

      final documentReference = packageSubcollectionRef.doc(newOrderId);

      await documentReference.set({
        ...data,
        'hashedOrderId': hashedOrderId,
      });

      print("inside firestore $newOrderId");
    } catch (e) {
      print('Error adding data to package subcollection: $e');
    }
  }

//   //Add Incomplete Order and package info to firebase
//  Future<void> addIncompleteDataToFirestore({
//   required PackageInfo packageInfo,
//   required TextEditingController textEditingController,
//   required String dropdownValue1,
//   required TextEditingController textEditingControllerDescription,
//   required String dropdownValue2,
//   required String dropdownValue3,
//   required bool isChecked,
//   String? orderId, // Add orderId as a parameter
//   int? reason,
// }) async {
//   try {
//     print("excuse me");
//     print(orderId);
//     final user = await _authService.getCurrentUser();
//     print(user?.uid);
//     final data = {
//       'Sender Name': packageInfo.senderName,
//       'Sender Phone': packageInfo.senderPhone,
//       'Sender Address': packageInfo.senderAddress,
//       'Sender Room': packageInfo.senderCity,
//       'Sender Building': packageInfo.senderState,
//       'Sender Pincode': packageInfo.senderPincode,
//       'Instruction for Traveler': packageInfo.senderInstruction,
//       'Receiver Name': packageInfo.receiverName,
//       'Receiver Phone': packageInfo.receiverPhone,
//       'Receiver Address': packageInfo.receiverAddress,
//       'Receiver Room': packageInfo.receiverCity,
//       'Receiver Building': packageInfo.receiverState,
//       'Receiver Pincode': packageInfo.receiverPincode,
//       'Package Value': textEditingController.text,
//       'Package Category': dropdownValue1,
//       'Package Description': textEditingControllerDescription.text,
//       'Package Weight': dropdownValue2,
//       'Package Size': dropdownValue3,
//       'acceptedTerms': isChecked,
//       'userid': user?.uid,
//       'Status': 'Incomplete',
//       'Timestamp': FieldValue.serverTimestamp(),
//       'Sender Geocode Lat': packageInfo.senderGeocodeLat,
//       'Sender Geocode Lon': packageInfo.senderGeocodeLon,
//       'Reason': reason

//     };

//     final packageSubcollectionRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(user?.uid)
//         .collection('Incomplete Orders');
//     print(packageSubcollectionRef);

//     if (orderId != null && orderId.trim().isNotEmpty) {

//       print("in orderid");
//         print(orderId);
//       // If orderId exists, update the existing document
//       await packageSubcollectionRef.doc(orderId).update(data);
//     } else {
//       print("In else of incomplete");
//       // If orderId is null, create a new document
//       final documentReference = await packageSubcollectionRef.add(data);

//       final orderId = documentReference.id;

//       final hashedOrderId = generateOrderIdHash(orderId);

//       await documentReference.update({'hashedOrderId': hashedOrderId});
//       print("inside firestore $orderId");
//     }
//   } catch (e) {
//     print('Error adding data to package subcollection: $e');
//   }
// }

  Future<void> addIncompleteDataWithStatus({
    required PackageInfo packageInfo,
    required TextEditingController textEditingController,
    required String dropdownValue1,
    required TextEditingController textEditingControllerDescription,
    required String dropdownValue2,
    required String dropdownValue3,
    required bool isChecked,
    String? orderId,
    required String status,
    String? reason,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      final data = {
        'Sender Name': packageInfo.senderName,
        'Sender Phone': packageInfo.senderPhone,
        'Sender Address': packageInfo.senderAddress,
        'Sender Room': packageInfo.senderCity,
        'Sender Building': packageInfo.senderState,
        'Sender Pincode': packageInfo.senderPincode,
        'Instruction for Traveler': packageInfo.senderInstruction,
        'Receiver Name': packageInfo.receiverName,
        'Receiver Phone': packageInfo.receiverPhone,
        'Receiver Address': packageInfo.receiverAddress,
        'Receiver Room': packageInfo.receiverCity,
        'Receiver Building': packageInfo.receiverState,
        'Receiver Pincode': packageInfo.receiverPincode,
        'Package Value': textEditingController.text,
        'Package Category': dropdownValue1,
        'Package Description': textEditingControllerDescription.text,
        'Package Weight': dropdownValue2,
        'Package Size': dropdownValue3,
        'acceptedTerms': isChecked,
        'userid': user?.uid,
        'Status': status, // Use the provided status
        'Timestamp': FieldValue.serverTimestamp(),
        'Sender Geocode Lat': packageInfo.senderGeocodeLat,
        'Sender Geocode Lon': packageInfo.senderGeocodeLon,
        'Reason': reason
      };

      final incompleteOrdersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Incomplete Orders');

      if (orderId != null && orderId.trim().isNotEmpty) {
        // If orderId exists, update the existing document
        await incompleteOrdersRef.doc(orderId).update(data);
      } else {
        // If orderId is null, create a new document
        final documentReference = await incompleteOrdersRef.add(data);

        final newOrderId = documentReference.id;
        final hashedOrderId = generateOrderIdHash(newOrderId);

        await documentReference.update({'hashedOrderId': hashedOrderId});
        print("inside firestore $newOrderId");
      }
    } catch (e) {
      print('Error adding data to Incomplete Orders collection: $e');
    }
  }

  Future<void> updateStatusInIncompleteOrders(String? orderId) async {
    try {
      final user = await _authService.getCurrentUser();
      final incompleteOrdersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Incomplete Orders');

      final incompleteOrderDoc = await incompleteOrdersRef.doc(orderId).get();

      if (incompleteOrderDoc.exists) {
        await incompleteOrdersRef.doc(orderId).update({'Status': 'FULL'});
        print('Status updated to FULL for orderId: $orderId');
      } else {
        print('Incomplete Order with orderId $orderId does not exist.');
      }
    } catch (e) {
      print('Error updating status in Incomplete Orders collection: $e');
    }
  }

  Future<Map<String, dynamic>?> getIncompleteDataToFirestore(
      String orderId) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        return null;
      }

      final userDocRef = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .collection("Incomplete Orders")
          .doc(orderId);

      final userData = await userDocRef.get();
      print(userData.data());

      if (userData.exists) {
        return userData.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      // Handle the exception
      print("Error getting incomplete order details: $e");
      print(stackTrace);
      rethrow;
    }
  }

  String generateOrderIdHash(String orderId) {
    final bytes = utf8.encode(orderId);
    final hash = md5.convert(bytes);
    final hashString = hash.toString().substring(0, 5);
    print(hashString);

    return hashString;
  }

  //travelers
  //get Available orders
  Future<Stream<QuerySnapshot>?> getOrdersStreamForAvailable() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collectionGroup("orders")
          .where("Status", isEqualTo: "Active")
          .orderBy("userid", descending: true)
          .where("userid", isNotEqualTo: currentUser.uid)
          .orderBy("Timestamp", descending: true)
          .snapshots();
    } else {
      return null; // Handle the case when currentUser is null
    }
  }

  //get Active orders
  Future<Stream<QuerySnapshot>?> getOrdersStreamForActive() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collectionGroup("orders")
          .where("travelerId", isEqualTo: currentUser.uid)
          .orderBy("userid", descending: true)
          .where("userid", isNotEqualTo: currentUser.uid)
          .orderBy("Timestamp", descending: true)
          .snapshots();
    } else {
      return null; // Handle the case when currentUser is null
    }
  }

//get Completed orders
  Future<Stream<QuerySnapshot>?> getOrdersStreamForComplete() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collectionGroup("orders")
          .where("Status", isEqualTo: "Completed")
          .orderBy("userid", descending: true)
          .where("userid", isNotEqualTo: currentUser.uid)
          .orderBy("Timestamp", descending: true)
          .snapshots();
    } else {
      return null; // Handle the case when currentUser is null
    }
  }

  Future<void> updateUserRoleSignout(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': -1,
      });
    } catch (e) {
      print("Error updating user role: $e");
      rethrow;
    }
  }

  Future<void> addUserToFirestore({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String location,
  }) async {
    try {
      final userMap = {
        "id": userId,
        "name": name,
        "email": email,
        "phone": phone,
        "location": location,
        "sender": false,
        "traveler": false,
        "role": -1
      };

      await _firestore.collection('users').doc(userId).set(userMap);
    } catch (error) {
      // Handle errors here
    }
  }

  Future<void> updateUserAsSender(User user) async {
    try {
      Map<String, dynamic> updatedData = {
        "sender": true,
        "role": 0, // Set to true to mark as a sender
      };

      await _firestore.collection("users").doc(user.uid).update(updatedData);
    } catch (e) {
      print("Error updating user as sender: $e");
      rethrow;
    }
  }

  Future<void> updateUserAsTraveler(User user) async {
    try {
      Map<String, dynamic> updatedData = {
        "traveler": true,
        "role": 1, // Set to false to mark as not a traveler
      };
      await _firestore.collection("users").doc(user.uid).update(updatedData);
      DocumentSnapshot userSnapshot =
          await _firestore.collection("users").doc(user.uid).get();

      if (userSnapshot.exists) {
        String email = userSnapshot.get("email");
        String name = userSnapshot.get("name");
        String phone = userSnapshot.get("phone");
        String location = userSnapshot.get("location");

        await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("travelers")
            .doc(user.uid)
            .set({
          "email": email,
          "name": name,
          "phone": phone,
          "location": location,
        });
      }
    } catch (e) {
      print("Error updating user as traveler: $e");
    }
  }

  Future<bool> acceptOrder(String? senderId, String? orderId) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      String? userId = currentUser?.uid;
      Map<String, dynamic> orderData = {
        'orderId': orderId,
        'senderId': senderId,
        'Timestamp': FieldValue.serverTimestamp(),
        'Status': 'Processing',
      };
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('travelers')
          .doc(userId)
          .collection('Accepted orders')
          .doc(orderId)
          .set(orderData);

      await _firestore
          .collection('users')
          .doc(senderId)
          .collection('orders')
          .doc(orderId)
          .update({'travelerId': userId, 'Status': 'Processing'});
      return true;
    } catch (error) {
      // Handle any errors here
      print('Error accepting order: $error');
      return false;
    }
  }

  // Function to get UserId
  Future<String?> getUserId() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      return (await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get())
          .data()?['id'];
    }
    return null; // Handle the case when senderId is not available
  }
}
