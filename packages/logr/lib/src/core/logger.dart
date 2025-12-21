import '../core/log_level.dart';

/// Interface for logger implementations.
///
/// Provides logging methods for each severity level.
abstract class Logger {
  /// Optional name or scope of this logger.
  String? get name;

  /// Logs a message at [LogLevel.trace] level.
  void trace(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });

  /// Logs a message at [LogLevel.debug] level.
  void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });

  /// Logs a message at [LogLevel.info] level.
  void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });

  /// Logs a message at [LogLevel.warning] level.
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });

  /// Logs a message at [LogLevel.error] level.
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });

  /// Logs a message at [LogLevel.fatal] level.
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });

  /// Logs a message at the specified [level].
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });
}
