/// Supabase Configuration
/// 
/// Store your Supabase project credentials here.
/// 
/// IMPORTANT: In production, use environment variables or a secure config management system.
/// Never commit real credentials to version control.
class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  // Find this in: Supabase Dashboard > Settings > API > Project URL
  static const String supabaseUrl = 'https://idoosepbgjnfgufcvsfm.supabase.co';

  // TODO: Replace with your Supabase anon/public key
  // Find this in: Supabase Dashboard > Settings > API > Project API keys > anon public
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlkb29zZXBiZ2puZmd1ZmN2c2ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MjQzMjksImV4cCI6MjA3OTUwMDMyOX0.qnVRHhCUxsAraRNA-njRRSf_CAfo02s11PPkQKGm9yo';

  /// Validate that credentials have been set
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && 
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE';
  }
}
