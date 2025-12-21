import 'package:logr/logr.dart';
import 'package:test/test.dart';

/// Integration tests for the complete LogR logging pipeline.
///
/// These tests verify end-to-end functionality of the logging system.
void main() {
  setUp(() {
    // Initialize with fresh configuration for each test
    LogR.init(
      config: const LoggerConfig(
        minimumLevel: LogLevel.trace,
        maxBufferSize: 100,
        enableInRelease: true,
        includeStackTraceForErrors: true,
      ),
    );
  });

  group('Complete Logging Pipeline', () {
    test('should process logs through complete pipeline', () async {
      // Set up multiple outputs and listeners
      final consoleOutput = ConsoleOutput(useColors: false);
      final streamLogs = <LogEntry>[];
      final listenerLogs = <LogEntry>[];

      LogR.instance.addOutput(consoleOutput);
      LogR.instance.addListener(listenerLogs.add);
      final subscription = LogR.instance.stream.listen(streamLogs.add);

      // Log at different levels
      log.trace('Trace message');
      log.debug('Debug message');
      log.info('Info message');
      log.warning('Warning message');
      log.error('Error message');
      log.fatal('Fatal message');

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify all outputs received the logs
      expect(listenerLogs.length, equals(6));
      expect(streamLogs.length, equals(6));

      // Verify buffer contains all logs
      final buffered = LogR.instance.getBufferedLogs();
      expect(buffered.length, equals(6));

      // Verify log levels
      expect(buffered[0].level, equals(LogLevel.trace));
      expect(buffered[1].level, equals(LogLevel.debug));
      expect(buffered[2].level, equals(LogLevel.info));
      expect(buffered[3].level, equals(LogLevel.warning));
      expect(buffered[4].level, equals(LogLevel.error));
      expect(buffered[5].level, equals(LogLevel.fatal));

      await subscription.cancel();
    });

    test('should handle complex log entries', () async {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      final error = Exception('Test exception');
      final stackTrace = StackTrace.current;

      log.error(
        'Complex error occurred',
        error: error,
        stackTrace: stackTrace,
        tags: ['critical', 'database'],
        metadata: {
          'userId': '12345',
          'action': 'update',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      expect(logged.length, equals(1));
      final entry = logged[0];

      expect(entry.level, equals(LogLevel.error));
      expect(entry.message, equals('Complex error occurred'));
      expect(entry.error, equals(error));
      expect(entry.stackTrace, equals(stackTrace));
      expect(entry.tags, contains('critical'));
      expect(entry.tags, contains('database'));
      expect(entry.metadata['userId'], equals('12345'));
      expect(entry.metadata['action'], equals('update'));
    });

    test('should filter and buffer correctly', () {
      LogR.init(
        config: const LoggerConfig(
          minimumLevel: LogLevel.warning,
          maxBufferSize: 3,
          enableInRelease: true,
        ),
      );

      // Log at various levels
      log.trace('Trace');
      log.debug('Debug');
      log.info('Info');
      log.warning('Warning 1');
      log.error('Error 1');
      log.warning('Warning 2');
      log.error('Error 2');

      final buffered = LogR.instance.getBufferedLogs();

      // Only warning and above should be logged
      // Buffer size is 3, so oldest entry should be removed
      expect(buffered.length, equals(3));
      expect(buffered[0].message, equals('Error 1'));
      expect(buffered[1].message, equals('Warning 2'));
      expect(buffered[2].message, equals('Error 2'));
    });

    test('should work with multiple named loggers', () async {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      final authLogger = LogR.instance.named('Auth');
      final dbLogger = LogR.instance.named('Database');
      final apiLogger = LogR.instance.named('API');

      authLogger.info('User login attempt');
      dbLogger.debug('Query executed');
      apiLogger.warning('Rate limit approaching');
      authLogger.info('User authenticated');
      dbLogger.error('Connection failed');

      expect(logged.length, equals(5));
      expect(logged[0].loggerName, equals('Auth'));
      expect(logged[1].loggerName, equals('Database'));
      expect(logged[2].loggerName, equals('API'));
      expect(logged[3].loggerName, equals('Auth'));
      expect(logged[4].loggerName, equals('Database'));
    });

    test('should handle high volume logging', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      // Log 1000 entries
      for (int i = 0; i < 1000; i++) {
        log.info('Message $i');
      }

      expect(logged.length, equals(1000));

      // Buffer should only contain most recent 100 (default config)
      final buffered = LogR.instance.getBufferedLogs();
      expect(buffered.length, equals(100));
      expect(buffered.last.message, equals('Message 999'));
    });

    test('should disable logging in release mode', () {
      LogR.init(
        config: const LoggerConfig(
          enableInRelease: false,
        ),
      );

      // Manually simulate release mode behavior
      LogR.instance.setEnabled(false);

      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      log.info('This should not be logged');

      expect(logged.length, equals(0));
    });

    test('should handle concurrent logging', () async {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      // Simulate concurrent logging from multiple sources
      final futures = <Future>[];
      for (int i = 0; i < 10; i++) {
        futures.add(Future(() {
          for (int j = 0; j < 10; j++) {
            log.info('Thread $i Message $j');
          }
        }));
      }

      await Future.wait(futures);

      expect(logged.length, equals(100));
    });

    test('should work with custom filters', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      // Add filter that only allows messages containing 'important'
      LogR.instance.addFilter(_MessageFilter('important'));

      log.info('Regular message');
      log.info('This is important');
      log.warning('Another regular message');
      log.error('Very important error');

      expect(logged.length, equals(2));
      expect(logged[0].message, contains('important'));
      expect(logged[1].message, contains('important'));
    });

    test('should maintain log entry immutability', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      log.info(
        'Original message',
        tags: ['tag1'],
        metadata: {'key': 'value'},
      );

      final entry = logged[0];

      // Should not be able to modify the entry
      expect(
        () => (entry.tags as List).add('tag2'),
        throwsUnsupportedError,
      );
      expect(
        () => (entry.metadata as Map)['key2'] = 'value2',
        throwsUnsupportedError,
      );
    });

    test('should auto-capture stack traces for errors', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      log.error('Error without explicit stack trace');
      log.fatal('Fatal without explicit stack trace');
      log.warning('Warning without stack trace');

      expect(logged[0].stackTrace, isNotNull); // error
      expect(logged[1].stackTrace, isNotNull); // fatal
      expect(logged[2].stackTrace, isNull); // warning
    });
  });

  group('Real-World Scenarios', () {
    test('should handle authentication flow logging', () async {
      final authLogger = LogR.instance.named('Auth');
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      // Simulate authentication flow
      authLogger
          .info('User login started', metadata: {'email': 'user@example.com'});
      await Future.delayed(const Duration(milliseconds: 10));

      authLogger.debug('Validating credentials');
      await Future.delayed(const Duration(milliseconds: 10));

      authLogger.info('User authenticated', tags: ['success']);
      await Future.delayed(const Duration(milliseconds: 10));

      authLogger.info('Session created', metadata: {'sessionId': 'abc123'});

      expect(logged.length, equals(4));
      expect(logged.every((e) => e.loggerName == 'Auth'), isTrue);
    });

    test('should handle error tracking scenario', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      try {
        // Simulate an error
        throw Exception('Database connection failed');
      } catch (e, st) {
        log.error(
          'Failed to connect to database',
          error: e,
          stackTrace: st,
          tags: ['database', 'critical'],
          metadata: {
            'host': 'localhost',
            'port': 5432,
            'retryCount': 3,
          },
        );
      }

      expect(logged.length, equals(1));
      final entry = logged[0];

      expect(entry.level, equals(LogLevel.error));
      expect(entry.error, isNotNull);
      expect(entry.stackTrace, isNotNull);
      expect(entry.tags, contains('database'));
      expect(entry.metadata['host'], equals('localhost'));
    });

    test('should handle performance monitoring', () async {
      final perfLogger = LogR.instance.named('Performance');
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      final startTime = DateTime.now();

      // Simulate operation
      await Future.delayed(const Duration(milliseconds: 100));

      final duration = DateTime.now().difference(startTime);

      perfLogger.info(
        'Operation completed',
        tags: ['performance'],
        metadata: {
          'operation': 'dataFetch',
          'duration_ms': duration.inMilliseconds,
        },
      );

      expect(logged.length, equals(1));
      expect(logged[0].metadata['operation'], equals('dataFetch'));
      expect(logged[0].metadata['duration_ms'], greaterThan(0));
    });
  });
}

// Helper classes
class _MessageFilter implements LogFilter {
  final String keyword;

  _MessageFilter(this.keyword);

  @override
  bool shouldLog(LogEntry entry) {
    return entry.message.toLowerCase().contains(keyword.toLowerCase());
  }
}
