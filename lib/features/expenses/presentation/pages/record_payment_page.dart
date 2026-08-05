import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/profile_picture_dialog.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import 'package:split_ease/features/expenses/presentation/bloc/settle_up/settle_up_cubit.dart';
import 'package:split_ease/features/expenses/presentation/pages/expense_note_page.dart';
import 'package:split_ease/features/expenses/presentation/widgets/calculator_bottom_sheet.dart';

class RecordPaymentPage extends StatefulWidget {
  const RecordPaymentPage({super.key});

  @override
  State<RecordPaymentPage> createState() => _RecordPaymentPageState();
}

class _RecordPaymentPageState extends State<RecordPaymentPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _hintAnimController;
  late Animation<double> _hintFade;

  String? _targetUserName;
  String? _targetUserAvatar;

  @override
  void initState() {
    super.initState();

    _hintAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _hintFade = CurvedAnimation(
      parent: _hintAnimController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String? targetUserId = args?['targetUserId'];
      final double? balance = args?['balance'];
      final String? groupId = args?['groupId'];
      _targetUserName = args?['targetUserName'];
      _targetUserAvatar = args?['targetUserAvatar'];

      final userState = context.read<AppUserCubit>().state;
      if (userState is AppUserLoggedIn) {
        context.read<SettleUpCubit>().initialize(
          currentUserId: userState.user.id,
          groupId: groupId,
          initialAmount: balance?.abs(),
          targetUserId: targetUserId,
        );
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _hintAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettleUpCubit, SettleUpState>(
      listener: (context, state) {
        if (state.status == SettleUpStatus.success) {
          AppAlerts.showSuccess(context, "Payment recorded successfully!");
          Navigator.of(context).popUntil(
            (route) =>
                route.settings.name == AppRoutes.groupDetail ||
                route.settings.name == AppRoutes.friendDetail ||
                route.settings.name == AppRoutes.home,
          );
        } else if (state.status == SettleUpStatus.failure &&
            state.errorMessage != null) {
          AppAlerts.showError(context, state.errorMessage!);
        }

        // Animate hint in/out based on overpayment state
        if (state.isOverpayment) {
          _hintAnimController.forward();
        } else {
          _hintAnimController.reverse();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).ext.backgroundGrey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).ext.backgroundGrey,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          leadingWidth: 80,
          title: Text(
            "Settle Up",
            style: GoogleFonts.outfit(
              color: Theme.of(context).ext.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<SettleUpCubit, SettleUpState>(
              builder: (context, state) {
                if (state.status == SettleUpStatus.loading) {
                   return const Padding(
                     padding: EdgeInsets.only(right: 24.0),
                     child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal))),
                   );
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () => context.read<SettleUpCubit>().submitPayment(),
                    child: Text(
                      "Save",
                      style: GoogleFonts.outfit(color: AppColors.primaryTeal, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<SettleUpCubit, SettleUpState>(
          builder: (context, state) {
            final userState = context.read<AppUserCubit>().state;
            if (userState is! AppUserLoggedIn) return const SizedBox();
            final currentUser = userState.user;
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;

            // Determine direction: balance > 0 = they owe you = they paid you
            //                      balance < 0 = you owe them = you paid them
            final double rawBalance = args?['balance'] ?? 0.0;
            final bool theyPayYou =
                rawBalance > 0; // they owe you → they're paying you

            final String directionLabel = theyPayYou
                ? "${_targetUserName ?? "Friend"} paid you"
                : "You paid ${_targetUserName ?? "Friend"}";

            final String? payerAvatar = theyPayYou
                ? _targetUserAvatar
                : currentUser.avatarUrl;
            final String? payeeAvatar = theyPayYou
                ? currentUser.avatarUrl
                : _targetUserAvatar;
            final String payerName = theyPayYou
                ? (_targetUserName ?? "Friend")
                : "You";
            final String payeeName = theyPayYou
                ? "You"
                : (_targetUserName ?? "Friend");

            final formatter = NumberFormat('#,##0.##', 'en_IN');
            final double balance = state.targetBalance;

            String getPaymentMethodName() {
              if (state.paymentMethods.isEmpty) return "CASH";
              for (var m in state.paymentMethods) {
                if (m.id == state.selectedPaymentMethodId) return m.name;
              }
              return state.paymentMethods.first.name;
            }

            // Find selected group name
            String groupName = "Non-group expense";
            if (state.groupId != null) {
              final selectedGroup =
                  state.commonGroups.any((g) => g.id == state.groupId)
                  ? state.commonGroups.firstWhere((g) => g.id == state.groupId)
                  : null;
              groupName = selectedGroup?.name ?? "Selected Group";
            }

            final selectedMethod = state.paymentMethods.isNotEmpty
                ? (state.paymentMethods.any((m) => m.id == state.selectedPaymentMethodId)
                    ? state.paymentMethods.firstWhere((m) => m.id == state.selectedPaymentMethodId)
                    : state.paymentMethods.first)
                : null;
            final IconData paymentMethodIcon = selectedMethod != null
                ? IconUtils.getIconFromString(selectedMethod.icon)
                : Icons.account_balance_wallet_rounded;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Direction Summary Card ──────────────────────────────
                  _DirectionCard(
                    payerAvatar: payerAvatar,
                    payeeAvatar: payeeAvatar,
                    payerName: payerName,
                    payeeName: payeeName,
                    directionLabel: directionLabel,
                    balance: balance,
                    formatter: formatter,
                  ),

                  const SizedBox(height: 24),

                  // ── Amount Input Card ───────────────────────────────────
                  _AmountInput(
                    initialAmount: balance,
                    targetBalance: balance,
                    onChanged: (val) {
                      context.read<SettleUpCubit>().onAmountChanged(val);
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── Smart Overpayment Hint ──────────────────────────────
                  FadeTransition(
                    opacity: _hintFade,
                    child: state.isOverpayment
                        ? _OverpaymentHint(
                            settlementAmount: state.settlementAmount,
                            overpaymentAmount: state.overpaymentAmount,
                            formatter: formatter,
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // ── Settings Card ───────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).ext.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 20,
                            offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildConfigRow(
                          icon: Icons.group_rounded,
                          label: "In Group",
                          value: groupName,
                          isTop: true,
                          showArrow: false,
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildConfigRow(
                          icon: Icons.calendar_today_rounded,
                          label: "Date",
                          value:
                              DateFormat('MMM dd, yyyy').format(state.date),
                          valueColor: Theme.of(context).ext.textPrimary,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: state.date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: AppColors.primary,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null && context.mounted) {
                              context
                                  .read<SettleUpCubit>()
                                  .onDateChanged(picked);
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildConfigRow(
                          icon: paymentMethodIcon,
                          iconColor: selectedMethod != null
                              ? Color(int.parse(
                                  selectedMethod.color.replaceFirst('#', '0xFF')))
                              : null,
                          label: "Payment method",
                          value: state.paymentMethods.isNotEmpty
                              ? getPaymentMethodName()
                              : "Loading...",
                          onTap: () => _showPaymentMethodPicker(context, state),
                        ),
                        _buildDivider(),
                        _buildConfigRow(
                          icon: Icons.notes_rounded,
                          label: "Notes",
                          value: state.note.isEmpty ? "Add a note" : state.note,
                          valueColor: state.note.isEmpty
                              ? Theme.of(context).ext.textSecondary
                              : Theme.of(context).ext.textPrimary,
                          isBottom: true,
                          onTap: () async {
                            final result = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExpenseNotePage(initialNote: state.note),
                              ),
                            );
                            if (result != null && context.mounted) {
                              context
                                  .read<SettleUpCubit>()
                                  .onNoteChanged(result);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Disclaimer ──────────────────────────────────────────
                  Text(
                    state.isOverpayment
                        ? "The extra ₹${formatter.format(state.overpaymentAmount)} will be recorded as an advance payment."
                        : "This records a payment and settles the pending balance.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: state.isOverpayment
                          ? AppColors.warningOrange
                          : AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPaymentMethodPicker(BuildContext context, SettleUpState state) {
    if (state.paymentMethods.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).ext.scaffoldBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Payment Method",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: state.paymentMethods.map((method) {
                        final isSelected =
                            state.selectedPaymentMethodId == method.id;
                        final color = Color(int.parse(
                            method.color.replaceFirst('#', '0xFF')));
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(IconUtils.getIconFromString(method.icon),
                                color: color, size: 24),
                          ),
                          title: Text(
                            method.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: Theme.of(context).ext.textPrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded,
                                  color: AppColors.primaryTeal)
                              : null,
                          onTap: () {
                            context
                                .read<SettleUpCubit>()
                                .onPaymentMethodChanged(method.id);
                            Navigator.pop(ctx);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 20),
      child: Divider(height: 1, color: Theme.of(context).ext.border.withValues(alpha: 0.2)),
    );
  }

  Widget _buildConfigRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? iconColor,
    required VoidCallback onTap,
    bool isTop = false,
    bool isBottom = false,
    bool showArrow = true,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.primaryTeal;
    return InkWell(
      onTap: showArrow ? onTap : null,
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(24) : Radius.zero,
        bottom: isBottom ? const Radius.circular(24) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: effectiveIconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: valueColor ?? AppColors.textGrey),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showArrow)
              Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).ext.textTertiary, size: 14),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Direction Card: shows transfer visualization with payer → payee
// ─────────────────────────────────────────────────────────────────────────────

class _DirectionCard extends StatelessWidget {
  final String? payerAvatar;
  final String? payeeAvatar;
  final String payerName;
  final String payeeName;
  final String directionLabel;
  final double balance;
  final NumberFormat formatter;

  const _DirectionCard({
    required this.payerAvatar,
    required this.payeeAvatar,
    required this.payerName,
    required this.payeeName,
    required this.directionLabel,
    required this.balance,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).ext.border.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Direction Header & Balance Pill
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        size: 14,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          directionLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryTeal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (balance > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.backgroundGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).ext.border.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    "Balance: ₹${formatter.format(balance)}",
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).ext.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // Avatar Flow
          Row(
            children: [
              _UserNode(
                avatar: payerAvatar,
                name: payerName,
                role: "Payer",
                isPayer: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryTeal.withValues(alpha: 0.2),
                              AppColors.primaryTeal,
                              AppColors.primaryTeal.withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryTeal.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Theme.of(context).ext.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _UserNode(
                avatar: payeeAvatar,
                name: payeeName,
                role: "Recipient",
                isPayer: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserNode extends StatelessWidget {
  final String? avatar;
  final String name;
  final String role;
  final bool isPayer;

  const _UserNode({
    required this.avatar,
    required this.name,
    required this.role,
    required this.isPayer,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isPayer ? AppColors.primaryTeal : AppColors.primary;
    final badgeBg = isPayer
        ? AppColors.primaryTeal.withValues(alpha: 0.1)
        : AppColors.primary.withValues(alpha: 0.1);
    final badgeText = isPayer ? AppColors.primaryTeal : AppColors.primary;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              ProfilePictureDialog.show(
                context,
                avatarUrl: avatar,
                name: name,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: AppAvatar(url: avatar, radius: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).ext.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Amount Input Card: Large editable amount in a styled hero container
// ─────────────────────────────────────────────────────────────────────────────

class _AmountInput extends StatefulWidget {
  final double initialAmount;
  final double targetBalance;
  final ValueChanged<String> onChanged;

  const _AmountInput({
    required this.initialAmount,
    required this.targetBalance,
    required this.onChanged,
  });

  @override
  State<_AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<_AmountInput> {
  late TextEditingController _controller;
  bool _hasReceivedRealAmount = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAmount == 0
        ? ''
        : widget.initialAmount
              .toStringAsFixed(2)
              .replaceAll(RegExp(r'\.00$'), '');
    _controller = TextEditingController(text: initial);
    if (initial.isNotEmpty) {
      _hasReceivedRealAmount = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(initial);
      });
    }
  }

  @override
  void didUpdateWidget(_AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasReceivedRealAmount && widget.initialAmount != 0) {
      _hasReceivedRealAmount = true;
      final value = widget.initialAmount
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'\.00$'), '');
      _controller.text = value;
      _controller.selection = TextSelection.collapsed(offset: value.length);
      widget.onChanged(value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    final formatted = amount
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'\.00$'), '');
    _controller.text = formatted;
    _controller.selection = TextSelection.collapsed(offset: formatted.length);
    widget.onChanged(formatted);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double? currentEntered = double.tryParse(_controller.text);
    final bool showFullSettleChip =
        widget.targetBalance > 0 &&
        (currentEntered == null || (currentEntered - widget.targetBalance).abs() > 0.01);

    final formatter = NumberFormat('#,##0.##', 'en_IN');

    final text = _controller.text;
    final double fontSize = text.length > 8
        ? 30.0
        : text.length > 6
            ? 36.0
            : text.length > 3
                ? 42.0
                : 52.0;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).ext.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              TextField(
                controller: _controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                style: GoogleFonts.outfit(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).ext.textPrimary,
                  height: 1.1,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      left: 48, right: 48, top: 4, bottom: 4),
                  hintText: "₹0",
                  hintStyle: GoogleFonts.outfit(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textGrey.withValues(alpha: 0.3),
                    height: 1.1,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (val) {
                  setState(() {});
                  widget.onChanged(val);
                },
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: AppColors.primaryTeal,
                      size: 22,
                    ),
                  ),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    final result = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CalculatorBottomSheet(
                        initialValue: _controller.text,
                      ),
                    );
                    if (result != null && result.isNotEmpty && mounted) {
                      _setAmount(double.tryParse(result) ?? 0.0);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (showFullSettleChip) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _setAmount(widget.targetBalance),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryTeal.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14,
                    color: AppColors.primaryTeal,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Settle Full Balance: ₹${formatter.format(widget.targetBalance)}",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overpayment Hint Banner
// ─────────────────────────────────────────────────────────────────────────────

class _OverpaymentHint extends StatelessWidget {
  final double settlementAmount;
  final double overpaymentAmount;
  final NumberFormat formatter;

  const _OverpaymentHint({
    required this.settlementAmount,
    required this.overpaymentAmount,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warningOrange.withValues(alpha: 0.12),
            AppColors.warningOrange.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warningOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.warningOrange,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Theme.of(context).ext.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: "You're settling "),
                  TextSpan(
                    text: "₹${formatter.format(settlementAmount)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreen,
                    ),
                  ),
                  const TextSpan(text: " and paying "),
                  TextSpan(
                    text: "₹${formatter.format(overpaymentAmount)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.warningOrange,
                    ),
                  ),
                  const TextSpan(text: " extra"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
