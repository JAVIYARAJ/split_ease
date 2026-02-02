
import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    File? image, // Changed to File
  });
}
