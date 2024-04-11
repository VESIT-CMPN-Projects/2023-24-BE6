import 'package:deliveryx/Users/Users_screen/tandc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:deliveryx/pages/terms_and_conditions_page.dart';

void main() {
  testWidgets('Terms and Conditions Page Widgets Test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: TermsAndConditionsPage()));

    // Verify that the AppBar title is rendered.
    expect(find.text('Terms and Conditions'), findsOneWidget);

    // Verify that the "Contact Us" section title is rendered.
    expect(find.text('Contact Us:'), findsOneWidget);

    // Verify that the "Thank you" text is rendered.
    expect(
        find.text(
            'Thank you for choosing DelivryX for your package delivery needs!'),
        findsOneWidget);
  });
}
