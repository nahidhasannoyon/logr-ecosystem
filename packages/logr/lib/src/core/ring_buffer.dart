import 'dart:collection';

import '../core/log_entry.dart';

/// A circular buffer for storing recent log entries in memory.
/// 
/// Maintains a fixed-size buffer that automatically discards the oldest
/// entries when the maximum size is reached.
class RingBuffer {
  /// Maximum number of entries to store.
  final int maxSize;

  /// Internal queue for storing log entries.
  final Queue<LogEntry> _buffer;

  /// Creates a ring buffer with the specified maximum size.
  /// 
  /// - [maxSize]: Maximum number of entries (must be positive)
  RingBuffer(this.maxSize)
      : assert(maxSize > 0, 'maxSize must be positive'),
        _buffer = Queue<LogEntry>();

  /// Adds a log entry to the buffer.
  /// 
  /// If the buffer is full, removes the oldest entry first.
  void add(LogEntry entry) {
    if (_buffer.length >= maxSize) {
      _buffer.removeFirst();
    }
    _buffer.addLast(entry);
  }

  /// Returns all entries in the buffer in chronological order.
  List<LogEntry> getAll() {
    return List.unmodifiable(_buffer);
  }

  /// Returns the most recent [count] entries.
  /// 
  /// If [count] exceeds the buffer size, returns all available entries.
  List<LogEntry> getRecent(int count) {
    final takeCount = count.clamp(0, _buffer.length);
    return List.unmodifiable(_buffer.skip(_buffer.length - takeCount));
  }

  /// Returns entries that match the given predicate.
  List<LogEntry> where(bool Function(LogEntry) test) {
    return List.unmodifiable(_buffer.where(test));
  }

  /// Clears all entries from the buffer.
  void clear() {
    _buffer.clear();
  }

  /// Returns the current number of entries in the buffer.
  int get length => _buffer.length;

  /// Returns true if the buffer is empty.
  bool get isEmpty => _buffer.isEmpty;

  /// Returns true if the buffer is at maximum capacity.
  bool get isFull => _buffer.length >= maxSize;
}
