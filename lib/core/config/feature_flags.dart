class FeatureFlags {
  // Prevent instantiation
  const FeatureFlags._();

  /// Controls whether social authentication (Google, Apple, etc.) is enabled.
  static const bool isSocialAuthEnabled = false;
  static const bool isForgotPasswordEnabled = false;
  static const bool isSubscriptionEnabled = false;
}
