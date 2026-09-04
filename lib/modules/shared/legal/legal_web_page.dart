import 'package:flutter/material.dart';
import 'package:we_chat_chat/core/widgets/figma_back_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebPage extends StatefulWidget {
  const LegalWebPage({
    super.key,
    required this.title,
    this.url,
    this.assetPath,
  });

  final String title;
  final String? url;
  final String? assetPath;

  @override
  State<LegalWebPage> createState() => _LegalWebPageState();
}

class _LegalWebPageState extends State<LegalWebPage> {
  late final WebViewController _controller;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) =>
              mounted ? setState(() => _loading = false) : null,
          onWebResourceError: (_) =>
              mounted ? setState(() => _loading = false) : null,
        ),
      );
    final asset = widget.assetPath;
    if (asset == null) {
      _controller.loadRequest(Uri.parse(widget.url!));
    } else {
      _controller.loadFlutterAsset(asset);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: FigmaBackButton(),
    ),
    body: Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading) const LinearProgressIndicator(),
      ],
    ),
  );
}
