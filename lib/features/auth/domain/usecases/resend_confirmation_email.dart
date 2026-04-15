import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/usecases/use_case.dart';

class ResendConfirmationEmail implements UseCase<void, String> {
  final AuthRepository authRepository;

  ResendConfirmationEmail(this.authRepository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await authRepository.resendConfirmationEmail(email: email);
  }
}
