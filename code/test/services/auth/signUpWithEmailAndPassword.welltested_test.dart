import 'signUpWithEmailAndPassword.welltested_test.mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deliveryx/services/auth.dart';

import 'auth_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    authService = AuthService();
    authService._auth = mockFirebaseAuth;
  });

  test('signUpWithEmailAndPassword with valid credentials', () async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'test@test.com', password: 'password'))
        .thenAnswer((_) => Future.value(mockUserCredential));

    when(mockUserCredential.user).thenReturn(mockUser);

    final result = await authService.signUpWithEmailAndPassword('test@test.com', 'password');

    expect(result, equals(mockUser));
    verify(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'test@test.com', password: 'password'))
        .called(1);
  });

  test('signUpWithEmailAndPassword with invalid credentials', () async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'test@test.com', password: 'password'))
        .thenThrow(FirebaseAuthException(code: 'user-not-found'));

    final result = await authService.signUpWithEmailAndPassword('test@test.com', 'password');

    expect(result, isNull);
    verify(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'test@test.com', password: 'password'))
        .called(1);
  });
}