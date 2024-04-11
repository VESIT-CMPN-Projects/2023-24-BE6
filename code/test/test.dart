import 'package:deliveryx/Users/Users_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:your_project/screens/login/login_screen.dart';
import 'package:mockito/mockito.dart';
// import 'package:your_project/screens/login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  setUpAll(() async {
    // Mock Firebase initialization
    TestWidgetsFlutterBinding.ensureInitialized();
    final MockFirebaseApp mockFirebaseApp = MockFirebaseApp();
  });
  testWidgets('Login screen UI test', (WidgetTester tester) async {
    when(Firebase.initializeApp()).thenAnswer((_) async => MockFirebaseApp());
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Verify that the initial UI is as expected.
    expect(find.text('Cheaper and faster delivery'), findsOneWidget);
    expect(find.text('Get great experience with DeliveryX :)'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.byType(ElevatedButton).first, findsOneWidget);
    expect(find.byType(ElevatedButton).last, findsOneWidget);
  });

  // Add more test cases as needed...
}
