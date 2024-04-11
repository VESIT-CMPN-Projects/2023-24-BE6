import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:deliveryx/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockAuthService extends Mock implements AuthService {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
   Future<MockDocumentSnapshot> Function(String collectionPath, String documentId) getMockDoc(
      {required String collectionPath, required String documentId});

  // Mock getSenderId behavior
  Future<String?> getSenderId({required AuthService authService}) async {
    // Delegate user fetching to the provided AuthService mock
    final mockUser = await authService.getCurrentUser();

    if (mockUser != null) {
      // Use the getMockDoc function (defined below) to simulate document retrieval
      final mockSnapshot = getMockDoc(collectionPath: 'users', documentId: mockUser.uid);
      return mockSnapshot.exists ? mockSnapshot.data?['id'] : null ;
    }

    return null;
  }
}

void main() {
  // Create mocks
  final mockAuthService = MockAuthService();
  final mockFirestore = MockFirebaseFirestore();

  group('getSenderId', () {
    test('returns senderId when user exists and document has data', () async {
      // Mock user with uid
      final mockUser = MockUser(uid: "test_user_id");

      // Mock document snapshot with data
      const expectedSenderId = "sender_123";
      final mockSnapshot = MockDocumentSnapshot(true, {"id": expectedSenderId});

      // Mock AuthService to return user for any uid
      when(mockAuthService.getCurrentUser())
          .thenAnswer((_) => Future.value(mockUser));
      when(mockFirestore
              .collection('users')
              .doc(any)
              .get()) // Capture any uid argument
          .thenAnswer((_) => Future.value(mockSnapshot as FutureOr<DocumentSnapshot<Map<String, dynamic>>>?));

      // Call the function with mocks
      final senderId = await getSenderId(
          authService: mockAuthService, firestore: mockFirestore);

      // Verify results
      expect(senderId, expectedSenderId);
      verify(mockAuthService.getCurrentUser()).called(1);
      verify(mockFirestore.collection('users').doc(mockUser.uid).get())
          .called(1); // Verify specific uid
    });
  });
}

// Replace with your actual user model definition if applicable
class MockUser extends Mock implements User {
  @override
  final String uid;
  MockUser({required this.uid});
}

// Mock document snapshot (assuming you don't have a DocumentSnapshot class)
class MockDocumentSnapshot {
  final bool exists;
  final Map<String, dynamic>? data;

  MockDocumentSnapshot(this.exists, this.data);
}
