import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';

class UploadProfilePicture implements UseCase<String, File> {
  final AccountRepository accountRepository;

  UploadProfilePicture({required this.accountRepository});

  @override
  Future<Either<Failure, String>> call(File params) async {
    return await accountRepository.uploadProfilePicture(params);
  }
}
