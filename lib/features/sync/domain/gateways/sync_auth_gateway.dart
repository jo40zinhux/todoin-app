import '../entities/sync_auth_session.dart';

abstract class SyncAuthGateway {
  Future<SyncAuthSession?> ensureSession();
}
