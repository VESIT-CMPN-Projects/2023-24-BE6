import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'getCurrentUser.welltested_test.mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deliveryx/services/auth.dart';

@GenerateMocks([FirebaseAuth, User])
void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
setUp(() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  mockFirebaseAuth = MockFirebaseAuth();
  mockUser = MockUser();
  authService = AuthService();
});
  group('getCurrentUser', () {
    test('should return current user when called', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final result = await authService.getCurrentUser();

      expect(result, equals(mockUser));
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('should return null when there is no current user', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await authService.getCurrentUser();

      expect(result, isNull);
      verify(mockFirebaseAuth.currentUser).called(1);
    });
  });
}
