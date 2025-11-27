class AppConfig {
  // Cambia en runtime con --dart-define
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // Emulador Android
  );
}

/// Configuración de Supabase para Plan México
/// 
/// IMPORTANTE: Reemplaza estos valores con los de tu proyecto de Supabase
/// Puedes encontrarlos en: https://supabase.com/dashboard/project/TU_PROYECTO/settings/api
class SupabaseConfig {
  // URL de tu proyecto Supabase
  // Formato: https://xxxxxxxxxxxxx.supabase.co
  static const String supabaseUrl = 'https://gyajgkwzsnypolqrwopr.supabase.co';
  
  // Anon Key (clave pública) de tu proyecto
  // Esta clave es segura para usar en el cliente
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5YWpna3d6c255cG9scXJ3b3ByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMDcwMjIsImV4cCI6MjA3OTY4MzAyMn0.55nNv0w4Tvcv52AUJLEdMKCY6efLesL2UgULDCrATwg';
  
  /// Verifica si la configuración está lista
  static bool get isConfigured => 
      supabaseUrl.isNotEmpty && 
      supabaseUrl != 'TU_SUPABASE_URL' &&
      supabaseAnonKey.isNotEmpty &&
      supabaseAnonKey != 'TU_SUPABASE_ANON_KEY';
}
