import 'package:deliveryx/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// import 'package:path/to/auth_service.dart'; // Update the path accordingly

// class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
          Invocation.method(#signInWithEmailAndPassword, [email, password]),
          returnValue: Future.value(MockUserCredential()));
}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('AuthService Unit Test', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    final MockUserCredential mockUserCredential = MockUserCredential();
    final mockUser = MockUser();

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(auth: mockFirebaseAuth);
      when(mockUserCredential.user).thenReturn(mockUser);
    });

    test('getCurrentUser returns current user', () async {
      final mockUser = MockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final result = await authService.getCurrentUser();

      expect(result, equals(mockUser));
    });

    test('signUpWithEmailAndPassword returns user on success', () async {
      const email = 's1@gmail.com';
      const password = 's1@gmail.com';

      final MockUserCredential mockUserCredential = MockUserCredential();
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      )).thenAnswer((_) => Future.value(mockUserCredential));

      final result =
          await authService.signUpWithEmailAndPassword(email, password);

      expect(result, equals(mockUserCredential.user));
    });

    test('signUpWithEmailAndPassword returns null on failure', () async {
      const email = 'test@example.com';
      const password = 'password123';

      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      )).thenThrow(Exception('Test error'));

      final result =
          await authService.signUpWithEmailAndPassword(email, password);

      expect(result, isNull);
    });

    // Add more tests for other methods as needed
  });
}
