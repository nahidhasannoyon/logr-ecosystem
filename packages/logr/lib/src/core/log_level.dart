/// Severity levels for log entries.
///
/// Each level represents a different severity of logging message,
/// from most detailed (trace) to most critical (fatal).
enum LogLevel {
  /// Most detailed level for tracing application flow.
  /// Typically used in development for detailed debugging.
  trace(0, 'TRACE'),

  /// Detailed information for debugging purposes.
  /// Used to diagnose issues during development.
  debug(1, 'DEBUG'),

  /// General informational messages about application state.
  /// Used for normal application flow tracking.
  info(2, 'INFO'),

  /// Warning messages for potentially harmful situations.
  /// The application continues but attention may be needed.
  warning(3, 'WARNING'),

  /// Error messages for serious issues.
  /// The application encountered an error but can continue.
  error(4, 'ERROR'),

  /// Critical error messages indicating application failure.
  /// The application may not be able to continue.
  fatal(5, 'FATAL');

  /// Numeric value for level comparison and filtering.
  final int value;

  /// String representation of the level.
  final String name;

  const LogLevel(this.value, this.name);

  /// Returns true if this level is equal to or more severe than [other].
  bool operator >=(LogLevel other) => value >= other.value;

  /// Returns true if this level is equal to or less severe than [other].
  bool operator <=(LogLevel other) => value <= other.value;

  /// Returns true if this level is more severe than [other].
  bool operator >(LogLevel other) => value > other.value;

  /// Returns true if this level is less severe than [other].
  bool operator <(LogLevel other) => value < other.value;

  @override
  String toString() => name;
}
