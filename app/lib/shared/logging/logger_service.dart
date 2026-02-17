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
    final logMessage = "FILE: $fileName | FUNC: $functionName | OUTCOME: $outcome";
    dev.log(logMessage, name: 'DataAtBat_Log');
  }
}