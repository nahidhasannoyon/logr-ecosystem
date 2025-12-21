import '../core/log_level.dart';

/// Configuration for LogR initialization.
///
/// Provides settings for controlling logging behavior including
/// minimum log level, buffer size, and production mode settings.
class LoggerConfig {
  /// Minimum log level to process. Logs below this level are filtered out.
  final LogLevel minimumLevel;

  /// Maximum number of log entries to keep in the in-memory ring buffer.
  /// Set to 0 to disable buffering.
  final int maxBufferSize;

  /// Enable logging in release mode.
  /// When false, logging is disabled in release builds for performance.
  final bool enableInRelease;

  /// Include stack traces for error and fatal logs automatically.
  final bool includeStackTraceForErrors;

  /// Creates a logger configuration.
  ///
  /// - [minimumLevel]: Minimum severity level to log (defaults to [LogLevel.debug])
  /// - [maxBufferSize]: Maximum buffer size (defaults to 1000)
  /// - [enableInRelease]: Allow logging in release mode (defaults to false)
  /// - [includeStackTraceForErrors]: Auto-include stack traces (defaults to true)
  const LoggerConfig({
    this.minimumLevel = LogLevel.debug,
    this.maxBufferSize = 1000,
    this.enableInRelease = false,
    this.includeStackTraceForErrors = true,
  });

  /// Creates a copy with modified fields.
  LoggerConfig copyWith({
    LogLevel? minimumLevel,
    int? maxBufferSize,
    bool? enableInRelease,
    bool? includeStackTraceForErrors,
  }) {
    return LoggerConfig(
      minimumLevel: minimumLevel ?? this.minimumLevel,
      maxBufferSize: maxBufferSize ?? this.maxBufferSize,
      enableInRelease: enableInRelease ?? this.enableInRelease,
      includeStackTraceForErrors:
          includeStackTraceForErrors ?? this.includeStackTraceForErrors,
    );
  }

  /// Default configuration for development.
  static const LoggerConfig development = LoggerConfig(
    minimumLevel: LogLevel.trace,
    maxBufferSize: 1000,
    enableInRelease: false,
    includeStackTraceForErrors: true,
  );

  /// Default configuration for production.
  static const LoggerConfig production = LoggerConfig(
    minimumLevel: LogLevel.warning,
    maxBufferSize: 100,
    enableInRelease: false,
    includeStackTraceForErrors: true,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoggerConfig &&
        other.minimumLevel == minimumLevel &&
        other.maxBufferSize == maxBufferSize &&
        other.enableInRelease == enableInRelease &&
        other.includeStackTraceForErrors == includeStackTraceForErrors;
  }

  @override
  int get hashCode {
    return Object.hash(
      minimumLevel,
      maxBufferSize,
      enableInRelease,
      includeStackTraceForErrors,
    );
  }

  @override
  String toString() {
    return 'LoggerConfig('
        'minimumLevel: $minimumLevel, '
        'maxBufferSize: $maxBufferSize, '
        'enableInRelease: $enableInRelease, '
        'includeStackTraceForErrors: $includeStackTraceForErrors)';
  }
}
