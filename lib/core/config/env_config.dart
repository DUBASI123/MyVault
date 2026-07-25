/// Live app configuration — Supabase and Cloudinary keys.
class EnvConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://roaxygqyuemlpxygvzyq.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvYXh5Z3F5dWVtbHB4eWd2enlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ5NzU2ODEsImV4cCI6MjEwMDU1MTY4MX0.61PhYJFw-NX480PzvhKg0wak1p1Ov7-6jBQiiSF5xho',
  );



  /// Live mode — no mock login/demo data (default: on).
  static const isLiveMode = bool.fromEnvironment(
    'LIVE_MODE',
    defaultValue: true,
  );

  static bool get isSupabaseConfigured =>
      !supabaseUrl.contains('YOUR_') && !supabaseAnonKey.contains('YOUR_');

  static bool get isFirebaseConfigured => false;

  static bool get isLiveOtpReady => isFirebaseConfigured || isSupabaseConfigured;
}

