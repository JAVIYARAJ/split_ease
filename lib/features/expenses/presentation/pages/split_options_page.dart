import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/split/split_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

import '../../../../injection_container.dart';

class SplitOptionsPage extends StatelessWidget {
  const SplitOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final members = args['members'] as List<GroupMemberEntity>;
    final splitType = args['splitType'] as SplitType;
    final splits = args['splits'] as List<ExpenseSplit>;
    final totalAmount = args['totalAmount'] as double;

    return BlocProvider(
      create: (context) => sl<SplitBloc>()
        ..add(InitializeSplitEvent(
          members: members,
          initialSplitType: splitType,
          initialSplits: splits,
          totalAmount: totalAmount,
        )),
      child: const _SplitOptionsView(),
    );
  }
}

class _SplitOptionsView extends StatefulWidget {
  const _SplitOptionsView();

  @override
  State<_SplitOptionsView> createState() => _SplitOptionsViewState();
}

class _SplitOptionsViewState extends State<_SplitOptionsView> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateControllerValue(String userId, ExpenseSplit split, SplitType splitType) {
    if (!_controllers.containsKey(userId)) {
      _controllers[userId] = TextEditingController();
    }
    
    final controller = _controllers[userId]!;
    String newValue = '';
    
    if (splitType == SplitType.exact) {
      newValue = split.amount == 0 ? '' : split.amount.toStringAsFixed(2);
    } else if (splitType == SplitType.percentage) {
      newValue = split.percentage == 0 ? '' : split.percentage.toStringAsFixed(1);
    } else if (splitType == SplitType.shares) {
      newValue = split.shares.toStringAsFixed(0);
    }

