import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Importación condicional para web vs mobile
import 'webview_dialog_stub.dart'
    if (dart.library.html) 'webview_dialog_web.dart'
    if (dart.library.io) 'webview_dialog_mobile.dart' as platform;

/// Diálogo flotante que muestra un WebView con contenido 3D
/// Funciona en Web (iframe) y Mobile (webview_flutter)
class WebViewDialog extends StatelessWidget {
  final String url;
  final String title;

  const WebViewDialog({super.key, required this.url, required this.title});

  /// Muestra el diálogo con el WebView
  static Future<void> show(
    BuildContext context, {
    required String url,
    required String title,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => WebViewDialog(url: url, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return platform.WebViewDialogPlatform(url: url, title: title);
  }
}

/// Header compartido para el diálogo
class WebViewDialogHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const WebViewDialogHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF691C32), Color(0xFF4A1525)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.view_in_ar_rounded,
              color: Colors.white,
              size: isMobile ? 20 : 24,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),

          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Experiencia interactiva 3D',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: isMobile ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),

          // Instrucciones (solo en desktop)
          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Arrastra para explorar',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Botón cerrar
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: isMobile ? 20 : 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de loading compartido
class WebViewLoading extends StatelessWidget {
  final bool isDark;

  const WebViewLoading({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF1E2029) : Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF691C32),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Cargando experiencia 3D...',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esto puede tomar unos segundos',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
