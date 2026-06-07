import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoin_focus_app/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:todoin_focus_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:todoin_focus_app/features/settings/domain/entities/app_settings.dart';

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

void main() {
  late MockSettingsLocalDataSource mockDataSource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(localDataSource: mockDataSource);
  });

  test('getSettings returns AppSettings from datasource', () async {
    when(() => mockDataSource.getSoundEnabled()).thenAnswer((_) async => false);
    when(() => mockDataSource.getHapticEnabled()).thenAnswer((_) async => true);
    when(() => mockDataSource.getBadDayMode()).thenAnswer((_) async => false);

    final result = await repository.getSettings();

    expect(
      result,
      const AppSettings(soundEnabled: false, hapticEnabled: true, badDayMode: false),
    );
  });

  test('saveSoundEnabled delegates to datasource', () async {
    when(() => mockDataSource.setSoundEnabled(any())).thenAnswer((_) async => {});

    await repository.saveSoundEnabled(false);

    verify(() => mockDataSource.setSoundEnabled(false)).called(1);
  });

  test('saveHapticEnabled delegates to datasource', () async {
    when(() => mockDataSource.setHapticEnabled(any())).thenAnswer((_) async => {});

    await repository.saveHapticEnabled(true);

    verify(() => mockDataSource.setHapticEnabled(true)).called(1);
  });
}
