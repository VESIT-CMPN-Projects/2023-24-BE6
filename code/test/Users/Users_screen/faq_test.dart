import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deliveryx/Users/Users_screen/faq.dart';

void main() {
  testWidgets('FAQ Page Widget Tests', (tester) async {
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(home: FAQPage()));

      expect(find.text('FAQ'), findsOneWidget);

      expect(find.text('Q. How can I track my package?'), findsOneWidget);
    };
  });
}
