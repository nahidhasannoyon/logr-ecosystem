/// Pure Dart logging core for the LogR ecosystem.
///
/// LogR provides a fast, flexible, and feature-rich logging system for Dart
/// applications without requiring Flutter dependencies.
///
/// ## Features
///
/// - **Multi-Level Logging**: Support for 6 severity levels (trace, debug, info, warning, error, fatal)
/// - **Singleton Access**: Global singleton pattern for easy access anywhere in your app
/// - **Named/Scoped Loggers**: Create named logger instances for better organization
/// - **Immutable LogEntry**: Thread-safe, immutable log data model
/// - **Console Output**: Built-in console output with ANSI color support
/// - **In-Memory Buffer**: Circular buffer for retaining recent logs
/// - **Stream API**: Reactive stream of log entries for real-time monitoring
/// - **Listener Hooks**: Synchronous callbacks for immediate log processing
/// - **Release Mode Control**: Automatically disable logging in production builds
///
/// ## Quick Start
///
/// ```dart
/// import 'package:logr/logr.dart';
///
/// void main() {
///   // Initialize the logger (optional - auto-initializes with defaults)
///   LogR.init(
///     config: LoggerConfig.development,
///   );
///
///   // Use the global log instance
///   log.info('Application started');
///   log.debug('Debug information');
///   log.error('An error occurred', error: exception);
///
///   // Create named loggers
///   final authLogger = LogR.instance.named('Auth');
///   authLogger.info('User logged in');
/// }
/// ```
///
/// ## Configuration
///
/// ```dart
/// LogR.init(
///   config: LoggerConfig(
///     minimumLevel: LogLevel.debug,
///     maxBufferSize: 1000,
///     enableInRelease: false,
///     includeStackTraceForErrors: true,
///   ),
/// );
/// ```
library;

export 'src/core/log_entry.dart';
// Core types
export 'src/core/log_level.dart';
export 'src/core/logger.dart';
export 'src/core/logr.dart';
// Filters
export 'src/filters/log_filter.dart';
// Configuration
export 'src/models/logger_config.dart';
export 'src/outputs/console_output.dart';
// Outputs
export 'src/outputs/log_output.dart';
