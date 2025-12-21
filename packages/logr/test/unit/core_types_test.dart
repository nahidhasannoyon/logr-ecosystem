import 'package:logr/logr.dart';
import 'package:test/test.dart';

void main() {
  group('LogLevel', () {
    test('should have correct values', () {
      expect(LogLevel.trace.value, equals(0));
      expect(LogLevel.debug.value, equals(1));
      expect(LogLevel.info.value, equals(2));
      expect(LogLevel.warning.value, equals(3));
      expect(LogLevel.error.value, equals(4));
      expect(LogLevel.fatal.value, equals(5));
    });

    test('should compare correctly', () {
      expect(LogLevel.error >= LogLevel.warning, isTrue);
      expect(LogLevel.debug >= LogLevel.trace, isTrue);
      expect(LogLevel.info <= LogLevel.error, isTrue);
      expect(LogLevel.trace < LogLevel.debug, isTrue);
      expect(LogLevel.fatal > LogLevel.error, isTrue);
    });

    test('should have correct string representation', () {
      expect(LogLevel.trace.toString(), equals('TRACE'));
      expect(LogLevel.debug.toString(), equals('DEBUG'));
      expect(LogLevel.info.toString(), equals('INFO'));
      expect(LogLevel.warning.toString(), equals('WARNING'));
      expect(LogLevel.error.toString(), equals('ERROR'));
      expect(LogLevel.fatal.toString(), equals('FATAL'));
    });
  });

  group('LogEntry', () {
    test('should create immutable log entry', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
      );

      expect(entry.level, equals(LogLevel.info));
      expect(entry.message, equals('Test message'));
      expect(entry.id, isNotEmpty);
      expect(entry.timestamp, isNotNull);
    });

    test('should generate unique IDs', () {
      final entry1 = LogEntry(level: LogLevel.info, message: 'Message 1');
      final entry2 = LogEntry(level: LogLevel.info, message: 'Message 2');

      expect(entry1.id, isNot(equals(entry2.id)));
    });

    test('should create entry with all optional fields', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final tags = ['tag1', 'tag2'];
      final metadata = {'key': 'value'};

      final entry = LogEntry(
        level: LogLevel.error,
        message: 'Error message',
        loggerName: 'TestLogger',
        error: error,
        stackTrace: stackTrace,
        tags: tags,
        metadata: metadata,
      );

      expect(entry.loggerName, equals('TestLogger'));
      expect(entry.error, equals(error));
      expect(entry.stackTrace, equals(stackTrace));
      expect(entry.tags, equals(tags));
      expect(entry.metadata, equals(metadata));
    });

    test('should create immutable collections', () {
      final tags = ['tag1'];
      final metadata = {'key': 'value'};

      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test',
        tags: tags,
        metadata: metadata,
      );

      // Should not be able to modify original lists
      tags.add('tag2');
      metadata['key2'] = 'value2';

      expect(entry.tags.length, equals(1));
      expect(entry.metadata.length, equals(1));
    });

    test('should support copyWith', () {
      final entry1 = LogEntry(
        level: LogLevel.info,
        message: 'Original',
      );

      final entry2 = entry1.copyWith(
        message: 'Modified',
        level: LogLevel.error,
      );

      expect(entry2.message, equals('Modified'));
      expect(entry2.level, equals(LogLevel.error));
      expect(entry2.id, equals(entry1.id));
      expect(entry2.timestamp, equals(entry1.timestamp));
    });

    test('should have proper string representation', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
        loggerName: 'TestLogger',
      );

      final str = entry.toString();
      expect(str, contains('INFO'));
      expect(str, contains('Test message'));
      expect(str, contains('TestLogger'));
    });
  });

  group('LoggerConfig', () {
    test('should create default config', () {
      const config = LoggerConfig();

      expect(config.minimumLevel, equals(LogLevel.debug));
      expect(config.maxBufferSize, equals(1000));
      expect(config.enableInRelease, isFalse);
      expect(config.includeStackTraceForErrors, isTrue);
    });

    test('should provide development config', () {
      const config = LoggerConfig.development;

      expect(config.minimumLevel, equals(LogLevel.trace));
      expect(config.maxBufferSize, equals(1000));
    });

    test('should provide production config', () {
      const config = LoggerConfig.production;

      expect(config.minimumLevel, equals(LogLevel.warning));
      expect(config.maxBufferSize, equals(100));
    });

    test('should support copyWith', () {
      const config1 = LoggerConfig();
      final config2 = config1.copyWith(
        minimumLevel: LogLevel.error,
        maxBufferSize: 500,
      );

      expect(config2.minimumLevel, equals(LogLevel.error));
      expect(config2.maxBufferSize, equals(500));
      expect(config2.enableInRelease, equals(config1.enableInRelease));
    });
  });
}
