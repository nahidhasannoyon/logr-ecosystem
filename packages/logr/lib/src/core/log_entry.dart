import 'package:meta/meta.dart';

import 'log_level.dart';

/// Immutable data model representing a single log event.
///
/// Contains all information about a log event including severity level,
/// message, error details, and contextual metadata.
@immutable
class LogEntry {
  /// Unique identifier for this log entry.
  final String id;

  /// When this log entry was created.
  final DateTime timestamp;

  /// The severity level of this log entry.
  final LogLevel level;

  /// The log message.
  final String message;

  /// Optional name or scope of the logger that created this entry.
  final String? loggerName;

  /// Optional error object associated with this log entry.
  final Object? error;

  /// Optional stack trace associated with this log entry.
  final StackTrace? stackTrace;

  /// Optional tags for categorizing or filtering log entries.
  final List<String> tags;

  /// Optional contextual metadata as key-value pairs.
  final Map<String, dynamic> metadata;

  /// Creates a new immutable log entry.
  ///
  /// - [id]: Unique identifier (auto-generated if not provided)
  /// - [timestamp]: When the log was created (defaults to now)
  /// - [level]: Severity level of the log
  /// - [message]: The log message
  /// - [loggerName]: Optional name of the logger
  /// - [error]: Optional error object
  /// - [stackTrace]: Optional stack trace
  /// - [tags]: Optional list of tags for categorization
  /// - [metadata]: Optional contextual information
  LogEntry({
    String? id,
    DateTime? timestamp,
    required this.level,
    required this.message,
    this.loggerName,
    this.error,
    this.stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now(),
        tags = List.unmodifiable(tags ?? const []),
        metadata = Map.unmodifiable(metadata ?? const {});

  /// Creates a copy of this log entry with modified fields.
  LogEntry copyWith({
    String? id,
    DateTime? timestamp,
    LogLevel? level,
    String? message,
    String? loggerName,
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      message: message ?? this.message,
      loggerName: loggerName ?? this.loggerName,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Generates a unique identifier for a log entry.
  static String _generateId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${_counter++}';
  }

  static int _counter = 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogEntry &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.level == level &&
        other.message == message &&
        other.loggerName == loggerName &&
        other.error == error &&
        other.stackTrace == stackTrace;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      timestamp,
      level,
      message,
      loggerName,
      error,
      stackTrace,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('[${timestamp.toIso8601String()}] ')
      ..write('${level.name} ');

    if (loggerName != null) {
      buffer.write('[$loggerName] ');
    }

    buffer.write(message);

    if (error != null) {
      buffer.write(' | Error: $error');
    }

    if (tags.isNotEmpty) {
      buffer.write(' | Tags: ${tags.join(', ')}');
    }

    return buffer.toString();
  }
}
