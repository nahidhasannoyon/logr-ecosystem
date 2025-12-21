import 'dart:io' show Platform, stdout;

import '../core/log_entry.dart';
import '../core/log_level.dart';
import 'log_output.dart';

/// Writes log entries to the console with ANSI color support.
///
/// Automatically detects terminal capabilities and applies colors
/// when supported.
class ConsoleOutput implements LogOutput {
  /// Whether to use ANSI color codes.
  final bool useColors;

  /// Whether to include timestamp in output.
  final bool includeTimestamp;

  /// Whether to include logger name in output.
  final bool includeLoggerName;

  /// Creates a console output instance.
  ///
  /// - [useColors]: Enable ANSI colors (auto-detected if null)
  /// - [includeTimestamp]: Show timestamps (default: true)
  /// - [includeLoggerName]: Show logger name (default: true)
  ConsoleOutput({
    bool? useColors,
    this.includeTimestamp = true,
    this.includeLoggerName = true,
  }) : useColors = useColors ?? _supportsAnsiColors();

  /// Detects if the current terminal supports ANSI colors.
  static bool _supportsAnsiColors() {
    try {
      // Check if stdout supports ANSI colors
      return stdout.supportsAnsiEscapes;
    } catch (_) {
      // Fallback for environments where stdout detection fails
      return Platform.isLinux || Platform.isMacOS;
    }
  }

  @override
  void write(LogEntry entry) {
    try {
      final buffer = StringBuffer();

      // Add timestamp
      if (includeTimestamp) {
        buffer.write('[${_formatTimestamp(entry.timestamp)}] ');
      }

      // Add colored level
      buffer.write(_formatLevel(entry.level));
      buffer.write(' ');

      // Add logger name
      if (includeLoggerName && entry.loggerName != null) {
        buffer.write('[${entry.loggerName}] ');
      }

      // Add message
      buffer.write(entry.message);

      // Add error if present
      if (entry.error != null) {
        buffer.write('\n  Error: ${entry.error}');
      }

      // Add stack trace if present
      if (entry.stackTrace != null) {
        final stackLines = entry.stackTrace.toString().split('\n');
        for (final line in stackLines.take(10)) {
          // Limit to 10 lines
          if (line.trim().isNotEmpty) {
            buffer.write('\n    $line');
          }
        }
      }

      // Add tags if present
      if (entry.tags.isNotEmpty) {
        buffer.write('\n  Tags: ${entry.tags.join(', ')}');
      }

      // Add metadata if present
      if (entry.metadata.isNotEmpty) {
        buffer.write('\n  Metadata: ${entry.metadata}');
      }

      print(buffer.toString());
    } catch (e) {
      // Fallback in case of any formatting errors
      print('LOG ERROR: Failed to format log entry: $e');
      print('Original message: ${entry.message}');
    }
  }

  /// Formats timestamp in HH:mm:ss.SSS format.
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  /// Formats log level with appropriate colors.
  String _formatLevel(LogLevel level) {
    final levelStr = level.name.padRight(7);

    if (!useColors) {
      return levelStr;
    }

    final color = _getColorForLevel(level);
    return '$color$levelStr$_resetColor';
  }

  /// Gets ANSI color code for a log level.
  String _getColorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return _gray;
      case LogLevel.debug:
        return _cyan;
      case LogLevel.info:
        return _green;
      case LogLevel.warning:
        return _yellow;
      case LogLevel.error:
        return _red;
      case LogLevel.fatal:
        return _magenta;
    }
  }

  // ANSI color codes
  static const String _resetColor = '\x1B[0m';
  static const String _gray = '\x1B[90m';
  static const String _cyan = '\x1B[36m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _magenta = '\x1B[35m';

  @override
  void close() {
    // Console output doesn't need explicit cleanup
  }
}
