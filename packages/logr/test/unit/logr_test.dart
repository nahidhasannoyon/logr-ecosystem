import 'dart:async';

import 'package:logr/logr.dart';
import 'package:test/test.dart';

void main() {
  // Reset LogR before each test
  setUp(() {
    // Initialize with fresh instance for each test
    LogR.init(
      config: const LoggerConfig(
        minimumLevel: LogLevel.trace,
        maxBufferSize: 100,
        enableInRelease: true,
      ),
    );
  });

  group('LogR Initialization', () {
    test('should initialize with defaults', () {
      LogR.init();
      final instance = LogR.instance;

      expect(instance, isNotNull);
      expect(instance.config, isNotNull);
    });

    test('should initialize with custom config', () {
      LogR.init(
        config: const LoggerConfig(
          minimumLevel: LogLevel.error,
          maxBufferSize: 500,
        ),
      );

      final instance = LogR.instance;
      expect(instance.config.minimumLevel, equals(LogLevel.error));
      expect(instance.config.maxBufferSize, equals(500));
    });

    test('should auto-initialize on first access', () {
      // Don't call init
      final instance = LogR.instance;
      expect(instance, isNotNull);
    });
  });

  group('LogR Logging Methods', () {
    test('should log at all levels', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      LogR.instance.trace('Trace message');
      LogR.instance.debug('Debug message');
      LogR.instance.info('Info message');
      LogR.instance.warning('Warning message');
      LogR.instance.error('Error message');
      LogR.instance.fatal('Fatal message');

      expect(logged.length, equals(6));
      expect(logged[0].level, equals(LogLevel.trace));
      expect(logged[1].level, equals(LogLevel.debug));
      expect(logged[2].level, equals(LogLevel.info));
      expect(logged[3].level, equals(LogLevel.warning));
      expect(logged[4].level, equals(LogLevel.error));
      expect(logged[5].level, equals(LogLevel.fatal));
    });

    test('should respect minimum level filtering', () {
      LogR.init(
        config: const LoggerConfig(
          minimumLevel: LogLevel.warning,
          enableInRelease: true,
        ),
      );

      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      LogR.instance.trace('Trace');
      LogR.instance.debug('Debug');
      LogR.instance.info('Info');
      LogR.instance.warning('Warning');
      LogR.instance.error('Error');

      expect(logged.length, equals(2));
      expect(logged[0].level, equals(LogLevel.warning));
      expect(logged[1].level, equals(LogLevel.error));
    });

    test('should include error and stack trace', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      LogR.instance
          .error('Error occurred', error: error, stackTrace: stackTrace);

      expect(logged.length, equals(1));
      expect(logged[0].error, equals(error));
      expect(logged[0].stackTrace, equals(stackTrace));
    });

    test('should include tags and metadata', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      LogR.instance.info(
        'Message',
        tags: ['tag1', 'tag2'],
        metadata: {'key': 'value'},
      );

      expect(logged.length, equals(1));
      expect(logged[0].tags, equals(['tag1', 'tag2']));
      expect(logged[0].metadata, equals({'key': 'value'}));
    });

    test('should auto-capture stack trace for errors', () {
      LogR.init(
        config: const LoggerConfig(
          includeStackTraceForErrors: true,
          enableInRelease: true,
        ),
      );

      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      LogR.instance.error('Error without explicit stack trace');

      expect(logged.length, equals(1));
      expect(logged[0].stackTrace, isNotNull);
    });
  });

  group('LogR Named Loggers', () {
    test('should create named logger', () {
      final authLogger = LogR.instance.named('Auth');

      expect(authLogger, isNotNull);
      expect(authLogger.name, equals('Auth'));
    });

    test('should include logger name in entries', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      final authLogger = LogR.instance.named('Auth');
      authLogger.info('User logged in');

      expect(logged.length, equals(1));
      expect(logged[0].loggerName, equals('Auth'));
    });

    test('should support multiple named loggers', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      final authLogger = LogR.instance.named('Auth');
      final dbLogger = LogR.instance.named('Database');

      authLogger.info('Auth message');
      dbLogger.info('DB message');

      expect(logged.length, equals(2));
      expect(logged[0].loggerName, equals('Auth'));
      expect(logged[1].loggerName, equals('Database'));
    });
  });

  group('LogR Stream API', () {
    test('should emit logs to stream', () async {
      final streamLogs = <LogEntry>[];
      final subscription = LogR.instance.stream.listen(streamLogs.add);

      LogR.instance.info('Test message 1');
      LogR.instance.info('Test message 2');

      // Wait for stream to process
      await Future.delayed(const Duration(milliseconds: 10));

      expect(streamLogs.length, equals(2));
      expect(streamLogs[0].message, equals('Test message 1'));
      expect(streamLogs[1].message, equals('Test message 2'));

      await subscription.cancel();
    });

    test('should support multiple stream subscribers', () async {
      final logs1 = <LogEntry>[];
      final logs2 = <LogEntry>[];

      final sub1 = LogR.instance.stream.listen(logs1.add);
      final sub2 = LogR.instance.stream.listen(logs2.add);

      LogR.instance.info('Broadcast message');

      await Future.delayed(const Duration(milliseconds: 10));

      expect(logs1.length, equals(1));
      expect(logs2.length, equals(1));

      await sub1.cancel();
      await sub2.cancel();
    });
  });

  group('LogR Listener Hooks', () {
    test('should add and invoke listeners', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      LogR.instance.info('Test message');

      expect(logged.length, equals(1));
      expect(logged[0].message, equals('Test message'));
    });

    test('should support multiple listeners', () {
      final logs1 = <LogEntry>[];
      final logs2 = <LogEntry>[];

      LogR.instance.addListener(logs1.add);
      LogR.instance.addListener(logs2.add);

      LogR.instance.info('Test message');

      expect(logs1.length, equals(1));
      expect(logs2.length, equals(1));
    });

    test('should remove listener', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      LogR.instance.info('Message 1');
      LogR.instance.removeListener(logged.add);
      LogR.instance.info('Message 2');

      expect(logged.length, equals(1));
    });

    test('should clear all listeners', () {
      final logs1 = <LogEntry>[];
      final logs2 = <LogEntry>[];

      LogR.instance.addListener(logs1.add);
      LogR.instance.addListener(logs2.add);

      LogR.instance.info('Message 1');
      LogR.instance.clearListeners();
      LogR.instance.info('Message 2');

      expect(logs1.length, equals(1));
      expect(logs2.length, equals(1));
    });

    test('should handle listener errors gracefully', () {
      LogR.instance.addListener((entry) {
        throw Exception('Listener error');
      });

      // Should not throw
      expect(() => LogR.instance.info('Test'), returnsNormally);
    });
  });

  group('LogR Buffer Management', () {
    test('should buffer log entries', () {
      LogR.instance.info('Message 1');
      LogR.instance.info('Message 2');
      LogR.instance.info('Message 3');

      final buffered = LogR.instance.getBufferedLogs();

      expect(buffered.length, equals(3));
      expect(buffered[0].message, equals('Message 1'));
      expect(buffered[1].message, equals('Message 2'));
      expect(buffered[2].message, equals('Message 3'));
    });

    test('should get recent logs', () {
      for (int i = 0; i < 10; i++) {
        LogR.instance.info('Message $i');
      }

      final recent = LogR.instance.getRecentLogs(3);

      expect(recent.length, equals(3));
      expect(recent[0].message, equals('Message 7'));
      expect(recent[1].message, equals('Message 8'));
      expect(recent[2].message, equals('Message 9'));
    });

    test('should clear buffer', () {
      LogR.instance.info('Message 1');
      LogR.instance.info('Message 2');

      LogR.instance.clearBuffer();

      expect(LogR.instance.getBufferedLogs(), isEmpty);
    });

    test('should handle buffer with size 0', () {
      LogR.init(
        config: const LoggerConfig(
          maxBufferSize: 0,
          enableInRelease: true,
        ),
      );

      LogR.instance.info('Message');

      expect(LogR.instance.getBufferedLogs(), isEmpty);
    });
  });

  group('LogR Enable/Disable', () {
    test('should enable and disable logging', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      LogR.instance.info('Message 1');
      LogR.instance.setEnabled(false);
      LogR.instance.info('Message 2');
      LogR.instance.setEnabled(true);
      LogR.instance.info('Message 3');

      expect(logged.length, equals(2));
      expect(logged[0].message, equals('Message 1'));
      expect(logged[1].message, equals('Message 3'));
    });

    test('should report enabled status', () {
      expect(LogR.instance.isEnabled, isTrue);

      LogR.instance.setEnabled(false);
      expect(LogR.instance.isEnabled, isFalse);

      LogR.instance.setEnabled(true);
      expect(LogR.instance.isEnabled, isTrue);
    });
  });

  group('LogR Output Management', () {
    test('should add custom output', () {
      final customLogs = <LogEntry>[];
      final customOutput = _TestOutput(customLogs.add);

      LogR.instance.addOutput(customOutput);
      LogR.instance.info('Test message');

      expect(customLogs.length, equals(1));
      expect(customLogs[0].message, equals('Test message'));
    });

    test('should remove output', () {
      final customLogs = <LogEntry>[];
      final customOutput = _TestOutput(customLogs.add);

      LogR.instance.addOutput(customOutput);
      LogR.instance.info('Message 1');
      LogR.instance.removeOutput(customOutput);
      LogR.instance.info('Message 2');

      expect(customLogs.length, equals(1));
    });

    test('should handle output errors gracefully', () {
      final errorOutput = _ErrorOutput();

      LogR.instance.addOutput(errorOutput);

      // Should not throw
      expect(() => LogR.instance.info('Test'), returnsNormally);
    });
  });

  group('LogR Filter Management', () {
    test('should add custom filter', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      // Add filter that only allows messages containing 'important'
      LogR.instance.addFilter(_TestFilter());

      LogR.instance.info('Regular message');
      LogR.instance.info('Important message');

      expect(logged.length, equals(1));
      expect(logged[0].message, equals('Important message'));
    });

    test('should remove filter', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      final filter = _TestFilter();
      LogR.instance.addFilter(filter);

      LogR.instance.info('Regular message 1');
      LogR.instance.removeFilter(filter);
      LogR.instance.info('Regular message 2');

      expect(logged.length, equals(1));
    });
  });

  group('LogR Global Access', () {
    test('should provide global log instance', () {
      expect(log, isNotNull);
      expect(log, equals(LogR.instance));
    });

    test('should work with global log variable', () {
      final logged = <LogEntry>[];
      LogR.instance.addListener(logged.add);

      log.info('Global log message');

      expect(logged.length, equals(1));
      expect(logged[0].message, equals('Global log message'));
    });
  });

  group('LogR Error Handling', () {
    test('should not throw on logging errors', () {
      // Should handle any internal errors gracefully
      expect(() => LogR.instance.info('Test message'), returnsNormally);
    });
  });
}

// Test helper classes
class _TestOutput implements LogOutput {
  final void Function(LogEntry) callback;

  _TestOutput(this.callback);

  @override
  void write(LogEntry entry) {
    callback(entry);
  }

  @override
  void close() {}
}

class _ErrorOutput implements LogOutput {
  @override
  void write(LogEntry entry) {
    throw Exception('Output error');
  }

  @override
  void close() {}
}

class _TestFilter implements LogFilter {
  @override
  bool shouldLog(LogEntry entry) {
    return entry.message.contains('Important');
  }
}
