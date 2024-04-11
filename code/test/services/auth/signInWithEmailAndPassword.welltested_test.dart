import 'package:flutter/material.dart';

import 'signInWithEmailAndPassword.welltested_test.mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deliveryx/services/auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

@GenerateMocks([FirebaseAuth, UserCredential, User, EmailAuthProvider])
void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  // Ensure Firebase is initialized before running any tests
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    authService = AuthService();

    when(mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((_) => Future.value(mockUserCredential));
    when(mockUserCredential.user).thenReturn(mockUser);
  });

  group('signInWithEmailAndPassword', () {
    const email = 'test@example.com';
    const password = 'testpassword';

    test('should return User when signInWithEmailAndPassword is successful',
        () async {
      final result =
          await authService.signInWithEmailAndPassword(email, password);

      expect(result, equals(mockUser));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .called(1);
    });

    test(
        'should return null when signInWithEmailAndPassword throws an exception',
        () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .thenThrow(Exception());

      final result =
          await authService.signInWithEmailAndPassword(email, password);

      expect(result, null);
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .called(1);
    });
  });
}
