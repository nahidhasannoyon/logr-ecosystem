import '../core/log_entry.dart';

/// Interface for log output destinations.
/// 
/// Implementations of this interface handle where and how log entries
/// are written (e.g., console, file, remote service).
abstract class LogOutput {
  /// Writes a log entry to the output destination.
  /// 
  /// Implementations should handle errors gracefully and not throw exceptions.
  void write(LogEntry entry);

  /// Closes the output and releases any resources.
  /// 
  /// Called when the logger is shut down.
  void close() {}
}
