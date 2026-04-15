
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> updateProfile({String? name, File? image}) async {
    try {
      final user = await _remoteDataSource.updateProfile(name: name, image: image);
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
