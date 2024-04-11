import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driver/flutter_driver.dart' as driver_finder;
import 'dart:ui' as ui;

void main() {
  FlutterDriver? driver;

  // Connect to the Flutter driver before running any tests.
  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  // Close the connection to the driver after the tests have completed.
  tearDownAll(() async {
    // if (driver != null) {
    driver?.close();
    // }
  });
  test(
      'Sign Up button navigates to RegisterScreen',
      (driver) async {
        await driver.tap(driver_finder.find.byValueKey('otpnav'));
        expect(await driver.getCurrentRoute(), '/register');
      } as Function());
}
