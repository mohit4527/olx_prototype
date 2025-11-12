class Logger {
  /// Simple debug logger used across the app. Prints timestamp, tag and message.
  static void d(String tag, String message) {
    final time = DateTime.now().toIso8601String();
    // Keep a single print so logs are easy to grep
    print('[$time] [$tag] $message');
  }

  /// Info level
  static void i(String tag, String message) {
    d(tag, 'INFO: $message');
  }

  /// Error level
  static void e(String tag, String message) {
    d(tag, 'ERROR: $message');
  }

  /// Verbose print with optional stack
  static void v(String tag, String message, [StackTrace? st]) {
    d(tag, 'VERBOSE: $message');
    if (st != null) print(st.toString());
  }
}
