class AppSecrets {
  static String supabaseUrl = 'https://pbfnylvcpscoawcsqetw.supabase.co';
  static String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBiZm55bHZjcHNjb2F3Y3NxZXR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5Mjc3MjcsImV4cCI6MjA4MjUwMzcyN30.idVdKDm9qqXc4NwWnWhbQ7mRYxPg_wqnzG51l0owAUQ';

  // Google Sign-In OAuth client IDs (public values, safe to commit).
  // The Web Client ID is used as serverClientId so Supabase can verify the ID token's `aud`.
  static const String googleWebClientId =
      '903953714490-sn2t8fv6imh8c7tqbmr3ikqf64kkkbkv.apps.googleusercontent.com';
  static const String googleIosClientId =
      '903953714490-1jj1pgn46uc363m6l6568eob0f933huu.apps.googleusercontent.com';
}
