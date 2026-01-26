import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';

import '../repository/group_repository.dart';

class GroupInsertIcon implements UseCase<String, File> {
  final GroupRepository groupRepository;

  GroupInsertIcon({required this.groupRepository});

  @override
  Future<Either<Failure, String>> call(File params) async {
    return await groupRepository.insertGroupIcon(params);
  }
}
