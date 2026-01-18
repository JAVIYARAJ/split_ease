import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/splash/domain/repository/splash_repository.dart';

class UserActiveSession implements UseCase<bool, NoParams> {
  final SplashRepository splashRepository;

  UserActiveSession(this.splashRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return splashRepository.isUserActiveSession();
  }
}
