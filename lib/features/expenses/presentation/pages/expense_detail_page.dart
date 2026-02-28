import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_event.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_state.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/injection_container.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExpenseDetailPage extends StatefulWidget {

  const ExpenseDetailPage({super.key});

  @override
  State<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      var argument = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (argument != null && argument["expanse_id"] != null) {
        context.read<ExpenseDetailBloc>().add(FetchExpenseDetailEvent(argument["expanse_id"]));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      useSafeArea: false,
      backgroundColor: Colors.white, // Plain white background, no cards
      child: BlocBuilder<ExpenseDetailBloc, ExpenseDetailState>(
        builder: (context, state) {
          if (state is ExpenseDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.errorRed),
                  const SizedBox(height: 16),
                  Text(
                    "Failed to load expense details:\n${state.message}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          final bool isLoading = state is ExpenseDetailLoading || state is ExpenseDetailInitial;
          final entity = state is ExpenseDetailLoaded ? state.expenseDetail : _getMockEntity();

          return Skeletonizer(
            enabled: isLoading,
            child: CustomScrollView(
              slivers: [
                _buildPremiumAppBar(context, entity),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfoDense(entity),
                        const Divider(height: 1, thickness: 1, color: AppColors.backgroundLightGrey),
                        _buildActionStrip(),
                        const Divider(height: 1, thickness: 1, color: AppColors.backgroundLightGrey),
                        _buildPaidBySection(entity),
                        _buildSplitsList(entity),
                        const Divider(height: 1, thickness: 1, color: AppColors.backgroundLightGrey),
                        _buildCommentsSection(entity),
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumAppBar(BuildContext context, ExpenseDetailEntity entity) {
    final formatter = NumberFormat('#,##0.00', 'en_IN');

    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primary,
      expandedHeight: 240,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Dark Teal solid background (handled by appBar color usually, but safe here)
            Container(color: AppColors.primary),
            // Subtle Top-Left Gradient Overlay to add premium feel
            Positioned(
              left: -100,
              top: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 48.0, bottom: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            image: entity.group?.groupIcon != null
                                ? DecorationImage(image: CachedNetworkImageProvider(entity.group!.groupIcon!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: entity.group?.groupIcon == null ? const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24) : null,
                        ),
                        const SizedBox(width: 16),
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Total Expense",
                                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "₹${formatter.format(entity.totalAmount)}",
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      entity.description,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoDense(ExpenseDetailEntity entity) {
    String formattedDate = "Unknown Date";
    try {
      final parsed = DateTime.parse(entity.expenseDate);
      formattedDate = DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Date", formattedDate),
              _buildInfoColumn("Added By", entity.createdBy.fullName),
              _buildInfoColumn("Group", entity.group?.name ?? "Non-group"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: AppColors.iconGrey, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(color: AppColors.textBlack, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionStrip() {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextBtn(Icons.receipt_rounded, "View Receipt"),
          Container(width: 1, height: 24, color: AppColors.backgroundLightGrey),
          _buildTextBtn(Icons.history_rounded, "Activity Log"),
        ],
      ),
    );
  }

  Widget _buildTextBtn(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textBlack, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(color: AppColors.textBlack, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidBySection(ExpenseDetailEntity entity) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceWhite, // slight off-white separation
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundLightGrey,
              image: entity.paidBy.avatar != null
                  ? DecorationImage(image: CachedNetworkImageProvider(entity.paidBy.avatar!), fit: BoxFit.cover)
                  : null,
            ),
            child: entity.paidBy.avatar == null ? const Icon(Icons.person, color: AppColors.textGrey, size: 20) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Paid by", style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
                Text(
                  entity.paidBy.fullName,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                ),
              ],
            ),
          ),
          Text(
            "₹${NumberFormat('#,##0.00', 'en_IN').format(entity.totalAmount)}",
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textBlack),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitsList(ExpenseDetailEntity entity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 8),
            child: Text(
              "Split Details",
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.iconGrey, letterSpacing: 0.5),
            ),
          ),
          ...entity.splits.map((split) {
            final isOwed = split.type != "participant";
            final amountText = isOwed ? "Owes" : "Participated";

            return _buildSplitListItem(name: split.fullName, avatarUrl: split.avatar, subText: amountText, amount: split.amount, isOwed: isOwed);
          }),
        ],
      ),
    );
  }

  Widget _buildSplitListItem({required String name, String? avatarUrl, required String subText, required double amount, required bool isOwed}) {
    final amountColor = isOwed ? AppColors.warningOrange : AppColors.textGrey;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundLightGrey,
                image: avatarUrl != null ? DecorationImage(image: CachedNetworkImageProvider(avatarUrl), fit: BoxFit.cover) : null,
                border: Border.all(color: AppColors.borderGreyLight, width: 0.5),
              ),
              child: avatarUrl == null ? const Icon(Icons.person, size: 18, color: AppColors.textGrey) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                  ),
                  Text(subText, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
                ],
              ),
            ),
            Text(
              "₹${NumberFormat('#,##0.##', 'en_IN').format(amount)}",
              style: GoogleFonts.outfit(fontSize: 15, color: amountColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(ExpenseDetailEntity entity) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Comments",
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.iconGrey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGreyLight),
            ),
            child: TextField(
              style: GoogleFonts.outfit(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: GoogleFonts.outfit(color: AppColors.iconGrey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fallback entity to render the Skeleton properly.
  ExpenseDetailEntity _getMockEntity() {
    return const ExpenseDetailEntity(
      id: "",
      description: "Loading...",
      expenseType: "expense",
      totalAmount: 1000.0,
      expenseDate: "2026-02-21T00:00:00+00:00",
      createdAt: "2026-02-21T00:00:00+00:00",
      paidBy: ExpenseUserEntity(id: "", fullName: "User Name"),
      createdBy: ExpenseUserEntity(id: "", fullName: "User Name"),
      splits: [
        ExpenseSplitEntity(type: "you_owe", amount: 500, userId: "1", fullName: "Test User"),
        ExpenseSplitEntity(type: "participant", amount: 500, userId: "2", fullName: "Test User"),
      ],
      yourSummary: ExpenseSummaryEntity(youOwe: 500, youPaid: 0, netEffect: -500),
      monthlyTrends: [],
      comments: [],
    );
  }
}
