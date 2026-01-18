import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/auth/domain/repositories/auth_repository.dart';

class UserLogin implements UseCase<UserEntity, UserLoginParam> {
  final AuthRepository authRepository;

  UserLogin({required this.authRepository});

  @override
  Future<Either<Failure, UserEntity>> call(UserLoginParam params) async {
    return await authRepository.loginWithEmailPassword(email: params.email, password: params.password);
  }
}

class UserLoginParam {
  final String email;
  final String password;

  UserLoginParam({required this.email, required this.password});
}
