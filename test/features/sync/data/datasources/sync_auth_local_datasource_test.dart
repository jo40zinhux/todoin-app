import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoin_focus_app/features/sync/data/datasources/sync_auth_local_datasource.dart';

void main() {
  test('returns null and clears key when session JSON is corrupt', () async {
    SharedPreferences.setMockInitialValues({
      'sync_auth_session': 'not-valid-json',
    });
    final prefs = await SharedPreferences.getInstance();
    final dataSource = SyncAuthLocalDataSource(prefs);

    final session = dataSource.load();

    expect(session, isNull);
    expect(prefs.getString('sync_auth_session'), isNull);
  });
}
