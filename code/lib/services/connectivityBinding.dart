import 'package:flutter/material.dart';
import 'connectivityService.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MyAppBinding extends WidgetsFlutterBinding {
  static MyAppBinding? _instance;

  factory MyAppBinding.ensureInitialized() {
    return _instance ??= MyAppBinding._();
  }

  MyAppBinding._();

  @override
  void initInstances() {
    super.initInstances();
    // Initialize your global connectivity service
    ConnectivityService _connectivityService = ConnectivityService();

    // Listen for global connectivity changes
    _connectivityService.connectivityStream
        .listen((ConnectivityResult connectivityResult) {
      // Handle connectivity changes globally
      if (connectivityResult == ConnectivityResult.none) {
        print("Internet issue OOPSSS");
        // Navigate to a connectivity error page, or show a snackbar, etc.
        // Example: Navigator.of(myGlobalContext).push(MaterialPageRoute(builder: (context) => ConnectivityErrorScreen()));
        // Or show a snackbar: Scaffold.of(myGlobalContext).showSnackBar(SnackBar(content: Text('No internet connection')));
      }
    });
  }
}
