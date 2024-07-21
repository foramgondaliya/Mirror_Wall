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
                      },
                      onLoadStop: (controller, url) async {
                        await pullToRefreshController!.endRefreshing();
                        checkIfBookmarked();
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
                            if (!url.startsWith('http')) {
                              switch (
                                  searchEngineProvider.selectedSearchEngine) {
                                case 'Yahoo':
                                  url = 'https://search.yahoo.com/search?p=' +
                                      url;
                                  break;
                                case 'Bing':
                                  url = 'https://www.bing.com/search?q=' + url;
                                  break;
                                case 'Duck Duck Go':
                                  url = 'https://duckduckgo.com/?q=' + url;
                                  break;
                                case 'Google':
                                default:
                                  url =
                                      'https://www.google.com/search?q=' + url;
                                  break;
                              }
                            }
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
      ),
    );
  }
}

// class AlertBox extends StatelessWidget {
//   const AlertBox({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SearchEngineProvider>(
//       builder: (context, searchEngineProvider, child) {
//         return AlertDialog(
//           title: const Text('Search Engine'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               RadioListTile<String>(
//                 title: Text('Google'),
//                 value: "https://www.google.com",
//                 groupValue: searchEngineProvider.selectedSearchEngine,
//                 onChanged: (val) {
//                   searchEngineProvider.setSearchEngine(val!);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               RadioListTile<String>(
//                 title: Text('Yahoo'),
//                 value: "https://www.yahoo.com",
//                 groupValue: searchEngineProvider.selectedSearchEngine,
//                 onChanged: (val) {
//                   searchEngineProvider.setSearchEngine(val!);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               RadioListTile<String>(
//                 title: Text('Bing'),
//                 value: "https://www.bing.com",
//                 groupValue: searchEngineProvider.selectedSearchEngine,
//                 onChanged: (val) {
//                   searchEngineProvider.setSearchEngine(val!);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               RadioListTile<String>(
//                 title: Text('Duck Duck Go'),
//                 value: "https://www.duckduckgo.com",
//                 groupValue: searchEngineProvider.selectedSearchEngine,
//                 onChanged: (val) {
//                   searchEngineProvider.setSearchEngine(val!);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
