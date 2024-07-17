import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class mark extends StatefulWidget {
  const mark({super.key});

  @override
  State<mark> createState() => _markState();
}

class _markState extends State<mark> {
  @override
  Widget build(BuildContext context) {
    String data = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(data),
        ),
      ),
    );
  }
}
