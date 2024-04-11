// lib/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamController<ConnectivityResult> _connectivityController;

  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityController.stream;

  ConnectivityService() {
    _connectivityController = StreamController<ConnectivityResult>();
    _init();
  }

  void _init() {
    _connectivity.onConnectivityChanged.listen((result) {
      _connectivityController.add(result);
    });
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _connectivityController.close();
  }
}
