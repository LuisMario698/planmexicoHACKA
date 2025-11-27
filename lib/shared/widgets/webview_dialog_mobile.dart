import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_dialog.dart';

/// Implementación Mobile usando webview_flutter
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
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1E2029))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // En móvil usamos casi toda la pantalla
    final dialogWidth = screenSize.width;
    final dialogHeight = screenSize.height - padding.top - padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          margin: EdgeInsets.only(top: padding.top),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2029) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF691C32).withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Column(
              children: [
                // Handle para arrastrar (estilo bottom sheet)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  color: const Color(0xFF691C32),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                
                // Header
                WebViewDialogHeader(
                  title: widget.title,
                  onClose: () => Navigator.of(context).pop(),
                ),
                
                // Barra de progreso
                if (_isLoading)
                  LinearProgressIndicator(
                    value: _loadingProgress / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF691C32)),
                    minHeight: 3,
                  ),
                
                // WebView
                Expanded(
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (_isLoading && _loadingProgress < 30)
                        WebViewLoading(isDark: isDark),
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
