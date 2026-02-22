import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';

import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final group = args['group'] as GroupEntity;
      
      final appUserState = context.read<AppUserCubit>().state;
      String? currentUserId;
      if (appUserState is AppUserLoggedIn) {
        currentUserId = appUserState.user.id;
      }
      
      context.read<ExpenseBloc>().add(ExpenseInitialized(group, currentUserId: currentUserId));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.openSans(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          "Add expense",
          style: GoogleFonts.openSans(color: AppColors.textBlack, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              if (state.status == ExpenseStatus.loading) {
                 return const Padding(
                   padding: EdgeInsets.only(right: 16.0),
                   child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal))),
                 );
              }
              return TextButton(
                onPressed: () {
                  if (state.group?.id != null) {
                    if(state.description.isEmpty){
                      AppAlerts.showError(context, "please enter description");
                      return;
                    }else if(state.amount.isEmpty){
                      AppAlerts.showError(context, "please enter amount");
                      return;
                    }
                    context.read<ExpenseBloc>().add(AddExpenseSubmitted(groupId: state.group!.id!));
                  }
                },
                child: Text(
                  "Save",
                  style: GoogleFonts.openSans(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state.status == ExpenseStatus.success) {
            AppAlerts.showSuccess(context, 'Expense added successfully!');
            Navigator.pop(context, true); // true → signals GroupDetailPage to refresh
          } else if (state.status == ExpenseStatus.failure) {
            AppAlerts.showError(context, state.errorMessage ?? 'Failed to add expense');

          }
        },
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state.status == ExpenseStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final group = state.group;
            if (group == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final members = group.members?.cast<GroupMemberEntity>() ?? <GroupMemberEntity>[];
            final payerName = state.payerId != null
                ? members
                      .firstWhere(
                        (m) => m.userId == state.payerId,
                        orElse: () => GroupMemberEntity(memberId: '', userId: '', fullName: 'Unknown', email: '', role: '', joinedAt: '', avtar: ''),
                      )
                      .fullName
                : "you"; // Default to current user (assuming 'you' logic later)
  
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Group Info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: group.groupIcon != null
                                ? DecorationImage(image: CachedNetworkImageProvider(group.groupIcon!), fit: BoxFit.cover)
                                : null,
                            color: group.groupIcon == null ? AppColors.primaryTeal : null,
                          ),
                          child: group.groupIcon == null ? const Icon(Icons.group, color: Colors.white, size: 14) : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "With you and: ${group.name ?? "Group"}",
                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderGrey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long_outlined, color: AppColors.textGrey, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Enter a description",
                              hintStyle: GoogleFonts.openSans(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w500),
                            onChanged: (value) => context.read<ExpenseBloc>().add(DescriptionChanged(value)),
                          ),
                        ),
                      ],
                    ),
                  ),
  
                  const SizedBox(height: 16),
  
                  // Amount Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent, // Placeholder to align
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.currency_rupee, color: AppColors.textBlack, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: "0.00",
                              hintStyle: GoogleFonts.openSans(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.openSans(fontSize: 32, fontWeight: FontWeight.bold),
                            onChanged: (value) => context.read<ExpenseBloc>().add(AmountChanged(value)),
                          ),
                        ),
                      ],
                    ),
                  ),
  
                  const SizedBox(height: 24),
  
                  // Paid by section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Text("Paid by", style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final result = await NavigationService.pushNamed(
                              AppRoutes.payerSelection,
                              args: {
                                 'group': state.group,
                                 'currentPayerId': state.payerId,
                              }
                            );
                            if (result != null && result is String) {
                               if(context.mounted) {
                                 context.read<ExpenseBloc>().add(PayerChanged(result));
                               }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderGrey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(payerName ?? "Unknown", style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("and split", style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final result = await NavigationService.pushNamed(
                              AppRoutes.splitOptions,
                              args: {
                                'members': members,
                                'splitType': state.splitType,
                                'splits': state.splits,
                                'totalAmount': double.tryParse(state.amount) ?? 0.0,
                              }
                            );
                            if (result != null && result is Map<String, dynamic>) {
                              if (context.mounted) {
                                context.read<ExpenseBloc>().add(SplitTypeChanged(result['splitType']));
                                context.read<ExpenseBloc>().add(SplitOptionChanged(result['splits']));
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderGrey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              state.splitType == SplitType.equal
                                  ? (state.splits.length == members.length ? "equally" : "equally (${state.splits.length})")
                                  : "unequally",
                              style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
  
                  const SizedBox(height: 24),
  
                  // Date Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onTap: () async {
                        final result = await NavigationService.pushNamed(
                          AppRoutes.dateSelection,
                          args: {
                            'initialDate': state.date
                          },
                        );
                        if (result != null && result is DateTime) {
                          if (context.mounted) {
                             context.read<ExpenseBloc>().add(DateChanged(result));
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: AppColors.textGrey),
                          const SizedBox(width: 8),
                          BlocBuilder<ExpenseBloc, ExpenseState>(
                            builder: (context, s) {
                              return Text(
                                s.date != null
                                    ? DateFormat('MMMM d, yyyy').format(s.date!)
                                    : "Today", // Or DateFormat('MMMM d, yyyy').format(DateTime.now())
                                style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 40),
  
                  // Add Note / Camera buttons (Optional, can be added later)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
