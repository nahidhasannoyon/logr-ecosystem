import 'dart:async';

import '../filters/log_filter.dart';
import '../models/logger_config.dart';
import '../outputs/console_output.dart';
import '../outputs/log_output.dart';
import 'log_entry.dart';
import 'log_level.dart';
import 'logger.dart';
import 'ring_buffer.dart';

/// Global singleton instance of the logging system.
///
/// Provides a unified interface for all logging operations and manages
/// the logging pipeline.
class LogR implements Logger {
  /// Singleton instance.
  static LogR? _instance;

  /// Configuration for this logger.
  final LoggerConfig config;

  /// List of output destinations.
  final List<LogOutput> _outputs;

  /// List of filters to apply.
  final List<LogFilter> _filters;

  /// In-memory ring buffer for recent logs.
  final RingBuffer? _buffer;

  /// Stream controller for reactive log monitoring.
  final StreamController<LogEntry> _streamController;

  /// List of synchronous callback listeners.
  final List<void Function(LogEntry)> _listeners;

  /// Whether logging is currently enabled.
  bool _isEnabled;

  /// Optional name for this logger instance.
  @override
  final String? name;

  /// Private constructor for singleton pattern.
  LogR._({
    required this.config,
    required List<LogOutput> outputs,
    required List<LogFilter> filters,
    required bool isEnabled,
  })  : name = null,
        _outputs = outputs,
        _filters = filters,
        _buffer =
            config.maxBufferSize > 0 ? RingBuffer(config.maxBufferSize) : null,
        _streamController = StreamController<LogEntry>.broadcast(),
        _listeners = [],
        _isEnabled = isEnabled;

  /// Initializes the global LogR instance.
  ///
  /// Must be called before using LogR. Can be called multiple times to
  /// reconfigure the logger.
  ///
  /// - [config]: Logger configuration
  /// - [outputs]: List of output destinations (defaults to [ConsoleOutput])
  /// - [filters]: List of filters to apply (defaults to level filter)
  static void init({
    LoggerConfig? config,
    List<LogOutput>? outputs,
    List<LogFilter>? filters,
  }) {
    final effectiveConfig = config ?? const LoggerConfig();

    // Check if we should enable logging based on release mode settings
    final isRelease = const bool.fromEnvironment('dart.vm.product');
    final isEnabled = !isRelease || effectiveConfig.enableInRelease;

    _instance = LogR._(
      config: effectiveConfig,
      outputs: outputs ?? [ConsoleOutput()],
      filters: filters ?? [LevelFilter(effectiveConfig.minimumLevel)],
      isEnabled: isEnabled,
    );
  }

  /// Returns the global LogR instance.
  ///
  /// Throws [StateError] if [init] has not been called.
  static LogR get instance {
    if (_instance == null) {
      // Auto-initialize with defaults if not already initialized
      init();
    }
    return _instance!;
  }

  /// Creates a named logger instance with the same configuration.
  ///
  /// Named loggers share the same outputs and configuration but can be
  /// identified separately in log entries.
  Logger named(String name) {
    return _NamedLogger(name, this);
  }

  /// Stream of all log entries.
  ///
  /// Useful for reactive integrations and real-time log monitoring.
  Stream<LogEntry> get stream => _streamController.stream;

  /// Adds a synchronous callback listener for log events.
  ///
  /// The callback is invoked immediately when a log is processed.
  void addListener(void Function(LogEntry) listener) {
    _listeners.add(listener);
  }

  /// Removes a previously added listener.
  void removeListener(void Function(LogEntry) listener) {
    _listeners.remove(listener);
  }

  /// Removes all listeners.
  void clearListeners() {
    _listeners.clear();
  }

  /// Returns all buffered log entries.
  ///
  /// Returns an empty list if buffering is disabled.
  List<LogEntry> getBufferedLogs() {
    return _buffer?.getAll() ?? [];
  }

  /// Returns the most recent [count] buffered log entries.
  List<LogEntry> getRecentLogs(int count) {
    return _buffer?.getRecent(count) ?? [];
  }

  /// Clears all buffered log entries.
  void clearBuffer() {
    _buffer?.clear();
  }

