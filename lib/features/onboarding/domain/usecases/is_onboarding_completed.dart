import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

class IsOnboardingCompleted implements UseCase<bool, NoParams> {
  final OnboardingRepository repository;

  IsOnboardingCompleted(this.repository);

  @override
  Future<bool> call(NoParams params) => repository.isCompleted();
}
