import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';

import '../../domain/repository/group_repository.dart';
import '../datasources/group_remote_data_source.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource dataSource;

  GroupRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, String>> insertGroupIcon(File file) async {
    try {
      var response = await dataSource.insertGroupImage(file);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, dynamic>> createGroup(String name, String type, String? icon, String inviteCode) async{
    try{
      var response = await dataSource.createGroup(name, type, icon, inviteCode);
      return right(response);
    } on ServerException catch(error){
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getAllGroups() async{
    try{
      var response = await dataSource.getAllGroups();
      return right(response);
    } on ServerException catch(error){
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroupDetail(String id) async{
    try{
      var response = await dataSource.getGroupDetail(id);
      return right(response);
    } on ServerException catch(error){
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, bool>> joinGroup(String code) async {
     try{
      var response = await dataSource.joinGroup(code);
      return right(response);
    } on ServerException catch(error){
      return left(Failure(message: error.message));
    }
  }


  @override
  Future<Either<Failure, bool>> checkInviteCode(String code) async {
    try {
      var response = await dataSource.checkInviteCode(code);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }
  @override
  Future<Either<Failure, bool>> leaveGroup(String groupId) async {
    try {
      var response = await dataSource.leaveGroup(groupId);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteGroup(String groupId) async {
    try {
      var response = await dataSource.deleteGroup(groupId);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }
}
