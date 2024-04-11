import 'sendOTP.welltested_test.mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deliveryx/services/auth.dart';

import 'auth_test.mocks.dart';

@GenerateMocks([FirebaseAuth, PhoneAuthCredential])
void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    authService = AuthService();
    mockFirebaseAuth = MockFirebaseAuth();
    authService._auth = mockFirebaseAuth;
  });

  test('sendOTP with valid phone number', () async {
    when(mockFirebaseAuth.verifyPhoneNumber(
      phoneNumber: '+91 1234 567 890',
      verificationCompleted: anyNamed('verificationCompleted'),
      verificationFailed: anyNamed('verificationFailed'),
      codeSent: anyNamed('codeSent'),
      codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      timeout: anyNamed('timeout'),
    )).thenAnswer((_) => Future.value(MockPhoneAuthCredential()));

    final result = await authService.sendOTP('1234567890');

    expect(result[0], isNotNull);
    expect(result[1], isNotNull);
    verify(mockFirebaseAuth.verifyPhoneNumber(
      phoneNumber: '+91 1234 567 890',
      verificationCompleted: anyNamed('verificationCompleted'),
      verificationFailed: anyNamed('verificationFailed'),
      codeSent: anyNamed('codeSent'),
      codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      timeout: anyNamed('timeout'),
    )).called(1);
  });

  test('sendOTP with invalid phone number', () async {
    when(mockFirebaseAuth.verifyPhoneNumber(
      phoneNumber: '+91 1234 567 890',
      verificationCompleted: anyNamed('verificationCompleted'),
      verificationFailed: anyNamed('verificationFailed'),
      codeSent: anyNamed('codeSent'),
      codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      timeout: anyNamed('timeout'),
    )).thenThrow(Exception('Invalid phone number'));

    final result = await authService.sendOTP('1234567890');

    expect(result[0], isNull);
    expect(result[1], isNull);
    verify(mockFirebaseAuth.verifyPhoneNumber(
      phoneNumber: '+91 1234 567 890',
      verificationCompleted: anyNamed('verificationCompleted'),
      verificationFailed: anyNamed('verificationFailed'),
      codeSent: anyNamed('codeSent'),
      codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      timeout: anyNamed('timeout'),
    )).called(1);
  });
}