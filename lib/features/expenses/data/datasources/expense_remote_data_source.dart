import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/expense_media_entity.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
import 'package:split_ease/features/expenses/domain/usecases/update_expense_params.dart';
import 'package:split_ease/core/utils/error_message_utils.dart';

import '../../../../core/error/exception.dart';

import 'package:split_ease/features/expenses/data/models/expense_detail_model.dart';
import 'package:split_ease/features/expenses/data/models/expense_category_model.dart';
import 'package:split_ease/features/expenses/data/models/expense_metadata_model.dart';
import 'package:split_ease/features/expenses/data/models/personal_expenses_model.dart';
import 'package:split_ease/features/expenses/data/models/expense_media_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<String> createExpense(CreateExpenseParams params);
  Future<void> updateExpense(UpdateExpenseParams params);
  Future<ExpenseDetailModel> getExpenseDetail(String expenseId);
  Future<List<ExpenseCommentModel>> getExpenseComments(String expenseId);
  Future<void> deleteExpense(String expenseId);
  Future<void> restoreExpense(String expenseId);
  Future<List<ExpenseUserModel>> getExpenseParticipants({String? groupId, String? friendUserId});
  Future<void> addExpenseComment({required String expenseId, required String comment});
  Future<void> updateExpenseComment({required String commentId, required String comment});
  Future<void> deleteExpenseComment({required String commentId});
  Future<void> settleUp({
    required String toUserId,
    required double amount,
    String? groupId,
    String? note,
    String? paymentMethodId,
    DateTime? date,
  });
  Future<ExpenseMetadataModel> getExpenseMetadata();
  Future<PersonalExpensesModel> getPersonalExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? paymentMethodId,
  });
  Future<void> attachExpenseMedia(String expenseId, List<ExpenseMediaEntity> media);
  Future<void> deleteExpenseMedia(String mediaId);
}


class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient client;

  ExpenseRemoteDataSourceImpl({required this.client});

  @override
  Future<String> createExpense(CreateExpenseParams params) async {
    try {
      final response = await client.rpc(
        'create_expense_rpc',
        params: params.toJson(),
      );
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return response['expense_id'] as String;
        } else {
          throw ServerException(message: response['message'] as String? ?? 'Failed to create expense');
        }
      } else if (response is String) {
        return response;
      } else {
        throw ServerException(message: 'Invalid response format from server');
      }
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> updateExpense(UpdateExpenseParams params) async {
    try {
      final response = await client.rpc(
        'update_expense_rpc',
        params: params.toJson(),
      );
      
      if (response is Map<String, dynamic> && response['success'] == false) {
        throw ServerException(message: response['message'] as String? ?? 'Failed to update expense');
      }
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<ExpenseDetailModel> getExpenseDetail(String expenseId) async {
    try {
      final response = await client.rpc(
        'get_expense_detail_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );
      return ExpenseDetailModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<List<ExpenseCommentModel>> getExpenseComments(String expenseId) async {
    try {
      final response = await client.rpc(
        'get_expense_comments_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => ExpenseCommentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await client.rpc(
        'delete_expense_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
  
  @override
  Future<void> restoreExpense(String expenseId) async {
    try {
      await client.rpc(
        'restore_expense_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
  
  @override
  Future<List<ExpenseUserModel>> getExpenseParticipants({String? groupId, String? friendUserId}) async {
    try {
      final response = await client.rpc(
        'get_expense_participants_rpc',
        params: {
          'p_group_id': groupId,
          'p_friend_user_id': friendUserId,
        },
      );
      
      return (response as List)
          .map((e) => ExpenseUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> addExpenseComment({required String expenseId, required String comment}) async {
    try {
      await client.rpc(
        'add_expense_comment_rpc',
        params: {
          'p_expense_id': expenseId,
          'p_comment': comment,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> updateExpenseComment({required String commentId, required String comment}) async {
    try {
      await client.rpc(
        'update_expense_comment_rpc',
        params: {
          'p_comment_id': commentId,
          'p_comment': comment,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> deleteExpenseComment({required String commentId}) async {
    try {
      await client.rpc(
        'delete_expense_comment_rpc',
        params: {
          'p_comment_id': commentId,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> settleUp({
    required String toUserId,
    required double amount,
    String? groupId,
    String? note,
    String? paymentMethodId,
    DateTime? date,
  }) async {
    try {
      await client.rpc(
        'settle_up_rpc',
        params: {
          'p_to_user_id': toUserId,
          'p_amount': amount,
          'p_group_id': groupId,
          'p_payment_method_id': paymentMethodId,
          'p_expense_note': note,
          'p_expense_date':
              (date ?? DateTime.now()).toIso8601String().split('T').first,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<ExpenseMetadataModel> getExpenseMetadata() async {
    try {
      final response = await client.rpc('get_expense_metadata_rpc');
      return ExpenseMetadataModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<PersonalExpensesModel> getPersonalExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? paymentMethodId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['p_start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) params['p_end_date'] = endDate.toIso8601String().split('T')[0];
      if (categoryId != null) params['p_category_id'] = categoryId;
      if (paymentMethodId != null) params['p_payment_method_id'] = paymentMethodId;
      final response = await client.rpc(
        'get_personal_expense_rpc',
        params: params.isEmpty ? null : params,
      );
      return PersonalExpensesModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> attachExpenseMedia(String expenseId, List<ExpenseMediaEntity> media) async {
    try {
      final mediaJson = media.map((m) {
        if (m is ExpenseMediaModel) return m.toJson();
        return ExpenseMediaModel(
          id: m.id,
          url: m.url,
          publicId: m.publicId,
          mediaType: m.mediaType,
          fileName: m.fileName,
          mimeType: m.mimeType,
          fileSize: m.fileSize,
          width: m.width,
          height: m.height,
        ).toJson();
      }).toList();

      await client.rpc(
        'attach_expense_media_rpc',
        params: {
          'p_expense_id': expenseId,
          'p_media': mediaJson,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> deleteExpenseMedia(String mediaId) async {
    try {
      await client.rpc(
        'delete_expense_media_rpc',
        params: {
          'p_media_id': mediaId,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
}
