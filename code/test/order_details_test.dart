import 'package:deliveryx/Users/Users_screen/Sender/order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:deliveryx/Users/Users_screen/Sender/o';

void main() {
  testWidgets('OrderDetails widget test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: OrderDetails(),
    ));

    // Verify if the OrderDetails widget is rendered on the screen
    expect(find.byType(OrderDetails), findsOneWidget);

    // You can add more test cases based on your widget behavior

    // Example: Test if the "Enter Package Details" button is present
    expect(find.text('Enter Package Details'), findsOneWidget);

    // Example: Test if the sender's name field is initially empty
    expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        '');

    // Example: Trigger a tap on the button and verify the behavior
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Add more test cases as needed

    // Example: Verify if the state has been updated after tapping the button
    expect(find.text('Sender Info'), findsOneWidget);
  });
}
