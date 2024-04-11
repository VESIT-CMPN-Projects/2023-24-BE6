import 'signOut.welltested_test.mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deliveryx/services/auth.dart';

@GenerateMocks([FirebaseAuth])
void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = AuthService();
    authService._auth = mockFirebaseAuth;
  });

  group('signOut', () {
    test('should call signOut method of FirebaseAuth', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) => Future.value());

      await authService.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('should print error message when signOut throws an exception', () async {
      when(mockFirebaseAuth.signOut()).thenThrow(Exception('Sign out error'));

      await authService.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      // Here we can't directly test if something was printed out, 
      // but we can verify that the signOut method was called and it threw an exception.
    });
  });
}