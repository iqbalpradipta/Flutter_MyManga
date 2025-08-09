import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasInternetAccess() async {
    try {
      final isConnected = await NetworkUtils.isConnected();
      if (!isConnected) {
        return false;
      }

      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none) && result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}