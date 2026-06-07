import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/core/analytics/analytics_properties.dart';

void main() {
  test('sanitizeAnalyticsProperties removes null values', () {
    final result = sanitizeAnalyticsProperties({
      'screen': 'home',
      'count': 3,
      'optional': null,
    });

    expect(result, {'screen': 'home', 'count': 3});
  });

  test('sanitizeAnalyticsProperties keeps bool and int', () {
    final result = sanitizeAnalyticsProperties({
      'posthog_enabled': true,
      'seconds': 120,
    });

    expect(result['posthog_enabled'], isTrue);
    expect(result['seconds'], 120);
  });
}
