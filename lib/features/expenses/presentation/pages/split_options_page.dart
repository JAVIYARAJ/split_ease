import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

import '../../../../injection_container.dart';

class SplitOptionsPage extends StatelessWidget {
  const SplitOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ExpenseBloc>(),
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final members = state.group?.members ?? [];
          final totalAmount = double.tryParse(state.amount) ?? 0.0;

          return _SplitOptionsView(members: members, initialSplitType: state.splitType, initialSplits: state.splits, totalAmount: totalAmount);
        },
      ),
    );
  }
}

class _SplitOptionsView extends StatefulWidget {
  final List<GroupMemberEntity> members;
  final SplitType initialSplitType;
  final List<ExpenseSplit> initialSplits;
  final double totalAmount;

  const _SplitOptionsView({required this.members, required this.initialSplitType, required this.initialSplits, required this.totalAmount});

  @override
  State<_SplitOptionsView> createState() => _SplitOptionsViewState();
}

class _SplitOptionsViewState extends State<_SplitOptionsView> {
  late SplitType _currentSplitType;
  late List<ExpenseSplit> _currentSplits;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _currentSplitType = widget.initialSplitType;
    _initializeSplits();
  }

  void _initializeSplits() {
    // Determine initial splits based on state or default to all members
    if (widget.initialSplits.isNotEmpty) {
      _currentSplits = List.from(widget.initialSplits);
    } else {
      _currentSplits = widget.members.map((member) {
        return ExpenseSplit(userId: member.userId!, amount: 0.0, percentage: 0.0, shares: 1.0);
      }).toList();
    }

    // Initialize controllers for present splits
    for (var split in _currentSplits) {
      _controllers[split.userId] = TextEditingController();
      _updateControllerValue(split.userId, split);
    }
  }

  void _updateControllerValue(String userId, ExpenseSplit split) {
    if (_currentSplitType == SplitType.exact) {
      _controllers[userId]?.text = split.amount == 0 ? '' : split.amount.toStringAsFixed(2);
    } else if (_currentSplitType == SplitType.percentage) {
      _controllers[userId]?.text = split.percentage == 0 ? '' : split.percentage.toStringAsFixed(1);
    } else if (_currentSplitType == SplitType.shares) {
      _controllers[userId]?.text = split.shares.toStringAsFixed(0);
    }
  }

  void _updateSplitsOnTypeChange() {
    // When switching types, we ensure all members are present (unless implicit subsets are allowed, but usually other types start with all)
    // For now, let's restore all members if we switch type, to avoid confusion.
    final setOfCurrent = _currentSplits.map((s) => s.userId).toSet();
    for (var member in widget.members) {
      if (!setOfCurrent.contains(member.userId)) {
         _currentSplits.add(ExpenseSplit(userId: member.userId!, amount: 0, percentage: 0, shares: 1));
      }
    }
    // Also ensure controllers exist
    for (var split in _currentSplits) {
       if (!_controllers.containsKey(split.userId)) {
          _controllers[split.userId] = TextEditingController();
       }
      _updateControllerValue(split.userId, split);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
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
          TextButton(
            onPressed: () {
              context.read<ExpenseBloc>().add(SplitTypeChanged(_currentSplitType));
              context.read<ExpenseBloc>().add(SplitOptionChanged(_currentSplits));
              Navigator.pop(context);
            },
            child: Text(
              "Done",
              style: GoogleFonts.openSans(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderGrey),
          Expanded(child: _buildMembersList()),
          _buildFooter(),
        ],
      ),
    );
  }

  // ... _buildHeader ... (Same as before)
  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: widget.members.take(4).map((m) => _buildHeaderAvatar(m)).toList()),
        ),
        Text(
          _getSplitTitle(),
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textBlack),
        ),
        SizedBox(
          height: 60,
          child: Center(
            child: Text(
              _getSplitDescription(),
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
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
          image: member.avtar != null ? DecorationImage(image: CachedNetworkImageProvider(member.avtar!), fit: BoxFit.cover) : null,
          color: member.avtar == null ? AppColors.primaryTeal : null,
        ),
        child: member.avtar == null
            ? Center(
                child: Text(
                  member.fullName?.substring(0, 1).toUpperCase() ?? "?",
                  style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTabItem("=", SplitType.equal),
            _buildTabItem("1.23", SplitType.exact),
            _buildTabItem("%", SplitType.percentage),
            _buildIconTabItem(Icons.bar_chart, SplitType.shares),
            _buildTabItem("+/-", null),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String text, SplitType? type) {
    final isSelected = _currentSplitType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (type != null) {
            setState(() {
              _currentSplitType = type;
              _updateSplitsOnTypeChange();
            });
          }
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))] : null,
          ),
          child: Text(
            text,
            style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textGrey),
          ),
        ),
      ),
    );
  }

  Widget _buildIconTabItem(IconData icon, SplitType? type) {
    final isSelected = _currentSplitType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (type != null) {
            setState(() {
              _currentSplitType = type;
              _updateSplitsOnTypeChange();
            });
          }
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))] : null,
          ),
          child: Icon(icon, color: isSelected ? Colors.white : AppColors.textGrey, size: 20),
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return ListView.builder(
      itemCount: widget.members.length,
      itemBuilder: (context, index) {
        final member = widget.members[index];
        ExpenseSplit? split;
        try {
          split = _currentSplits.firstWhere((s) => s.userId == member.userId);
        } catch (_) {
          split = null;
        }
        return _buildMemberItem(member, split);
      },
    );
  }

  Widget _buildMemberItem(GroupMemberEntity member, ExpenseSplit? split) {
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
                if (_currentSplitType == SplitType.equal)
                  Text(
                    _currentSplits.any((s) => s.userId == member.userId)
                        ? "₹${_currentSplits.isNotEmpty ? (widget.totalAmount / _currentSplits.length).toStringAsFixed(2) : '0.00'}"
                        : "Not involved",
                    style: GoogleFonts.openSans(
                      fontSize: 13, 
                      color: _currentSplits.any((s) => s.userId == member.userId) ? AppColors.textGrey : AppColors.textGrey.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
          _buildSplitInput(member.userId!, split),
        ],
      ),
    );
  }

  // ... _buildListAvatar ... (Same as before)
  Widget _buildListAvatar(GroupMemberEntity member) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: member.avtar != null ? DecorationImage(image: CachedNetworkImageProvider(member.avtar!), fit: BoxFit.cover) : null,
        color: member.avtar == null ? AppColors.primaryTeal : null,
      ),
      child: member.avtar == null
          ? Center(
              child: Text(
                member.fullName?.substring(0, 1).toUpperCase() ?? "?",
                style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )
          : null,
    );
  }

  Widget _buildSplitInput(String userId, ExpenseSplit? split) {
    if (_currentSplitType == SplitType.equal) {
      return const SizedBox(); // Nothing for equal
    }

    final controller = _controllers[userId];

    return SizedBox(
      width: 80,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.end,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: _currentSplitType == SplitType.percentage ? "0" : "0.00",
          border: InputBorder.none,
          isDense: true,
          hintStyle: GoogleFonts.openSans(color: AppColors.textGrey.withValues(alpha: 0.5)),
          suffixText: _currentSplitType == SplitType.percentage ? "%" : null,
        ),
        style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlack),
        onChanged: (value) {
          final doubleVal = double.tryParse(value) ?? 0.0;
          setState(() {
            final index = _currentSplits.indexWhere((s) => s.userId == userId);
            if (index != -1) {
              if (_currentSplitType == SplitType.exact) {
                _currentSplits[index] = _currentSplits[index].copyWith(amount: doubleVal);
              } else if (_currentSplitType == SplitType.percentage) {
                _currentSplits[index] = _currentSplits[index].copyWith(percentage: doubleVal);
              } else if (_currentSplitType == SplitType.shares) {
                _currentSplits[index] = _currentSplits[index].copyWith(shares: doubleVal);
              }
            }
          });
        },
      ),
    );
  }

  Widget _buildFooter() {
    String footerText;
    Color footerColor = AppColors.textBlack;

    if (_currentSplitType == SplitType.equal) {
      footerText = "${_currentSplits.length} people selected";
    } else if (_currentSplitType == SplitType.exact) {
      double currentTotal = _currentSplits.fold(0, (sum, item) => sum + item.amount);
      double remaining = widget.totalAmount - currentTotal;
      if (remaining.abs() < 0.01) {
        footerText = "₹$currentTotal • Perfect match";
        footerColor = AppColors.primaryTeal;
      } else if (remaining > 0) {
        footerText = "₹$currentTotal • ₹${remaining.toStringAsFixed(2)} remaining";
        footerColor = Colors.red;
      } else {
        footerText = "₹$currentTotal • ₹${(-remaining).toStringAsFixed(2)} over";
        footerColor = Colors.red;
      }
    } else if (_currentSplitType == SplitType.percentage) {
      double currentTotal = _currentSplits.fold(0, (sum, item) => sum + item.percentage);
      double remaining = 100 - currentTotal;
      if (remaining.abs() < 0.1) {
        footerText = "$currentTotal% • Perfect match";
        footerColor = AppColors.primaryTeal;
      } else if (remaining > 0) {
        footerText = "$currentTotal% • ${remaining.toStringAsFixed(1)}% remaining";
        footerColor = Colors.red;
      } else {
        footerText = "$currentTotal% • ${(-remaining).toStringAsFixed(1)}% over";
        footerColor = Colors.red;
      }
    } else if (_currentSplitType == SplitType.shares) {
      double totalShares = _currentSplits.fold(0, (sum, item) => sum + item.shares);
      footerText = "${totalShares.toStringAsFixed(0)} total shares";
    } else {
      footerText = "";
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            footerText,
            style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16, color: footerColor),
          ),
          if (_currentSplitType == SplitType.equal) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_currentSplits.length == widget.members.length) {
                     _currentSplits.clear();
                  } else {
                    _currentSplits = widget.members.map((m) => ExpenseSplit(userId: m.userId!, amount: 0, percentage: 0, shares: 1)).toList();
                  }
                });
              },
              child: Text(
                _currentSplits.length == widget.members.length ? "Deselect All" : "Select All",
                style: GoogleFonts.openSans(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // ... _getSplitTitle ... (Same as before)
  String _getSplitTitle() {
    switch (_currentSplitType) {
      case SplitType.equal:
        return "Split equally";
      case SplitType.exact:
        return "Split by exact amount";
      case SplitType.percentage:
        return "Split by percentage";
      case SplitType.shares:
        return "Split by shares";
    }
  }

  // ... _getSplitDescription ... (Same as before)
  String _getSplitDescription() {
    switch (_currentSplitType) {
      case SplitType.equal:
        return "Everyone pays the same amount.";
      case SplitType.exact:
        return "Specify exactly how much each person pays.";
      case SplitType.percentage:
        return "Enter the percentage of the total amount each person pays.";
      case SplitType.shares:
        return "Great for time-based splitting (2 nights → 2 shares) or splitting across families.";
    }
  }
}
