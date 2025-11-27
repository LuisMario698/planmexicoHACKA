import 'package:flutter/material.dart';

/// Stub para plataformas no soportadas
class WebViewDialogPlatform extends StatelessWidget {
  final String url;
  final String title;

  const WebViewDialogPlatform({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('WebView no disponible en esta plataforma'),
    );
  }
}
