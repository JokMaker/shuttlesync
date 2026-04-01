/// App-wide runtime configuration.
///
/// For local development:
/// - Android emulator uses: http://10.0.2.2:8000
/// - iOS simulator uses:    http://localhost:8000
/// - Physical device uses:  http://<your-lan-ip>:8000
///
/// For production, set this to your hosted FastAPI base URL.
class AppConfig {
  /// Base URL of the FastAPI server (no trailing slash).
  ///
  /// Example: https://api.shuttlesync.example.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
}
