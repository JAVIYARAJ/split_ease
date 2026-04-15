import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';

import '../../../../core/usecases/use_case.dart';

class SubmitAppFeedbackUseCase implements UseCase<bool, SubmitAppFeedbackParams> {
  final AccountRepository repository;

  SubmitAppFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SubmitAppFeedbackParams params) async {
    return await repository.submitAppFeedback(params.rating, params.description);
  }
}

class SubmitAppFeedbackParams {
  final int rating;
  final String description;

  SubmitAppFeedbackParams({required this.rating, required this.description});
}
