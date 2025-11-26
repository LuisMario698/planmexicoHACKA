class AppConfig {
  // Cambia en runtime con --dart-define
  static const String baseUrl = String.fromEnvironment(
    'http://172.32.5.231:3000',
    defaultValue: 'http://10.0.2.2:3000', // Emulador Android
  );
}
