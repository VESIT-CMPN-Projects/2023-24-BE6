import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deliveryx/Users/Users_screen/contactpage.dart';

void main() {
  testWidgets('Privacy Policy Page Widget Tests', (tester) async {
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(home: ContactUsPage()));

      expect(find.text('Contact Us'), findsOneWidget);

      expect(find.text('Contact Information'), findsOneWidget);

      expect(find.text('Mediaaaaaa'), findsOneWidget);
    };
  });
}
