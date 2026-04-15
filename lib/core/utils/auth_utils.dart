import 'package:url_launcher/url_launcher.dart';

class AuthUtils {
  /// Robust helper to open the user's mail application.
  /// Tries Gmail app first, then iOS mail, then falls back to mailto or web gmail.
  static Future<void> openMailApp() async {
    final List<Uri> emailUris = [
      Uri.parse("googlegmail:///"), // Gmail App
      Uri.parse("message://"), // iOS Default Mail
      Uri.parse("mailto:"), // Generic Fallback
    ];

    for (var uri in emailUris) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    }
    
    // Fallback to web gmail if everything else fails
    final webGmail = Uri.parse("https://mail.google.com/");
    if (await canLaunchUrl(webGmail)) {
      await launchUrl(webGmail, mode: LaunchMode.externalApplication);
    }
  }
}
