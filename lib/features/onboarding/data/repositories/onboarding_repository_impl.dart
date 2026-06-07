import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource dataSource;

  OnboardingRepositoryImpl(this.dataSource);

  @override
  Future<bool> isCompleted() => dataSource.isCompleted();

  @override
  Future<void> markCompleted() => dataSource.markCompleted();
}
