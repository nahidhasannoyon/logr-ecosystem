import 'package:logr/logr.dart';
import 'package:test/test.dart';

void main() {
  test('LogLevel tests are in core_types_test.dart', () {
    // Tests moved to core_types_test.dart for better organization
    expect(LogLevel.trace.value, equals(0));
  });
}
