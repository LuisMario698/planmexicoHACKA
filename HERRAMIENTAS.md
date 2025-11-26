# 📚 Documentación de Herramientas - Plan México

Este documento describe las tecnologías, frameworks y librerías utilizadas en el desarrollo de la aplicación Plan México.

---

## 🎯 Framework Principal

### Flutter
**Versión:** 3.9.2+  
**Sitio oficial:** [flutter.dev](https://flutter.dev)

Flutter es el framework de UI de Google para crear aplicaciones nativas compiladas para móvil, web y escritorio desde una sola base de código.

**Características utilizadas:**
- Material Design 3
- Widgets responsivos
- Navegación declarativa
- Temas dinámicos (claro/oscuro)
- Hot Reload para desarrollo rápido

**Plataformas soportadas:**
- ✅ Android
- ✅ Web

---

### Dart
**Versión:** ^3.9.2  
**Sitio oficial:** [dart.dev](https://dart.dev)

Dart es el lenguaje de programación optimizado para crear interfaces de usuario rápidas en cualquier plataforma.

**Características utilizadas:**
- Null Safety
- Async/Await para operaciones asíncronas
- Generics y tipos fuertes
- Extension methods
- Pattern matching

---

## 📦 Dependencias de Producción

### dio
**Versión:** ^5.9.0  
**Pub.dev:** [pub.dev/packages/dio](https://pub.dev/packages/dio)

Cliente HTTP potente para Dart/Flutter con soporte para interceptores, transformadores y cancelación de peticiones.

**Uso en el proyecto:**
- Consumo de API de Google Sheets (CSV)
- Comunicación con backend de voz (STT/TTS)
- Manejo de errores de red

**Ejemplo:**
```dart
final dio = Dio();
final response = await dio.get('https://api.example.com/data');
```

---

### record
**Versión:** ^6.1.2  
**Pub.dev:** [pub.dev/packages/record](https://pub.dev/packages/record)

Plugin para grabar audio desde el micrófono del dispositivo.

**Uso en el proyecto:**
- Grabación de voz del usuario para el chatbot
- Captura de audio en formato compatible

**Características:**
- Soporte multiplataforma
- Control de calidad de audio
- Detección de permisos

---

### audioplayers
**Versión:** ^6.5.1  
**Pub.dev:** [pub.dev/packages/audioplayers](https://pub.dev/packages/audioplayers)

Plugin para reproducir audio en Flutter.

**Uso en el proyecto:**
- Reproducción de respuestas de voz del asistente (TTS)
- Playback de audio generado por el backend

**Características:**
- Reproducción desde bytes, URL o archivo local
- Control de volumen y velocidad
- Soporte para múltiples formatos de audio

---

### permission_handler
**Versión:** ^12.0.1  
**Pub.dev:** [pub.dev/packages/permission_handler](https://pub.dev/packages/permission_handler)

Plugin unificado para manejar permisos en Android e iOS.

**Uso en el proyecto:**
- Solicitud de permiso de micrófono
- Verificación de estado de permisos
- Manejo de permisos denegados

**Permisos utilizados:**
```dart
Permission.microphone.request();
Permission.microphone.status;
```

---

### path_provider
**Versión:** ^2.1.5  
**Pub.dev:** [pub.dev/packages/path_provider](https://pub.dev/packages/path_provider)

Plugin para obtener rutas del sistema de archivos específicas de cada plataforma.

**Uso en el proyecto:**
- Almacenamiento temporal de archivos de audio
- Caché de datos

**Directorios disponibles:**
- `getTemporaryDirectory()` - Archivos temporales
- `getApplicationDocumentsDirectory()` - Documentos de la app
- `getApplicationSupportDirectory()` - Datos de soporte

---

### speech_to_text
**Versión:** ^7.3.0  
**Pub.dev:** [pub.dev/packages/speech_to_text](https://pub.dev/packages/speech_to_text)

Plugin para reconocimiento de voz (Speech-to-Text) en tiempo real.

**Uso en el proyecto:**
- Transcripción de voz del usuario
- Entrada de texto por voz para el chatbot

**Características:**
- Reconocimiento en español (es-MX)
- Resultados parciales y finales
- Detección automática de fin de habla

---

### avatar_glow
**Versión:** ^3.0.0  
**Pub.dev:** [pub.dev/packages/avatar_glow](https://pub.dev/packages/avatar_glow)

Widget para crear efectos de brillo/ondas animadas alrededor de un widget.

**Uso en el proyecto:**
- Animación de ondas en el botón del micrófono
- Indicador visual de grabación activa

**Ejemplo:**
```dart
AvatarGlow(
  animate: isRecording,
  glowColor: Colors.red,
  child: MicButton(),
)
```

---

### google_fonts
**Versión:** ^6.1.0  
**Pub.dev:** [pub.dev/packages/google_fonts](https://pub.dev/packages/google_fonts)

Paquete para usar fuentes de Google Fonts fácilmente en Flutter.

**Uso en el proyecto:**
- Tipografías personalizadas para la UI
- Consistencia tipográfica en toda la app

**Fuentes disponibles:** Fuentes de Google Fonts

---

## 🛠️ Dependencias de Desarrollo

### flutter_test
**Incluido en:** Flutter SDK

Framework de testing para Flutter.

**Uso:**
- Tests unitarios
- Tests de widgets
- Tests de integración

---

### flutter_lints
**Versión:** ^5.0.0  
**Pub.dev:** [pub.dev/packages/flutter_lints](https://pub.dev/packages/flutter_lints)

Conjunto de reglas de linting recomendadas para Flutter.

**Uso en el proyecto:**
- Análisis estático de código
- Mejores prácticas de Flutter
- Detección de errores comunes

---

## 🗂️ Assets y Recursos

### GeoJSON - Mapa de México
**Archivo:** `assets/images/mx-all.geo.json`

Datos geográficos de los 32 estados de México para renderizar el mapa interactivo.

**Fuente:** Highcharts Maps Collection

---

### Google Sheets (CSV)
**Integración:** Datos en tiempo real

Los proyectos de inversión se obtienen desde una hoja de cálculo de Google publicada como CSV.

**URL base:**
```
https://docs.google.com/spreadsheets/d/.../pub?output=csv
```

---

## 🔧 Herramientas de Desarrollo

### Visual Studio Code
IDE principal de desarrollo con extensiones:
- Flutter
- Dart
- Error Lens
- GitLens

### Git / GitHub
Control de versiones y colaboración.

**Repositorio:** `github.com/LuisMario698/planmexicoHACKA`

---

## 📱 Requisitos del Sistema

### Para Desarrollo
- Flutter SDK 3.9.2+
- Dart SDK 3.9.2+
- Android SDK (API 21+)
- 8GB RAM mínimo recomendado

### Para Usuarios
- **Android:** 5.0 (Lollipop) o superior
- **Web:** Chrome, Firefox, Safari, Edge 

---

## 📖 Referencias y Documentación

| Recurso | Enlace |
|---------|--------|
| Flutter Docs | [docs.flutter.dev](https://docs.flutter.dev) |
| Dart Docs | [dart.dev/guides](https://dart.dev/guides) |
| Pub.dev | [pub.dev](https://pub.dev) |
| Material Design | [m3.material.io](https://m3.material.io) |
| Flutter Cookbook | [docs.flutter.dev/cookbook](https://docs.flutter.dev/cookbook) |

---

*Documentación actualizada: 26 de noviembre de 2025*
