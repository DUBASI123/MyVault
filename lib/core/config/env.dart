class Env {
  static const supabaseUrl     = 'https://roaxygqyuemlpxygvzyq.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvYXh5Z3F5dWVtbHB4eWd2enlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ5NzU2ODEsImV4cCI6MjEwMDU1MTY4MX0.61PhYJFw-NX480PzvhKg0wak1p1Ov7-6jBQiiSF5xho';
  static const _defaultUrl     = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://myvault-jbd7.onrender.com/api',
  );

  static String? _customUrl;

  static String get backendUrl => _customUrl ?? _defaultUrl;

  static set customUrl(String? url) {
    _customUrl = url;
  }
}
