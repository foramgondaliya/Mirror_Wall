import 'package:flutter/cupertino.dart';

class SearchEngineProvider extends ChangeNotifier {
  String selectedRadio = '';
  String strGoogle = "Google";
  String strYahoo = "Yahoo";
  String strBing = "Bing";
  String strDuckDuckGo = "DuckDuckGo";
  String strMainURL = "https://www.google.com/";
  String strSearchURL = "https://www.google.com/search?q";

  void handleRadioValueChange(String value, BuildContext context) {
    selectedRadio = value;
    if (value == strGoogle) {
      strMainURL = "https://www.google.com/";
      strSearchURL = "https://www.google.com/search?q";
    } else if (value == strYahoo) {
      strMainURL = "https://in.search.yahoo.com";
      strSearchURL = "https://in.search.yahoo.com/search?q";
    } else if (value == strBing) {
      strMainURL = "https://www.bing.com";
      strSearchURL = "https://www.bing.com/search?q";
    } else if (value == strDuckDuckGo) {
      strMainURL = "https://duckduckgo.com";
      strSearchURL = "https://duckduckgo.com/search?q";
    }
    notifyListeners();

    Navigator.of(context).pop();
  }
}
