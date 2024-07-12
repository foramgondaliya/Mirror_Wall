import 'package:flutter/material.dart';
import 'package:mirror_wall/Provider/connectivity_Provider.dart';
import 'package:mirror_wall/Views/Screens/homePage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ConnectivityProvider(),
      )
    ],
    child: MaterialApp(debugShowCheckedModeBanner: false, routes: {
      '/': (context) => homePage(),
    }),
  ));
}
