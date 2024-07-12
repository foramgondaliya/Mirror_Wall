class Bookmark {
  static Set<String> urls = {};
  static List<String> urlData = [];

  static void convertUrl() {
    urlData = urls.toList();
  }
}
