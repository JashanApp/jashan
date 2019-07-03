import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebPageViewer extends StatelessWidget {
  String _url;

  WebPageViewer(this._url);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebviewScaffold(
        url: _url,
      ),
    );
  }
}
