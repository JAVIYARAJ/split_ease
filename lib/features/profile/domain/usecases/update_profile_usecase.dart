
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final ProfileRepository _profileRepository;

  UpdateProfileUseCase(this._profileRepository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    return await _profileRepository.updateProfile(
      name: params.name,
      image: params.image,
    );
  }
}

class UpdateProfileParams {
  final String? name;
  final File? image;

  UpdateProfileParams({
    this.name,
    this.image,
  });
}
