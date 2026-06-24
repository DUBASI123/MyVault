/// Live app configuration — Supabase and Cloudinary keys.
class EnvConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://oawomrlsitttrbulxgyk.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hd29tcmxzaXR0dHJidWx4Z3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NDk3NzQsImV4cCI6MjA5NzQyNTc3NH0.j3rs7JlIZiRXxsw67GVLbQsKGpOUP_758PuIbGnYzig',
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
