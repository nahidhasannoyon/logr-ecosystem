import 'package:logr/logr.dart';
import 'package:test/test.dart';

void main() {
  test('Integration tests are in logr_complete_pipeline_test.dart', () {
    // Tests moved to logr_complete_pipeline_test.dart for better organization
    LogR.init();
    expect(LogR.instance, isNotNull);
  });
}
