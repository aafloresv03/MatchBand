import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmbeddedMediaScreen extends StatefulWidget {
  final String title;
  final String url;

  const EmbeddedMediaScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<EmbeddedMediaScreen> createState() => _EmbeddedMediaScreenState();
}

class _EmbeddedMediaScreenState extends State<EmbeddedMediaScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}