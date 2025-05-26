import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://qtglfztuvaqvumvrywcx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0Z2xmenR1dmFxdnVtdnJ5d2N4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDE3MzEsImV4cCI6MjA2MzgxNzczMX0.ggrRFhDWtMZsP712rYAPOnhK0GLmh4-7Jh4aZKuqeuc';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;
  static SupabaseStorageClient get storage => Supabase.instance.client.storage;
}