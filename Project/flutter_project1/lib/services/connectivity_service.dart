import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static Future<bool> isOffline() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none;
  }
}
