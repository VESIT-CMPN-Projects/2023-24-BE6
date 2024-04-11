import 'package:deliveryx/Users/Users_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
// import 'package:your_app_path/login_screen.dart'; // Replace with the correct path

void main() async {
  // Ensure that Firebase is initialized before running tests
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  testWidgets('Login Screen Widget Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: LoginScreen(),
    ));

    // Verify that the email and password TextFormFields are initially empty.
    expect(find.text(''),
        findsNWidgets(2)); // 2 TextFormFields: email and password

    // Tap the Login button and trigger the login process.
    await tester.tap(find.text('Login'));
    // await tester.pump();

    // // Verify that the error dialog appears because both email and password are empty.
    // expect(find.text('Enter your Login Credentials'), findsOneWidget);
    // expect(find.text('Please Enter your Email and Password'), findsOneWidget);

    // Enter valid email and invalid password.
    // await tester.enterText(
    //     find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    // await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '');

    // // Tap the Login button again.
    // await tester.tap(find.text('Login'));
    // await tester.pump();

    // // Verify that the error dialog appears because the password is empty.
    // expect(find.text('Enter your Login Credentials'), findsOneWidget);
    // expect(find.text('Please Enter your Password'), findsOneWidget);

    // TODO: Add more test scenarios based on your application flow.
  });
}
