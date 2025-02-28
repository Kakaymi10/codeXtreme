import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase client singleton
class SupabaseConfig {
  static late final SupabaseClient client;

  // Replace these with your Supabase URL and anon key
  static const String supabaseUrl = 'https://tlucpdrdkuorqapvwtnk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRsdWNwZHJka3VvcnFhcHZ3dG5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA3MjUxMjAsImV4cCI6MjA1NjMwMTEyMH0.MQm2xQ95seQ1MfhtCBYIlaeOnY7NabhevgxnJWOSYcI';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    client = Supabase.instance.client;
  }
}
