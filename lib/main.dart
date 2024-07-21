import 'package:flutter/material.dart';
import 'package:mirror_wall/Provider/bookmark_Provider.dart';
import 'package:mirror_wall/Provider/connectivity_Provider.dart';
import 'package:mirror_wall/Provider/SearchEngineProvider.dart';
import 'package:mirror_wall/Views/Screens/bookmark.dart';
import 'package:mirror_wall/Views/Screens/homePage.dart';
import 'package:mirror_wall/Views/Screens/mark.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ConnectivityProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => DeleteProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => SearchEngineProvider(),
      )
    ],
    child: MaterialApp(debugShowCheckedModeBanner: false, routes: {
      '/': (context) => homePage(),
      'bookmark': (context) => BookmarkPage(),
      'mark': (context) => mark(),
    }),
  ));
}