    // Only update if the value is different to avoid cursor jumping
    if (controller.text != newValue) {
       // Check if the difference is just formatting (e.g. 1.0 vs 1) or user is typing
       // Ideally we'd only set text if it comes from external change (like tab switch), 
       // but here we are in a stateless-ish build. 
       // To prevent overwriting user input while typing, we should probably check focus.
       // However, since state is in Bloc now, we can just update when the state mismatch from text.
       // A simple check:
       final doubleVal = double.tryParse(controller.text) ?? 0.0;
       final newDoubleVal = double.tryParse(newValue) ?? 0.0;
       if ((doubleVal - newDoubleVal).abs() > 0.01) {
          controller.text = newValue;
       }
       if (controller.text.isEmpty && newValue.isNotEmpty) {
          controller.text = newValue;
       }
    }
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
          "Split options",
          style: GoogleFonts.openSans(color: AppColors.textBlack, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<SplitBloc, SplitState>(
            builder: (context, state) {
              return TextButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'splitType': state.splitType,
                    'splits': state.splits,
                  });
                },
                child: Text(
                  "Done",
                  style: GoogleFonts.openSans(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<SplitBloc, SplitState>(
        listener: (context, state) {
           // Sync controllers with state when type changes or initial load
           for (var split in state.splits) {
             _updateControllerValue(split.userId, split, state.splitType);
           }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(state),
              _buildTabs(context, state),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.borderGrey),
              Expanded(child: _buildMembersList(context, state)),
              _buildFooter(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(SplitState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: state.members.take(4).map((m) => _buildHeaderAvatar(m)).toList()
          ),
        ),
        Text(
          _getSplitTitle(state.splitType),
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textBlack),
        ),
        SizedBox(
          height: 60,
          child: Center(
            child: Text(
              _getSplitDescription(state.splitType),
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textGrey, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAvatar(GroupMemberEntity member) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AppAvatar(
        url: member.avtar,
        radius: 25,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, SplitState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTabItem(context, "=", SplitType.equal, state),
            _buildTabItem(context, "1.23", SplitType.exact, state),
            _buildTabItem(context, "%", SplitType.percentage, state),
            _buildIconTabItem(context, Icons.bar_chart, SplitType.shares, state),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String text, SplitType? type, SplitState state) {
    final isSelected = state.splitType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (type != null) {
            context.read<SplitBloc>().add(UpdateSplitTypeEvent(type));
          }
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1))] : null,
          ),
          child: Text(
            text,
            style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textGrey),
          ),
        ),
      ),
    );
  }

  Widget _buildIconTabItem(BuildContext context, IconData icon, SplitType? type, SplitState state) {
    final isSelected = state.splitType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (type != null) {
            context.read<SplitBloc>().add(UpdateSplitTypeEvent(type));
          }
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1))] : null,
          ),
          child: Icon(icon, color: isSelected ? Colors.white : AppColors.textGrey, size: 20),
        ),
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, SplitState state) {
    return ListView.builder(
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        final member = state.members[index];
        ExpenseSplit? split;
        try {
          split = state.splits.firstWhere((s) => s.userId == member.userId);
        } catch (_) {
          split = null;
        }
        return _buildMemberItem(context, member, split, state);
      },
    );
  }

  Widget _buildMemberItem(BuildContext context, GroupMemberEntity member, ExpenseSplit? split, SplitState state) {
    bool isSelected = state.splits.any((s) => s.userId == member.userId);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildListAvatar(member),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName ?? "Unknown",
                  style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textBlack),
                ),
                if (state.splitType == SplitType.equal)
                  Text(
                    isSelected
                        ? "₹${state.splits.isNotEmpty ? (state.totalAmount / state.splits.length).toStringAsFixed(2) : '0.00'}/person"
                        : "Not involved",
                    style: GoogleFonts.openSans(
                      fontSize: 13, 
                      color: isSelected ? AppColors.textGrey : AppColors.textGrey.withOpacity(0.5),
                    ),
                  )
                else if (state.splitType == SplitType.shares)
                  Text(
                    "₹${state.getMemberAmount(member.userId!).toStringAsFixed(2)}",
                    style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textGrey),
                  )
                else if (state.splitType == SplitType.percentage)
                  Text(
                    "₹${state.getMemberAmount(member.userId!).toStringAsFixed(2)}",
                    style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textGrey),
                  ),
              ],
            ),
          ),
          if (state.splitType == SplitType.equal)
             Checkbox(
               value: isSelected,
               activeColor: AppColors.primaryTeal,
               onChanged: (_) {
                 context.read<SplitBloc>().add(ToggleMemberSelectionEvent(member.userId!));
               },
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
             )
          else
            _buildSplitInput(context, member.userId!, split, state),
        ],
      ),
    );
  }

  Widget _buildListAvatar(GroupMemberEntity member) {
    return AppAvatar(
      url: member.avtar,
      radius: 20,
    );
  }

  Widget _buildSplitInput(BuildContext context, String userId, ExpenseSplit? split, SplitState state) {
    if (state.splitType == SplitType.equal) {
      return const SizedBox(); 
    }

    if (!_controllers.containsKey(userId)) {
      _controllers[userId] = TextEditingController();
    }
    final controller = _controllers[userId];

    return SizedBox(
      width: 100,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.end,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: state.splitType == SplitType.percentage ? "0" : "0.00",
          border: InputBorder.none,
          isDense: true,
          hintStyle: GoogleFonts.openSans(color: AppColors.textGrey.withOpacity(0.5)),
          suffixText: state.splitType == SplitType.percentage ? "%" : null,
        ),
        style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlack),
        onChanged: (value) {
          final doubleVal = double.tryParse(value) ?? 0.0;
          if (state.splitType == SplitType.exact) {
             context.read<SplitBloc>().add(UpdateSplitAmountEvent(userId: userId, amount: doubleVal));
          } else if (state.splitType == SplitType.percentage) {
             context.read<SplitBloc>().add(UpdateSplitPercentageEvent(userId: userId, percentage: doubleVal));
          } else if (state.splitType == SplitType.shares) {
             context.read<SplitBloc>().add(UpdateSplitSharesEvent(userId: userId, shares: doubleVal));
          }
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context, SplitState state) {
    if (state.splitType == SplitType.equal) {
       final amountPerPerson = state.splits.isNotEmpty ? state.totalAmount / state.splits.length : 0.0;
       final isAllSelected = state.splits.length == state.members.length;
       
       return Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 40.0), // Added bottom padding
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border(top: BorderSide(color: AppColors.borderGrey)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center the text
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹${amountPerPerson.toStringAsFixed(2)}/person",
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlack),
                  ),
                  Text(
                    "(${state.splits.length} people)",
                    style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  "All",
                  style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                ),
                Checkbox(
                  value: isAllSelected,
                  activeColor: AppColors.primaryTeal,
                  onChanged: (_) {
                    context.read<SplitBloc>().add(const ToggleAllSelectionEvent());
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ],
            )
          ],
        ),
      );
    }

    String mainText = "";
    String subText = "";
    Color subTextColor = AppColors.textGrey;

    if (state.splitType == SplitType.exact) {
      double currentTotal = state.currentTotalAmount;
      double remaining = state.totalAmount - currentTotal;
      
      mainText = "₹${currentTotal.toStringAsFixed(2)} of ₹${state.totalAmount.toStringAsFixed(2)}";
      if (remaining.abs() < 0.01) {
        subText = "Perfect match";
        subTextColor = AppColors.primaryTeal;
      } else if (remaining > 0) {
        subText = "₹${remaining.toStringAsFixed(2)} left";
        subTextColor = AppColors.textBlack;
      } else {
        subText = "₹${(-remaining).toStringAsFixed(2)} over";
        subTextColor = Colors.red;
      }
    } else if (state.splitType == SplitType.percentage) {
      double currentTotal = state.totalPercentage;
      double remaining = 100 - currentTotal;
      
      mainText = "${currentTotal.toStringAsFixed(1)}% of 100%";
      
      if (remaining.abs() < 0.1) {
         subText = "Perfect match";
         subTextColor = AppColors.primaryTeal;
      } else if (remaining > 0) {
        subText = "${remaining.toStringAsFixed(1)}% left";
        subTextColor = AppColors.textBlack;
      } else {
        subText = "${(-remaining).toStringAsFixed(1)}% over";
        subTextColor = Colors.red;
      }
    } else if (state.splitType == SplitType.shares) {
      double totalShares = state.totalShares;
      mainText = "${totalShares.toStringAsFixed(0)} total shares";
    }

    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 40.0), // Added bottom padding
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            mainText,
            style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlack),
          ),
          if (subText.isNotEmpty)
            Text(
              subText,
              style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: subTextColor),
            ),
        ],
      ),
    );
  }

  String _getSplitTitle(SplitType type) {
    switch (type) {
      case SplitType.equal: return "Split equally";
      case SplitType.exact: return "Split by exact amount";
      case SplitType.percentage: return "Split by percentage";
      case SplitType.shares: return "Split by shares";
    }
  }

  String _getSplitDescription(SplitType type) {
    switch (type) {
      case SplitType.equal: return "Everyone pays the same amount.";
      case SplitType.exact: return "Specify exactly how much each person pays.";
      case SplitType.percentage: return "Enter the percentage of the total amount each person pays.";
      case SplitType.shares: return "Great for time-based splitting (2 nights → 2 shares) or splitting across families.";
    }
  }
}
