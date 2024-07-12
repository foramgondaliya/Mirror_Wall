import 'package:flutter/cupertino.dart';
import 'package:mirror_wall/Modal/bookmark.dart';

class DeleteProvider extends ChangeNotifier {
  void deleteAllData() {
    Bookmark.urls.clear();
    Bookmark.urlData.clear();
    notifyListeners();
  }

  void delete(int index) {
    Bookmark.urls.remove(Bookmark.urlData[index]);
    Bookmark.urlData.removeAt(index);
    notifyListeners();
  }
}
