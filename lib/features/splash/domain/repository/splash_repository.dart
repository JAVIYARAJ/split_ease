import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';

abstract interface class SplashRepository {
  Future<Either<Failure,bool>> isUserActiveSession();
}
