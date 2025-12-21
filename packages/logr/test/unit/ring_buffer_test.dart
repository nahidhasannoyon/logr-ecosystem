import 'package:logr/logr.dart';
import 'package:logr/src/core/ring_buffer.dart';
import 'package:test/test.dart';

void main() {
  group('RingBuffer', () {
    test('should create buffer with specified size', () {
      final buffer = RingBuffer(5);
      expect(buffer.maxSize, equals(5));
      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, equals(0));
    });

    test('should add entries', () {
      final buffer = RingBuffer(5);
      final entry = LogEntry(level: LogLevel.info, message: 'Test');

      buffer.add(entry);

      expect(buffer.length, equals(1));
      expect(buffer.isEmpty, isFalse);
    });

    test('should remove oldest entry when full', () {
      final buffer = RingBuffer(3);
      final entry1 = LogEntry(level: LogLevel.info, message: 'Message 1');
      final entry2 = LogEntry(level: LogLevel.info, message: 'Message 2');
      final entry3 = LogEntry(level: LogLevel.info, message: 'Message 3');
      final entry4 = LogEntry(level: LogLevel.info, message: 'Message 4');

      buffer.add(entry1);
      buffer.add(entry2);
      buffer.add(entry3);
      expect(buffer.isFull, isTrue);

      buffer.add(entry4);

      final all = buffer.getAll();
      expect(all.length, equals(3));
      expect(all[0].message, equals('Message 2'));
      expect(all[1].message, equals('Message 3'));
      expect(all[2].message, equals('Message 4'));
    });

    test('should get all entries in order', () {
      final buffer = RingBuffer(5);
      final entry1 = LogEntry(level: LogLevel.info, message: 'First');
      final entry2 = LogEntry(level: LogLevel.info, message: 'Second');
      final entry3 = LogEntry(level: LogLevel.info, message: 'Third');

      buffer.add(entry1);
      buffer.add(entry2);
      buffer.add(entry3);

      final all = buffer.getAll();
      expect(all.length, equals(3));
      expect(all[0].message, equals('First'));
      expect(all[1].message, equals('Second'));
      expect(all[2].message, equals('Third'));
    });

    test('should get recent entries', () {
      final buffer = RingBuffer(5);
      for (int i = 0; i < 5; i++) {
        buffer.add(LogEntry(level: LogLevel.info, message: 'Message $i'));
      }

      final recent = buffer.getRecent(2);
      expect(recent.length, equals(2));
      expect(recent[0].message, equals('Message 3'));
      expect(recent[1].message, equals('Message 4'));
    });

    test('should handle getRecent with count larger than buffer', () {
      final buffer = RingBuffer(5);
      buffer.add(LogEntry(level: LogLevel.info, message: 'Test'));

      final recent = buffer.getRecent(10);
      expect(recent.length, equals(1));
    });

    test('should filter entries with where', () {
      final buffer = RingBuffer(5);
      buffer.add(LogEntry(level: LogLevel.info, message: 'Info 1'));
      buffer.add(LogEntry(level: LogLevel.error, message: 'Error 1'));
      buffer.add(LogEntry(level: LogLevel.info, message: 'Info 2'));
      buffer.add(LogEntry(level: LogLevel.error, message: 'Error 2'));

      final errors = buffer.where((entry) => entry.level == LogLevel.error);
      expect(errors.length, equals(2));
      expect(errors[0].message, equals('Error 1'));
      expect(errors[1].message, equals('Error 2'));
    });

    test('should clear buffer', () {
      final buffer = RingBuffer(5);
      buffer.add(LogEntry(level: LogLevel.info, message: 'Test 1'));
      buffer.add(LogEntry(level: LogLevel.info, message: 'Test 2'));

      expect(buffer.length, equals(2));

      buffer.clear();

      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, equals(0));
    });

    test('should return immutable lists', () {
      final buffer = RingBuffer(5);
      buffer.add(LogEntry(level: LogLevel.info, message: 'Test'));

      final all = buffer.getAll();

      expect(() => all.add(LogEntry(level: LogLevel.info, message: 'New')),
          throwsUnsupportedError);
    });
  });
}
