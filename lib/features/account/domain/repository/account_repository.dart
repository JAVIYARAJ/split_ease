
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';

abstract interface class AccountRepository {
  Future<Either<Failure, dynamic>> logout();
  Future<Either<Failure, bool>> submitAppFeedback(int rating, String description);
}
