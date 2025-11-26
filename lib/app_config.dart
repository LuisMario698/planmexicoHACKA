class AppConfig {
  // Cambia en runtime con --dart-define
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // Emulador Android
  );
}
