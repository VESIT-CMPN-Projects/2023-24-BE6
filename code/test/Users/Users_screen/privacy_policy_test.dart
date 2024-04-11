import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deliveryx/Users/Users_screen/privacy_policy.dart';

void main() {
  testWidgets('Privacy Policy Page Widget Tests', (tester) async {
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(home: PrivacyPolicyPage()));

      // Verify that the AppBar title is rendered.
      expect(find.text('DeliveryX Privacy Policy'), findsOneWidget);

      // Verify that the "Contact Us" section title is rendered.
      expect(find.text('Privacy Policy for Senders'), findsOneWidget);

      // Verify that the "Thank you" text is rendered.
      expect(find.text('Privacy Policy for Travelers'), findsOneWidget);
    };
  });
}
