import 'package:flutter/material.dart';

class SearchEngineProvider with ChangeNotifier {
  String _selectedSearchEngine = 'Google';

  String get selectedSearchEngine => _selectedSearchEngine;

  void setSearchEngine(String searchEngine) {
    _selectedSearchEngine = searchEngine;
    notifyListeners();
  }
}
