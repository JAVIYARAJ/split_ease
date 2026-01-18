import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failure.dart';

class UserSignUp implements UseCase<UserEntity, UserSignUpParam> {
  AuthRepository authRepository;

  UserSignUp({required this.authRepository});

  @override
  Future<Either<Failure, UserEntity>> call(UserSignUpParam params) async {
    return await authRepository.signUpWithEmailPassword(name: params.name, email: params.email, password: params.password);
  }
}

class UserSignUpParam {
  final String email;
  final String name;
  final String password;

  UserSignUpParam(this.email, this.name, this.password);
}
