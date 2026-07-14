import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Google Sign-In OAuth client IDs loaded from .env
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get googleIosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
}
