import 'package:flutter_test/flutter_test.dart';
import 'package:todoin_focus_app/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:todoin_focus_app/features/sync/domain/entities/sync_auth_session.dart';

void main() {
  final expiredSession = SyncAuthSession(
    accessToken: 'token',
    userId: 'user-1',
    refreshToken: 'refresh',
    expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  final dataSource = SyncRemoteDataSource();

  test('upsert throws when session is expired', () {
    expect(
      () => dataSource.upsert(
        deviceId: 'device-1',
        payload: const {'version': 1},
        updatedAt: DateTime.now(),
        session: expiredSession,
      ),
      throwsA(isA<SyncRemoteException>()),
    );
  });

  test('fetch throws when session is expired', () {
    expect(
      () => dataSource.fetch(
        deviceId: 'device-1',
        session: expiredSession,
      ),
      throwsA(isA<SyncRemoteException>()),
    );
  });
}
