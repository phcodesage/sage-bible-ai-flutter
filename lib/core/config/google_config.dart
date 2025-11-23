/// Google Sign-In Configuration
/// 
/// Store your Google OAuth credentials here.
class GoogleConfig {
  // TODO: Replace with your Web Client ID from Google Cloud Console
  // This is the "Web application" OAuth client ID
  // Find this in: Google Cloud Console > Credentials > Web client
  // Format: xxxxx.apps.googleusercontent.com
  static const String webClientId = '784362936378-lv9poiuvss0jmopvi06b8173oukeifmn.apps.googleusercontent.com';

  /// Validate that credentials have been set
  static bool get isConfigured {
    return webClientId.isNotEmpty && 
        webClientId != 'YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com';
  }
}
