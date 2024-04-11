import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';

class AuthService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

//get current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final authResult = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return authResult.user;
    } catch (error) {
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final authResult = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final emailPasswordCredential =
          EmailAuthProvider.credential(email: email, password: password);

      return authResult.user;
    } catch (error) {
      return null;
    }
  }

//signout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // Add other authentication-related methods here
  // Future<bool> signOut() async {
  //   try {
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser != null) {
  //       // Update the user's role to -1 in the user collection
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(currentUser.uid)
  //           .update({
  //         'role': -1,
  //       });
  //     }
  //     // Sign out the user
  //     await FirebaseAuth.instance.signOut();

  //     return true;
  //   } catch (e) {
  //     print("Error signing out: $e");
  //     return false;
  //   }
  // }

  Future<List> sendOTP(phoneNumber) async {
    try {
      // String phoneNumber = _phoneNumberController.text;
      // Formatting the phonenumber in the required format
      String first = phoneNumber.substring(0, 4);
      String second = phoneNumber.substring(4, 7);
      String third = phoneNumber.substring(7, 10);
      String selectedCountryCode = '+91';
      String vId = "";
      PhoneAuthCredential? cId;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "$selectedCountryCode $first $second $third",
        verificationCompleted: (credential) {
          cId = credential;
          // _PhoneNumberInputSectionState.credential = credential;
          setState(() {});
        },
        verificationFailed: (error) {
          print(error);
        },
        codeSent: (verificationId, forceResendingToken) {
          vId = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (verificationId) {
          vId = verificationId;
          setState(() {});
          // print('Auto retrieval timeout');
        },
        timeout: const Duration(seconds: 30),
      );
      //  await Future.delayed(Duration(seconds: 1));
      return [vId, cId];
    } catch (e) {
      print(e);
      return [null, null];
    }
  }

  // Future<User?> verifyOTP(AuthCredential phoneCredential) async {
  //   final userCredential =
  //       await FirebaseAuth.instance.signInWithCredential(phoneCredential);

  //   return userCredential.user;
  // }

  Future<User?> verifyOTP(PhoneAuthCredential phoneCredential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneCredential);

      return userCredential.user;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }

  void setState(Null Function() param0) {}
}
