import "package:flutter/foundation.dart";

class CheckConnectionStatus with ChangeNotifier {
  bool connected = true;

  bool notifyDisconnect() {
    connected = false;
    notifyListeners();
  }

  bool notifyConnect() {
    connected = true;
    notifyListeners();
  }
}
