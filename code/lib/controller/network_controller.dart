import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:deliveryx/Users/Users_screen/network_issue_page.dart';

import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, navigate to the NoInternetPage
      Get.offAll(const NetworkIssuePage());
    } else {
      // Internet connection is available
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
