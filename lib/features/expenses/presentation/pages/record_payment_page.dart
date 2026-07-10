import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/features/expenses/presentation/bloc/settle_up/settle_up_cubit.dart';

class RecordPaymentPage extends StatefulWidget {
  const RecordPaymentPage({super.key});

  @override
  State<RecordPaymentPage> createState() => _RecordPaymentPageState();
}

class _RecordPaymentPageState extends State<RecordPaymentPage> with SingleTickerProviderStateMixin {
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
    _hintFade = CurvedAnimation(parent: _hintAnimController, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
          Navigator.of(context).popUntil((route) =>
              route.settings.name == AppRoutes.groupDetail ||
              route.settings.name == AppRoutes.friendDetail ||
              route.settings.name == AppRoutes.home);
        } else if (state.status == SettleUpStatus.failure && state.errorMessage != null) {
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
        backgroundColor: AppColors.backgroundLightGrey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Settle Up",
            style: GoogleFonts.outfit(
              color: AppColors.textBlack,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SettleUpCubit, SettleUpState>(
          builder: (context, state) {
            final userState = context.read<AppUserCubit>().state;
            if (userState is! AppUserLoggedIn) return const SizedBox();
            final currentUser = userState.user;
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

            // Determine direction: balance > 0 = they owe you = they paid you
            //                      balance < 0 = you owe them = you paid them
            final double rawBalance = args?['balance'] ?? 0.0;
            final bool theyPayYou = rawBalance > 0; // they owe you → they're paying you

            final String directionLabel = theyPayYou
                ? "${_targetUserName ?? "Friend"} paid you"
                : "You paid ${_targetUserName ?? "Friend"}";

            final String? payerAvatar = theyPayYou ? _targetUserAvatar : currentUser.avatarUrl;
            final String? payeeAvatar = theyPayYou ? currentUser.avatarUrl : _targetUserAvatar;
            final String payerName = theyPayYou ? (_targetUserName ?? "Friend") : "You";
            final String payeeName = theyPayYou ? "You" : (_targetUserName ?? "Friend");

            final formatter = NumberFormat('#,##0.##', 'en_IN');
            final double balance = state.targetBalance;
            final double? enteredAmt = double.tryParse(state.amount);

            // Find selected group name
            String groupName = "Non-group expense";
            if (state.groupId != null) {
              final selectedGroup = state.commonGroups.any((g) => g.id == state.groupId)
                  ? state.commonGroups.firstWhere((g) => g.id == state.groupId)
                  : null;
              groupName = selectedGroup?.name ?? "Selected Group";
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

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

                      const SizedBox(height: 32),

                      // ── Amount Input ────────────────────────────────────────
                      _AmountInput(
                        initialAmount: balance,
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

                      const SizedBox(height: 28),

                      // ── Group Row ───────────────────────────────────────────
                      _buildActionItem(
                        icon: Icons.group_rounded,
                        label: "In Group",
                        value: groupName,
                        showArrow: false,
                        onTap: () {},
                      ),

                      const SizedBox(height: 12),

                      // ── Date Row ────────────────────────────────────────────
                      _buildActionItem(
                        icon: Icons.calendar_today_rounded,
                        label: "Date of payment",
                        value: DateFormat('MMM dd, yyyy').format(state.date),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: state.date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(primary: AppColors.primary),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null && mounted) {
                            // ignore: use_build_context_synchronously
                            context.read<SettleUpCubit>().onDateChanged(picked);
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      // ── Note Input ──────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _noteController,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                          ),
                          decoration: InputDecoration(
                            icon: const Icon(Icons.notes_rounded, color: AppColors.primary, size: 20),
                            hintText: "Add a note...",
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 15,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => context.read<SettleUpCubit>().onNoteChanged(val),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Disclaimer ──────────────────────────────────────────
                      Text(
                        state.isOverpayment
                            ? "The extra ₹${formatter.format(state.overpaymentAmount)} will be recorded as an advance payment."
                            : "This records a cash payment and settles the pending balance.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: state.isOverpayment ? AppColors.warningOrange : AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom CTA ────────────────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Amount preview above button
                        if (enteredAmt != null && enteredAmt > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              state.isOverpayment
                                  ? "Settling ₹${formatter.format(state.settlementAmount)} + ₹${formatter.format(state.overpaymentAmount)} advance"
                                  : "Settling ₹${formatter.format(enteredAmt)} of ₹${formatter.format(balance)}",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: state.isOverpayment ? AppColors.warningOrange : AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ElevatedButton(
                          onPressed: state.status == SettleUpStatus.loading
                              ? null
                              : () => context.read<SettleUpCubit>().submitPayment(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: state.status == SettleUpStatus.loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(
                                  "Confirm Settle Up",
                                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textBlack)),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.iconGrey, size: 14),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Direction Card: shows payer → payee visually
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Direction label
          Text(
            directionLabel,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "₹${formatter.format(balance)}",
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Avatar row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _UserNode(avatar: payerAvatar, name: payerName, role: "Payer"),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (i) => Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i.isEven
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            "CASH",
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _UserNode(avatar: payeeAvatar, name: payeeName, role: "Receives"),
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

  const _UserNode({required this.avatar, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          AppAvatar(url: avatar, radius: 26),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.outfit(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textBlack),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: GoogleFonts.outfit(
                fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Amount Input: large inline editable amount
// ─────────────────────────────────────────────────────────────────────────────

class _AmountInput extends StatefulWidget {
  final double initialAmount;
  final ValueChanged<String> onChanged;

  const _AmountInput({required this.initialAmount, required this.onChanged});

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
        : widget.initialAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
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
    // The BlocBuilder rebuilds after cubit.initialize() returns the real balance.
    // Since Flutter reuses the State object, initState never runs again.
    // We catch the first real (non-zero) value here and populate the controller.
    if (!_hasReceivedRealAmount && widget.initialAmount != 0) {
      _hasReceivedRealAmount = true;
      final value = widget.initialAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "₹",
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            IntrinsicWidth(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: GoogleFonts.outfit(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                  letterSpacing: -1,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: "0",
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.borderGreyLight,
                    letterSpacing: -1,
                  ),
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "TAP TO EDIT AMOUNT",
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.iconGrey,
            letterSpacing: 1.2,
          ),
        ),
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
        border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: AppColors.warningOrange, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: "You're settling "),
                  TextSpan(
                    text: "₹${formatter.format(settlementAmount)}",
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.successGreen),
                  ),
                  const TextSpan(text: " and paying "),
                  TextSpan(
                    text: "₹${formatter.format(overpaymentAmount)}",
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warningOrange),
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
