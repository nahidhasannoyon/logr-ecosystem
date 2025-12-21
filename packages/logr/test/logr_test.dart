import 'package:logr/logr.dart';
import 'package:test/test.dart';

void main() {
  test('LogR basic functionality', () {
    LogR.init();
    expect(LogR.instance, isNotNull);

    // Test basic logging
    log.info('Test message');

    // Verify it was logged
    final buffered = LogR.instance.getBufferedLogs();
    expect(buffered.isNotEmpty, isTrue);
  });
}
