import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorMessageUtils {
  static String generate(dynamic error) {
    if (error is AuthException) {
      return error.message;
    } else if (error is PostgrestException) {
      return error.message;
    } else if (error is StorageException) {
      return error.message;
    } else if (error is SocketException) {
      return "No internet connection. Please check your network settings.";
    } else if (error is FormatException) {
      return "Bad response format.";
    } else {
      // Clean up "Exception: " prefix if present
      final message = error.toString();
      if (message.startsWith("Exception: ")) {
        return message.substring(11); // Length of "Exception: "
      }
      return message;
    }
  }
}
