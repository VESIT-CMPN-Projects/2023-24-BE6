import 'verifyOTP.welltested_test.mocks.dart';
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

  test('verifyOTP returns a User on successful verification', () async {
    final phoneCredential = PhoneAuthCredential._credential('123456', '123456');

    when(mockFirebaseAuth.signInWithCredential(phoneCredential))
        .thenAnswer((_) => Future.value(mockUserCredential));
    when(mockUserCredential.user).thenReturn(mockUser);

    final result = await authService.verifyOTP(phoneCredential);

    expect(result, isNotNull);
    expect(result, isA<User>());
    verify(mockFirebaseAuth.signInWithCredential(phoneCredential)).called(1);
  });

  test('verifyOTP returns null on exception', () async {
    final phoneCredential = PhoneAuthCredential._credential('123456', '123456');

    when(mockFirebaseAuth.signInWithCredential(phoneCredential))
        .thenThrow(Exception('Authentication error'));

    final result = await authService.verifyOTP(phoneCredential);

    expect(result, isNull);
    verify(mockFirebaseAuth.signInWithCredential(phoneCredential)).called(1);
  });
}
