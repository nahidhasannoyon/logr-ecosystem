import '../core/log_entry.dart';
import '../core/log_level.dart';

/// Interface for filtering log entries.
/// 
/// Filters determine whether a log entry should be processed and output.
abstract class LogFilter {
  /// Returns true if the log entry should be processed.
  bool shouldLog(LogEntry entry);
}

/// Filters logs based on minimum severity level.
class LevelFilter implements LogFilter {
  /// Minimum level required for a log to pass.
  final LogLevel minimumLevel;

  /// Creates a level-based filter.
  const LevelFilter(this.minimumLevel);

  @override
  bool shouldLog(LogEntry entry) {
    return entry.level >= minimumLevel;
  }
}

/// Filters logs based on logger name pattern.
class NameFilter implements LogFilter {
  /// Pattern to match against logger names.
  final Pattern pattern;

  /// Whether to include or exclude matching names.
  final bool include;

  /// Creates a name-based filter.
  const NameFilter(this.pattern, {this.include = true});

  @override
  bool shouldLog(LogEntry entry) {
    if (entry.loggerName == null) return !include;

    final matches = pattern.allMatches(entry.loggerName!).isNotEmpty;
    return include ? matches : !matches;
  }
}

/// Combines multiple filters with AND logic.
class CompositeFilter implements LogFilter {
  /// List of filters to apply.
  final List<LogFilter> filters;

  /// Creates a composite filter that requires all filters to pass.
  const CompositeFilter(this.filters);

  @override
  bool shouldLog(LogEntry entry) {
    return filters.every((filter) => filter.shouldLog(entry));
  }
}
