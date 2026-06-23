/// Live app configuration — Supabase and Cloudinary keys.
class EnvConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://facqwktjfalukazexjye.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhY3F3a3RqZmFsdWthemV4anllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNDk2MzMsImV4cCI6MjA5NjgyNTYzM30.GYrTZn_QiN7oDTV3EWLMmP3-K_JAvg8llPJQz4YUEa0',
  );

  static const cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dtdb4irno',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.92.219.23:5000/api',
  );

  /// Treat emulator/local backend as live when true.
  static const useLocalBackend = bool.fromEnvironment(
    'USE_LOCAL_BACKEND',
    defaultValue: true,
  );

  /// Live mode — no mock login/demo data (default: on).
  static const isLiveMode = bool.fromEnvironment(
    'LIVE_MODE',
    defaultValue: true,
  );

  static bool get isSupabaseConfigured =>
      !supabaseUrl.contains('YOUR_') && !supabaseAnonKey.contains('YOUR_');

  static bool get isFirebaseConfigured => false;

  static bool get isBackendConfigured {
    if (!useLocalBackend) return false;
    final url = apiBaseUrl.toLowerCase();
    return url.isNotEmpty;
  }

  static bool get isLiveOtpReady =>
      isBackendConfigured || isFirebaseConfigured || isSupabaseConfigured;
}
