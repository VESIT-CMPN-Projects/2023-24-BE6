import 'setState.welltested_test.mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deliveryx/services/auth.dart';

@GenerateMocks([FirebaseAuth, AuthService])
void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = AuthService();
  });

  group('setState', () {
    test('should call setState when invoked', () {
      var isCalled = false;
      void testFunction() {
        isCalled = true;
      }

      authService.setState(testFunction);

      expect(isCalled, true);
    });
  });
}