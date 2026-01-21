import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constant/constant.dart';

class WebViewScreen extends StatefulWidget {
  final url;
  WebViewScreen({this.url});
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  bool _isLoadingPage = true;

  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Color.fromARGB(0, 255, 255, 255))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: ((String url) {
            setState(() {
              _isLoadingPage = false;
            });
          }),
          onPageFinished: ((String url) {
            setState(() {
              _isLoadingPage = false;
            });
          }),
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: accentColor,
        leading: IconButton(
          icon: new Icon(
              // FlutterIcons.md_close_ion,
              Iconsax.close_circle,
              color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Berita", style: TextStyle(fontSize: 16)),
        actions: <Widget>[webViewNavigation(_controller.future)],
      ),
      body: Stack(
        children: [
          Builder(builder: (BuildContext context) {
            return WebViewWidget(
              controller: controller,
            );
          }),
          _isLoadingPage ? LinearProgressIndicator() : Container(),
        ],
      ),
    );
  }

  Widget webViewNavigation(_webViewControllerFuture) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady = snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data!;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(
                  // FlutterIcons.ios_arrow_back_ion
                  Iconsax.arrow_left),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        await controller.goBack();
                      }
                    },
            ),
            IconButton(
              icon: const Icon(
                  // FlutterIcons.ios_arrow_forward_ion
                  Iconsax.arrow_right),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        await controller.goForward();
                      }
                    },
            ),
            IconButton(
              icon: const Icon(
                  // FlutterIcons.ios_refresh_ion
                  Iconsax.refresh),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller.reload();
                      setState(() {
                        _isLoadingPage = true;
                      });
                    },
            ),
          ],
        );
      },
    );
  }
}
