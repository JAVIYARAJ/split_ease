import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';

class AccountLogout implements UseCase<dynamic, NoParams> {
  final AccountRepository accountRepository;

  AccountLogout(this.accountRepository);

  @override
  Future<Either<Failure, dynamic>> call(NoParams params) async {
    return await accountRepository.logout();
  }
}


