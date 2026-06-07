enum SyncResult { pushed, pulled, upToDate, skipped, failed }

abstract class SyncRepository {
  Future<bool> isEnabled();
  Future<void> setEnabled(bool value);
  Future<String> getDeviceId();
  Future<SyncResult> syncNow({required bool isPro});
}
