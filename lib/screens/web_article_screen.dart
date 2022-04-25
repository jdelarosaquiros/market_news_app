import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebArticleScreen extends StatefulWidget {
  final String articleUrl;

  const WebArticleScreen({
    Key? key,
    required this.articleUrl,
  }) : super(key: key);

  @override
  WebArticleScreenState createState() => WebArticleScreenState();
}

class WebArticleScreenState extends State<WebArticleScreen> {
  int position = 1;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: IndexedStack(
        index: position,
        children: [
          WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: widget.articleUrl,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            onPageStarted: (progress) {
              setState(() {
                position = 0;
              });
            },
          ),
          const Center(child: CircularProgressIndicator())

        ],
      ),
    );
  }
}
