import 'package:flutter/material.dart';

class ScannerViewModel extends ChangeNotifier {
  String? _scannedId;
  String? get scannedId => _scannedId;

  void onScan(String id) {
    if (_scannedId != id) {
      _scannedId = id;
      notifyListeners();
    }
  }

  void reset() {
    _scannedId = null;
    notifyListeners();
  }
}
