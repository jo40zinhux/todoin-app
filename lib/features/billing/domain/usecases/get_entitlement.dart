import '../../../../core/usecases/usecase.dart';
import '../entities/entitlement.dart';
import '../repositories/entitlement_repository.dart';

class GetEntitlement implements UseCase<Entitlement, NoParams> {
  final EntitlementRepository repository;

  GetEntitlement(this.repository);

  @override
  Future<Entitlement> call(NoParams params) => repository.getEntitlement();
}
