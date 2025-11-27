import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'webview_dialog.dart';

/// Implementación Web usando iframe
class WebViewDialogPlatform extends StatefulWidget {
  final String url;
  final String title;

  const WebViewDialogPlatform({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewDialogPlatform> createState() => _WebViewDialogPlatformState();
}

class _WebViewDialogPlatformState extends State<WebViewDialogPlatform> {
  late String _viewId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewId = 'webview-${DateTime.now().millisecondsSinceEpoch}';
    _registerIFrame();
  }

  void _registerIFrame() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; xr-spatial-tracking'
          ..allowFullscreen = true;

        iframe.onLoad.listen((_) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        });

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    final dialogWidth = screenSize.width * 0.9;
    final dialogHeight = screenSize.height * 0.85;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2029) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF691C32).withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 60,
                offset: const Offset(0, 30),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                WebViewDialogHeader(
                  title: widget.title,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      HtmlElementView(viewType: _viewId),
                      if (_isLoading) WebViewLoading(isDark: isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
