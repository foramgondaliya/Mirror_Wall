import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/Provider/connectivity_Provider.dart';
import 'package:provider/provider.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? inAppWebViewController;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectivityProvider>(context, listen: false)
        .checkConnectivity();
    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          await inAppWebViewController?.reload();
        } else if (Platform.isIOS) {
          if (inAppWebViewController != null) {
            await inAppWebViewController!.loadUrl(
              urlRequest: URLRequest(
                url: await inAppWebViewController?.getUrl(),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Browser',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return <PopupMenuEntry>[
                PopupMenuItem(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.bookmark),
                      Text("All Bookmarks"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertBox();
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.screen_search_desktop_outlined),
                      Text("Search Engine"),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ConnectivityProvider>(
              builder: (context, connectivityProvider, _) {
                if (connectivityProvider.isOn) {
                  return InAppWebView(
                    pullToRefreshController: pullToRefreshController,
                    initialUrlRequest: URLRequest(
                      url: WebUri("https://google.com/"),
                    ),
                    onLoadStart: (controller, url) {
                      inAppWebViewController = controller;
                    },
                    onLoadStop: (controller, url) async {
                      await pullToRefreshController!.endRefreshing();
                    },
                  );
                } else {
                  return Center(
                    child: Text("No Internet"),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search or type web address',
                    ),
                    onSubmitted: (value) async {
                      String url = value;
                      if (!url.startsWith('http')) {
                        url = 'https://www.google.com/search?q=' + url;
                      }
                      if (inAppWebViewController != null) {
                        await inAppWebViewController!.loadUrl(
                          urlRequest: URLRequest(
                            url: WebUri(url),
                          ),
                        );
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 30,
                  ),
                  onPressed: () async {
                    String url = searchController.text;
                    if (!url.startsWith('http')) {
                      url = 'https://www.google.com/search?q=' + url;
                    }
                    if (inAppWebViewController != null) {
                      await inAppWebViewController!.loadUrl(
                        urlRequest: URLRequest(
                          url: WebUri(url),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.home,
                        size: 30,
                      ),
                      onPressed: () async {
                        if (inAppWebViewController != null) {
                          await inAppWebViewController!.loadUrl(
                            urlRequest: URLRequest(
                              url: WebUri("https://google.com/"),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.bookmark_border,
                        size: 30,
                      ),
                      onPressed: () async {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 30,
                      ),
                      onPressed: () async {
                        if (inAppWebViewController != null) {
                          if (await inAppWebViewController!.canGoBack()) {
                            await inAppWebViewController!.goBack();
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 30,
                      ),
                      onPressed: () async {
                        if (inAppWebViewController != null) {
                          await inAppWebViewController!.reload();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 30,
                      ),
                      onPressed: () async {
                        if (inAppWebViewController != null) {
                          if (await inAppWebViewController!.canGoForward()) {
                            await inAppWebViewController!.goForward();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlertBox extends StatelessWidget {
  const AlertBox({Key? key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Search Engine",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      content: Container(
        height: 400,
        width: 300,
      ),
    );
  }
}
