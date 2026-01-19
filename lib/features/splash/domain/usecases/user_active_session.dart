import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/splash/domain/repository/splash_repository.dart';

class UserActiveSession implements UseCase<UserEntity, NoParams> {
  final SplashRepository splashRepository;

  UserActiveSession(this.splashRepository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return splashRepository.isUserActiveSession();
  }
}
