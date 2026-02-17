import 'dart:developer' as dev;

class LoggerService {
  /// Logs an access event, function call, and the resulting outcome.
  /// 
  /// [fileName]: The name of the file being accessed (e.g., 'router.dart')
  /// [functionName]: The specific method or route being called
  /// [outcome]: 'Success', 'Failure', or a specific error message

  // Static for easy access across the app
  static void logEvent({
    required String fileName,
    required String functionName,
    required String outcome,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = "[$timestamp] FILE: $fileName | FUNC: $functionName | OUTCOME: $outcome";

    // Outputs to the debug console
    dev.log(logMessage, name: 'APP_LOG');

    // Here you could also write to a local file or an external database
    // _writeToOutput(logMessage);
  }

  // static void _writeToOutput(String message) {
    // Placeholder for persistent storage logic (e.g. writing to a .txt file)
  // }
}