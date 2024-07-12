import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool isOn = true;

  Connectivity connectivity = Connectivity();
  Stream<List<ConnectivityResult>>? connection;

  void checkConnectivity() {
    connectivity.onConnectivityChanged.listen(
      (connectivityList) {
        if (connectivityList.contains(ConnectivityResult.none)) {
          isOn = false;
        } else {
          isOn = true;
        }
        notifyListeners();
      },
    );
  }
}
