# LogR - Pure Dart Logging Core

A fast, flexible, and feature-rich logging system for Dart applications. LogR provides enterprise-grade logging capabilities without requiring Flutter dependencies, making it perfect for Dart servers, CLI tools, and Flutter apps alike.

## ✨ Features

### Phase 1 - Core Foundation (MVP) ✅

- **🎯 Multi-Level Logging**: Six severity levels (trace, debug, info, warning, error, fatal) with configurable filtering
- **🔧 Singleton Access**: Global singleton pattern via `LogR` class with easy initialization
- **📛 Named/Scoped Loggers**: Create named logger instances for better organization and filtering
- **🔒 Immutable LogEntry**: Thread-safe data model with id, timestamp, level, message, error, stackTrace, tags, and metadata
- **🎨 Console Output**: Built-in console output with automatic ANSI color support
- **💾 In-Memory Ring Buffer**: Circular buffer with configurable size for recent log retention
- **🌊 Stream API**: Reactive `Stream<LogEntry>` for real-time log monitoring
- **🪝 Listener/Callback Hooks**: Synchronous callback registration for immediate log processing
- **🚀 Release Mode Control**: Automatically disable or minimize logging in production builds
- **⚡ Zero Dependencies**: Pure Dart implementation with no external dependencies

## 🚀 Getting Started

### Installation

Add LogR to your `pubspec.yaml`:

```yaml
dependencies:
  logr: ^0.1.0
```

### Quick Start

```dart
import 'package:logr/logr.dart';

void main() {
  // Initialize (optional - auto-initializes with defaults)
  LogR.init();

  // Use the global log instance
  log.info('Application started');
  log.debug('Debug information');
  log.error('An error occurred');

  // Create named loggers for different modules
  final authLogger = LogR.instance.named('Auth');
  authLogger.info('User logged in');
}
```

## 📖 Usage

### Basic Logging

LogR supports six severity levels:

```dart
log.trace('Detailed trace information');
log.debug('Debug information');
log.info('General information');
log.warning('Warning message');
log.error('Error occurred');
log.fatal('Critical failure');
```

### Configuration

Configure LogR for different environments:

```dart
// Development configuration - all logs enabled
LogR.init(config: LoggerConfig.development);

// Production configuration - only warnings and above
LogR.init(config: LoggerConfig.production);

// Custom configuration
LogR.init(
  config: const LoggerConfig(
    minimumLevel: LogLevel.info,
    maxBufferSize: 1000,
    enableInRelease: false,
    includeStackTraceForErrors: true,
  ),
);
```

### Named Loggers

Organize logs by creating named loggers:

```dart
final authLogger = LogR.instance.named('Auth');
final dbLogger = LogR.instance.named('Database');
final apiLogger = LogR.instance.named('API');

authLogger.info('User authentication started');
dbLogger.debug('Executing query');
apiLogger.warning('Rate limit approaching');
```

### Error Logging

Log errors with automatic stack trace capture:

```dart
try {
  // Your code
} catch (e, stackTrace) {
  log.error(
    'Operation failed',
    error: e,
    stackTrace: stackTrace,
  );
}

// Stack traces auto-captured for error and fatal levels
log.error('Error with auto-captured stack trace');
```

### Tags and Metadata

Add contextual information to logs:

```dart
log.info(
  'API request completed',
  tags: ['api', 'http', 'success'],
  metadata: {
    'userId': '12345',
    'endpoint': '/api/users',
    'duration_ms': 145,
  },
);
```

### Stream API

Monitor logs in real-time:

```dart
final subscription = LogR.instance.stream.listen((entry) {
  // Process log entries in real-time
  print('[${entry.level.name}] ${entry.message}');
});

// Clean up when done
subscription.cancel();
```

### Listener Hooks

Add synchronous callbacks for immediate processing:

```dart
void errorListener(LogEntry entry) {
  if (entry.level >= LogLevel.error) {
    // Send to error tracking service
    reportError(entry);
  }
}

LogR.instance.addListener(errorListener);

// Remove when done
LogR.instance.removeListener(errorListener);
```

### Buffer Management

Access recent logs from the in-memory buffer:

```dart
// Get all buffered logs
final allLogs = LogR.instance.getBufferedLogs();

// Get recent logs
final recentLogs = LogR.instance.getRecentLogs(10);

// Clear buffer
LogR.instance.clearBuffer();
```

### Filtering

Apply custom filters to control which logs are processed:

```dart
// Filter by level
LogR.instance.addFilter(LevelFilter(LogLevel.warning));

// Filter by logger name
LogR.instance.addFilter(NameFilter('Auth', include: true));

// Combine multiple filters
LogR.instance.addFilter(CompositeFilter([
  LevelFilter(LogLevel.info),
  NameFilter(RegExp(r'^(Auth|API)'), include: true),
]));
```

### Custom Outputs

Add custom output destinations:

```dart
class FileOutput implements LogOutput {
  final File file;

  FileOutput(this.file);

  @override
  void write(LogEntry entry) {
    file.writeAsStringSync(
      '${entry.toString()}\n',
      mode: FileMode.append,
    );
  }
}

LogR.instance.addOutput(FileOutput(File('logs.txt')));
```

## 📋 API Reference

### Core Classes

- **`LogR`**: Main singleton class for logging operations
- **`Logger`**: Interface for logger implementations
- **`LogEntry`**: Immutable data model for log entries
- **`LogLevel`**: Enum for severity levels
- **`LoggerConfig`**: Configuration options

### Output Classes

- **`LogOutput`**: Interface for output destinations
- **`ConsoleOutput`**: Console output with ANSI colors

### Filter Classes

- **`LogFilter`**: Interface for filtering logs
- **`LevelFilter`**: Filter by minimum severity level
- **`NameFilter`**: Filter by logger name pattern
- **`CompositeFilter`**: Combine multiple filters

## 🧪 Testing

LogR includes comprehensive unit and integration tests:

```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage

# Run specific test file
dart test test/unit/logr_test.dart
```

## 🎯 Roadmap

### Phase 2 - Flutter Integration

- Flutter-specific outputs and formatters
- Widget for displaying logs in-app
- Integration with Flutter DevTools

### Phase 3 - Advanced Features

- File output with rotation
- Remote logging support
- Performance monitoring
- Integration with popular packages (Bloc, Riverpod, Dio, etc.)

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- [Documentation](https://github.com/nahidhasannoyon/logr-ecosystem)
- [Issue Tracker](https://github.com/nahidhasannoyon/logr-ecosystem/issues)
- [Changelog](CHANGELOG.md)

## 💡 Examples

See the [example](example/logr_example.dart) directory for comprehensive examples demonstrating all features.
