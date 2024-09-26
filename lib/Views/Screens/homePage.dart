import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/Modal/bookmark.dart';
import 'package:mirror_wall/Provider/connectivity_Provider.dart';
import 'package:mirror_wall/Provider/SearchEngineProvider.dart';
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
  bool isBookmarked = false;
  bool isTapped = false;
  bool canGoBack = false;
  bool canGoForward = false;

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

  void updateButton() async {
    if (inAppWebViewController != null) {
      bool back = await inAppWebViewController!.canGoBack();
      bool forward = await inAppWebViewController!.canGoForward();
      setState(() {
        canGoBack = back;
        canGoForward = forward;
      });
    }
  }

  void checkIfBookmarked() async {
    WebUri? currentUrl = await inAppWebViewController?.getUrl();
    if (currentUrl != null && Bookmark.urls.contains(currentUrl.toString())) {
      setState(() {
        isBookmarked = true;
      });
    } else {
      setState(() {
        isBookmarked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchEngineProvider(),
      child: Scaffold(
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
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('bookmark');
                },
                icon: Icon(Icons.bookmark)),
            PopupMenuButton(
              onSelected: (val) {
                inAppWebViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: WebUri("$val"),
                  ),
                );
              },
              itemBuilder: (context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Text("Google"),
                    value: "https://www.google.com",
                  ),
                  PopupMenuItem(
                    child: Text("Yahoo"),
                    value: "https://www.yahoo.com",
                  ),
                  PopupMenuItem(
                    child: Text("Bing"),
                    value: "https://www.bing.com",
                  ),
                  PopupMenuItem(
                    child: Text("DuckDuckGo"),
                    value: "https://www.duckduckgo.com",
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
                        checkIfBookmarked();
                        updateButton();
                      },
                      onLoadStop: (controller, url) async {
                        await pullToRefreshController!.endRefreshing();
                        checkIfBookmarked();
                        updateButton();
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
                    child: Consumer<SearchEngineProvider>(
                      builder: (context, searchEngineProvider, child) {
                        return TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Search or type web address',
                          ),
                          onSubmitted: (value) async {
                            String url = value;
                            if (inAppWebViewController != null) {
                              await inAppWebViewController!.loadUrl(
                                urlRequest: URLRequest(
                                  url: WebUri(url),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
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
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 30,
                        ),
                        onPressed: () async {
                          WebUri? currentUrl =
                              await inAppWebViewController!.getUrl();
                          if (currentUrl != null) {
                            if (isBookmarked) {
                              Bookmark.urls.remove(currentUrl.toString());
                            } else {
                              Bookmark.urls.add(currentUrl.toString());
                            }
                            Bookmark.convertUrl();
                            setState(() {
                              isBookmarked = !isBookmarked;
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: canGoBack
                            ? () async {
                                if (inAppWebViewController != null) {
                                  if (await inAppWebViewController!
                                      .canGoBack()) {
                                    await inAppWebViewController!.goBack();
                                    updateButton();
                                  }
                                }
                              }
                            : null,
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
                        icon: Icon(Icons.arrow_forward),
                        onPressed: canGoForward
                            ? () async {
                                if (inAppWebViewController != null) {
                                  if (await inAppWebViewController!
                                      .canGoForward()) {
                                    await inAppWebViewController!.goForward();
                                    updateButton();
                                  }
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
