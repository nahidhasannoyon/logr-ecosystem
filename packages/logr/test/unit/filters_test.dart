import 'package:logr/logr.dart';
import 'package:test/test.dart';

void main() {
  group('LevelFilter', () {
    test('should filter logs below minimum level', () {
      final filter = LevelFilter(LogLevel.warning);

      final traceEntry = LogEntry(level: LogLevel.trace, message: 'Trace');
      final debugEntry = LogEntry(level: LogLevel.debug, message: 'Debug');
      final infoEntry = LogEntry(level: LogLevel.info, message: 'Info');
      final warningEntry =
          LogEntry(level: LogLevel.warning, message: 'Warning');
      final errorEntry = LogEntry(level: LogLevel.error, message: 'Error');
      final fatalEntry = LogEntry(level: LogLevel.fatal, message: 'Fatal');

      expect(filter.shouldLog(traceEntry), isFalse);
      expect(filter.shouldLog(debugEntry), isFalse);
      expect(filter.shouldLog(infoEntry), isFalse);
      expect(filter.shouldLog(warningEntry), isTrue);
      expect(filter.shouldLog(errorEntry), isTrue);
      expect(filter.shouldLog(fatalEntry), isTrue);
    });

    test('should allow all logs with trace level', () {
      final filter = LevelFilter(LogLevel.trace);

      final traceEntry = LogEntry(level: LogLevel.trace, message: 'Trace');
      final debugEntry = LogEntry(level: LogLevel.debug, message: 'Debug');
      final fatalEntry = LogEntry(level: LogLevel.fatal, message: 'Fatal');

      expect(filter.shouldLog(traceEntry), isTrue);
      expect(filter.shouldLog(debugEntry), isTrue);
      expect(filter.shouldLog(fatalEntry), isTrue);
    });
  });

  group('NameFilter', () {
    test('should filter by exact name match', () {
      final filter = NameFilter('Auth', include: true);

      final authEntry = LogEntry(
        level: LogLevel.info,
        message: 'Message',
        loggerName: 'Auth',
      );
      final otherEntry = LogEntry(
        level: LogLevel.info,
        message: 'Message',
        loggerName: 'Database',
      );

      expect(filter.shouldLog(authEntry), isTrue);
      expect(filter.shouldLog(otherEntry), isFalse);
    });

    test('should support regex patterns', () {
      final filter = NameFilter(RegExp(r'^Auth'), include: true);

      final auth1 = LogEntry(
        level: LogLevel.info,
        message: 'Message',
        loggerName: 'Auth',
      );
      final auth2 = LogEntry(
        level: LogLevel.info,
        message: 'Message',
        loggerName: 'AuthService',
      );
      final other = LogEntry(
        level: LogLevel.info,
        message: 'Message',
        loggerName: 'Database',
      );

      expect(filter.shouldLog(auth1), isTrue);
      expect(filter.shouldLog(auth2), isTrue);
      expect(filter.shouldLog(other), isFalse);
    });

    test('should support exclusion mode', () {
      final filter = NameFilter('Debug', include: false);

      final debugEntry = LogEntry(
        level: LogLevel.info,
        message: 'Message',
        loggerName: 'Debug',
      );
      final otherEntry = LogEntry(
        level: LogLevel.info,
        message: 'Message',
        loggerName: 'Auth',
      );

      expect(filter.shouldLog(debugEntry), isFalse);
      expect(filter.shouldLog(otherEntry), isTrue);
    });

    test('should handle entries without logger name', () {
      final filter = NameFilter('Auth', include: true);

      final entryWithoutName = LogEntry(
        level: LogLevel.info,
        message: 'Message',
      );

      expect(filter.shouldLog(entryWithoutName), isFalse);
    });
  });

  group('CompositeFilter', () {
    test('should require all filters to pass', () {
      final levelFilter = LevelFilter(LogLevel.warning);
      final nameFilter = NameFilter('Auth', include: true);
      final composite = CompositeFilter([levelFilter, nameFilter]);

      final validEntry = LogEntry(
        level: LogLevel.error,
        message: 'Error',
        loggerName: 'Auth',
      );
      final wrongLevel = LogEntry(
        level: LogLevel.debug,
        message: 'Debug',
        loggerName: 'Auth',
      );
      final wrongName = LogEntry(
        level: LogLevel.error,
        message: 'Error',
        loggerName: 'Database',
      );

      expect(composite.shouldLog(validEntry), isTrue);
      expect(composite.shouldLog(wrongLevel), isFalse);
      expect(composite.shouldLog(wrongName), isFalse);
    });

    test('should work with empty filter list', () {
      final composite = CompositeFilter([]);

      final entry = LogEntry(level: LogLevel.info, message: 'Test');

      expect(composite.shouldLog(entry), isTrue);
    });
  });
}
