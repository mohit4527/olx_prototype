import 'package:http/http.dart' as http;

/// API Configuration and Network Debugging Utilities
class ApiConfig {
  // Primary API endpoints
  static const String primaryBaseUrl = "https://oldmarket.bhoomi.cloud/api";
  static const String primaryAssetsUrl = "https://oldmarket.bhoomi.cloud/";

  // Fallback endpoints (in case primary is down)
  static const String fallbackBaseUrl =
      "http://10.0.2.2:3000/api"; // Android emulator localhost
  static const String fallbackAssetsUrl = "http://10.0.2.2:3000/";

  // Current configuration
  static String baseUrl = primaryBaseUrl;
  static String assetsUrl = primaryAssetsUrl;
  static bool debugMode = true;

  /// Check if primary server is reachable and switch to fallback if needed
  static Future<bool> checkConnectivity() async {
    try {
      final uri = Uri.parse('$primaryBaseUrl/health-check');
      final response = await http.get(uri).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (debugMode) print('✅ Primary server reachable');
        _usePrimaryServer();
        return true;
      }
    } catch (e) {
      if (debugMode) print('❌ Primary server unreachable: $e');
    }

    if (debugMode) print('🔄 Switching to fallback server');
    _useFallbackServer();
    return false;
  }

  static void _usePrimaryServer() {
    baseUrl = primaryBaseUrl;
    assetsUrl = primaryAssetsUrl;
  }

  static void _useFallbackServer() {
    baseUrl = fallbackBaseUrl;
    assetsUrl = fallbackAssetsUrl;
  }

  /// Build full media URL with current configuration
  static String buildMediaUrl(String path) {
    if (path.isEmpty) return "";
    final fixed = path.replaceAll("\\", "/");
    if (fixed.startsWith("http")) return fixed;
    final rel = fixed.startsWith("/") ? fixed.substring(1) : fixed;
    return "$assetsUrl$rel";
  }

  /// Log network requests for debugging
  static void logRequest(String method, String url, [dynamic body]) {
    if (debugMode) {
      print('🌐 [$method] $url');
      if (body != null) print('📤 Body: $body');
    }
  }

  /// Log network responses for debugging
  static void logResponse(String url, int statusCode, [dynamic response]) {
    if (debugMode) {
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      print('$emoji Response [$statusCode] for $url');
      if (response != null && response.toString().length < 500) {
        print('📥 Response: $response');
      }
    }
  }
}
