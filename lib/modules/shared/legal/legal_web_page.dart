import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  var _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) =>
              mounted ? setState(() => _loading = false) : null,
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                _hasLoadError = true;
              });
            }
          },
        ),
      );
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final asset = widget.assetPath;
    try {
      if (asset != null && asset.trim().isNotEmpty) {
        await _controller.loadFlutterAsset(asset);
        return;
      }
      final uri = Uri.tryParse(widget.url ?? '');
      if (uri == null || !uri.hasScheme || !uri.isScheme('https')) {
        throw ArgumentError.value(widget.url, 'url', 'Expected an HTTPS URL');
      }
      await _controller.loadRequest(uri);
    } on Object {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasLoadError = true;
        });
      }
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
        if (_hasLoadError)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'legal_document_unavailable'.tr,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          WebViewWidget(controller: _controller),
        if (_loading) const LinearProgressIndicator(),
      ],
    ),
  );
}
