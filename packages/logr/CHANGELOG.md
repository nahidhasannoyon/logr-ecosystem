# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-21

### Added - Phase 1: Core Foundation (MVP)

#### Core Types

- `LogLevel` enum with 6 severity levels (trace, debug, info, warning, error, fatal)
- `LogEntry` immutable data model with id, timestamp, level, message, error, stackTrace, tags, and metadata
- `Logger` interface for logging implementations
- `LoggerConfig` configuration class with development and production presets

#### Logging System

- `LogR` singleton class with global initialization
- Named/scoped loggers via `LogR.instance.named(name)`
- Global `log` variable for quick access
- Multi-level logging methods (trace, debug, info, warning, error, fatal)
- Automatic stack trace capture for error and fatal levels
- Configurable minimum log level filtering

#### Outputs

- `LogOutput` interface for pluggable output destinations
- `ConsoleOutput` with automatic ANSI color detection and support
- Colored console output with configurable timestamp and logger name display

#### Buffering

- `RingBuffer` circular in-memory buffer with configurable maximum size
- Buffer management methods: `getBufferedLogs()`, `getRecentLogs()`, `clearBuffer()`
- Automatic old entry removal when buffer is full

#### Stream API

- Broadcast `Stream<LogEntry>` for reactive log monitoring
- Real-time log streaming to multiple subscribers

#### Listener Hooks

- Synchronous callback registration via `addListener()`
- Multiple listener support
- Error isolation to prevent listener failures from affecting logging

#### Filtering

- `LogFilter` interface for custom filtering logic
- `LevelFilter` for minimum severity level filtering
- `NameFilter` for logger name pattern matching (with regex support)
- `CompositeFilter` for combining multiple filters with AND logic

#### Production Support

- Release mode control via `enableInRelease` configuration
- Manual enable/disable via `setEnabled()`
- Automatic detection of release builds
- Zero-overhead when disabled

#### Error Handling

- Safe logging with try/catch wrappers
- Graceful handling of output and listener errors
- No application crashes from logging failures

#### Documentation

- Comprehensive API documentation with examples
- Detailed README with quick start guide
- Complete example demonstrating all features
- 78 unit and integration tests with 100% success rate

### Technical Details

- Pure Dart implementation (no Flutter dependencies)
- Zero external dependencies (except dev dependencies)
- Thread-safe immutable data structures
- Backwards-compatible API design
- Full test coverage with unit and integration tests

### Breaking Changes

None - Initial release

- Initial project setup

## [0.1.0] - 2024-01-15

### Added

- Initial release
- Core logging types
- Basic console output
