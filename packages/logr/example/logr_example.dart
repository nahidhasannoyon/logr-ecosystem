import 'package:logr/logr.dart';

/// Comprehensive example demonstrating all Phase 1 features of LogR.
void main() {
  print('=== LogR Phase 1 Examples ===\n');

  // Example 1: Basic Initialization
  basicInitialization();

  print('\n---\n');

  // Example 2: Multi-Level Logging
  multiLevelLogging();

  print('\n---\n');

  // Example 3: Named Loggers
  namedLoggers();

  print('\n---\n');

  // Example 4: Error Logging with Stack Traces
  errorLogging();

  print('\n---\n');

  // Example 5: Tags and Metadata
  tagsAndMetadata();

  print('\n---\n');

  // Example 6: Stream API
  streamApi();

  print('\n---\n');

  // Example 7: Listener Hooks
  listenerHooks();

  print('\n---\n');

  // Example 8: Buffer Management
  bufferManagement();

  print('\n---\n');

  // Example 9: Custom Configuration
  customConfiguration();

  print('\n---\n');

  // Example 10: Filtering
  filtering();
}

/// Example 1: Basic initialization and global log access
void basicInitialization() {
  print('Example 1: Basic Initialization');

  // Initialize LogR (optional - auto-initializes with defaults)
  LogR.init();

  // Use the global log variable for quick access
  log.info('LogR initialized successfully');
  log.debug('This is a debug message');
  log.warning('This is a warning');
}

/// Example 2: Logging at all severity levels
void multiLevelLogging() {
  print('Example 2: Multi-Level Logging');

  LogR.init();

  // Log at all 6 severity levels
  log.trace('Trace: Detailed debugging information');
  log.debug('Debug: Development diagnostic info');
  log.info('Info: General informational message');
  log.warning('Warning: Something needs attention');
  log.error('Error: An error occurred');
  log.fatal('Fatal: Critical system failure');
}

/// Example 3: Creating and using named loggers
void namedLoggers() {
  print('Example 3: Named/Scoped Loggers');

  LogR.init();

  // Create named loggers for different modules
  final authLogger = LogR.instance.named('Auth');
  final dbLogger = LogR.instance.named('Database');
  final apiLogger = LogR.instance.named('API');

  // Each logger includes its name in log entries
  authLogger.info('User authentication started');
  dbLogger.debug('Executing query: SELECT * FROM users');
  apiLogger.warning('Rate limit: 80% of quota used');
  authLogger.info('User authenticated successfully');
}

/// Example 4: Logging errors with stack traces
void errorLogging() {
  print('Example 4: Error Logging with Stack Traces');

  LogR.init(
    config: const LoggerConfig(
      includeStackTraceForErrors: true,
    ),
  );

  try {
    // Simulate an error
    throw Exception('Database connection failed');
  } catch (e, stackTrace) {
    // Log error with explicit stack trace
    log.error(
      'Failed to connect to database',
      error: e,
      stackTrace: stackTrace,
    );
  }

  // Stack traces are auto-captured for error and fatal levels
  log.error('Error with auto-captured stack trace');
}

/// Example 5: Using tags and metadata
void tagsAndMetadata() {
  print('Example 5: Tags and Metadata');

  LogR.init();

  // Log with tags for categorization
  log.info(
    'API request completed',
    tags: ['api', 'http', 'success'],
  );

  // Log with contextual metadata
  log.info(
    'User action recorded',
    metadata: {
      'userId': '12345',
      'action': 'login',
      'timestamp': DateTime.now().toIso8601String(),
      'ipAddress': '192.168.1.1',
    },
  );

  // Combine tags and metadata
  log.warning(
    'High memory usage detected',
    tags: ['performance', 'memory'],
    metadata: {
      'usedMB': 1536,
      'totalMB': 2048,
      'percentage': 75,
    },
  );
}

/// Example 6: Using the Stream API for reactive logging
void streamApi() {
  print('Example 6: Stream API');

  LogR.init();

  // Subscribe to the log stream
  final subscription = LogR.instance.stream.listen((entry) {
    print('Stream received: [${entry.level.name}] ${entry.message}');
  });

  log.info('This will be emitted to the stream');
  log.error('This error will also be streamed');

  // Clean up
  subscription.cancel();
}

/// Example 7: Using synchronous listener hooks
void listenerHooks() {
  print('Example 7: Listener/Callback Hooks');

  LogR.init();

  // Add a listener that processes logs immediately
  void errorListener(LogEntry entry) {
    if (entry.level >= LogLevel.error) {
      print('⚠️  ERROR DETECTED: ${entry.message}');
    }
  }

  LogR.instance.addListener(errorListener);

  log.info('Normal operation');
  log.error('This will trigger the listener');
  log.fatal('Critical error!');

  // Remove listener when done
  LogR.instance.removeListener(errorListener);
}

/// Example 8: Working with the in-memory buffer
void bufferManagement() {
  print('Example 8: Buffer Management');

  LogR.init(
    config: const LoggerConfig(
      maxBufferSize: 5,
    ),
  );

  // Log some messages
  for (int i = 1; i <= 7; i++) {
    log.info('Message $i');
  }

  // Retrieve all buffered logs (max 5 due to ring buffer)
  final allLogs = LogR.instance.getBufferedLogs();
  print('Buffered logs: ${allLogs.length}');
  for (final entry in allLogs) {
    print('  - ${entry.message}');
  }

  // Get only recent logs
  final recentLogs = LogR.instance.getRecentLogs(2);
  print('Recent logs: ${recentLogs.length}');
  for (final entry in recentLogs) {
    print('  - ${entry.message}');
  }

  // Clear the buffer
  LogR.instance.clearBuffer();
  print('Buffer cleared. Remaining: ${LogR.instance.getBufferedLogs().length}');
}

/// Example 9: Custom configuration
void customConfiguration() {
  print('Example 9: Custom Configuration');

  // Development configuration
  LogR.init(
    config: LoggerConfig.development,
  );
  log.trace('Development mode: all levels enabled');

  // Production configuration
  LogR.init(
    config: LoggerConfig.production,
  );
  log.debug('This won\'t be logged in production mode');
  log.error('Only warnings and above are logged');

  // Custom configuration
  LogR.init(
    config: const LoggerConfig(
      minimumLevel: LogLevel.info,
      maxBufferSize: 500,
      enableInRelease: false,
      includeStackTraceForErrors: true,
    ),
  );
  log.info('Custom configuration applied');
}

/// Example 10: Filtering logs
void filtering() {
  print('Example 10: Filtering');

  LogR.init();

  // Add a level filter
  LogR.instance.addFilter(LevelFilter(LogLevel.warning));

  log.debug('This will be filtered out');
  log.info('This will also be filtered out');
  log.warning('This will pass the filter');
  log.error('This will also pass');

  // Add a name filter for specific loggers
  LogR.instance.addFilter(NameFilter('Auth', include: true));

  final authLogger = LogR.instance.named('Auth');
  final dbLogger = LogR.instance.named('Database');

  authLogger.warning('This will pass (Auth logger, warning level)');
  dbLogger.warning('This will be filtered (not Auth logger)');
}