  /// Adds a new output destination.
  void addOutput(LogOutput output) {
    _outputs.add(output);
  }

  /// Removes an output destination.
  void removeOutput(LogOutput output) {
    _outputs.remove(output);
  }

  /// Adds a new filter.
  void addFilter(LogFilter filter) {
    _filters.add(filter);
  }

  /// Removes a filter.
  void removeFilter(LogFilter filter) {
    _filters.remove(filter);
  }

  /// Enables or disables logging.
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Returns whether logging is currently enabled.
  bool get isEnabled => _isEnabled;

  @override
  void trace(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    log(
      LogLevel.trace,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    log(
      LogLevel.debug,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    log(
      LogLevel.info,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    log(
      LogLevel.warning,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace ?? _captureStackTrace(LogLevel.error),
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    log(
      LogLevel.fatal,
      message,
      error: error,
      stackTrace: stackTrace ?? _captureStackTrace(LogLevel.fatal),
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return;

    try {
      final entry = LogEntry(
        level: level,
        message: message,
        loggerName: name,
        error: error,
        stackTrace: stackTrace,
        tags: tags,
        metadata: metadata,
      );

      _processLogEntry(entry);
    } catch (e, st) {
      // Fail-safe: ensure logging errors don't crash the application
      print('LogR internal error: $e');
      print(st);
    }
  }

  /// Processes a log entry through the pipeline.
  void _processLogEntry(LogEntry entry) {
    // Apply filters
    for (final filter in _filters) {
      if (!filter.shouldLog(entry)) {
        return; // Entry filtered out
      }
    }

    // Add to buffer
    _buffer?.add(entry);

    // Notify stream subscribers
    if (!_streamController.isClosed) {
      _streamController.add(entry);
    }

    // Notify synchronous listeners
    for (final listener in _listeners) {
      try {
        listener(entry);
      } catch (e) {
        // Ignore listener errors to prevent cascading failures
        print('LogR listener error: $e');
      }
    }

    // Write to outputs
    for (final output in _outputs) {
      try {
        output.write(entry);
      } catch (e) {
        // Ignore output errors to prevent cascading failures
        print('LogR output error: $e');
      }
    }
  }

  /// Captures current stack trace if configured.
  StackTrace? _captureStackTrace(LogLevel level) {
    if (!config.includeStackTraceForErrors) return null;
    if (level != LogLevel.error && level != LogLevel.fatal) return null;

    return StackTrace.current;
  }

  /// Closes the logger and releases all resources.
  void close() {
    for (final output in _outputs) {
      try {
        output.close();
      } catch (e) {
        print('Error closing output: $e');
      }
    }
    _streamController.close();
    _listeners.clear();
    _buffer?.clear();
  }
}

/// Named logger implementation that delegates to LogR.
class _NamedLogger implements Logger {
  @override
  final String name;

  final LogR _logr;

  _NamedLogger(this.name, this._logr);

  @override
  void trace(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.trace,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.debug,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.info,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.warning,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace ?? _captureStackTrace(LogLevel.error),
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.fatal,
      message,
      error: error,
      stackTrace: stackTrace ?? _captureStackTrace(LogLevel.fatal),
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level,
      message,
      error: error,
      stackTrace: stackTrace,
      tags: tags,
      metadata: metadata,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    if (!_logr.isEnabled) return;

    try {
      final entry = LogEntry(
        level: level,
        message: message,
        loggerName: name,
        error: error,
        stackTrace: stackTrace,
        tags: tags,
        metadata: metadata,
      );

      _logr._processLogEntry(entry);
    } catch (e, st) {
      print('LogR internal error: $e');
      print(st);
    }
  }

  StackTrace? _captureStackTrace(LogLevel level) {
    if (!_logr.config.includeStackTraceForErrors) return null;
    if (level != LogLevel.error && level != LogLevel.fatal) return null;

    return StackTrace.current;
  }
}

/// Global logger instance for quick access.
///
/// Provides convenient access to the global LogR instance without
/// repeatedly calling [LogR.instance].
Logger get log => LogR.instance;
