// ── Core Enums ─────────────────────────────────────────────────────────────

enum AppAlertType { success, error, warning, info }

enum RefreshType {
  home,
  groups,
  friends,
  activity,
  groupDetail,
  friendDetail,
  expenseDetail,
}

// ── Auth & Account Enums ───────────────────────────────────────────────────

enum LoginStatus {
  initial,
  loading,
  googleLoading,
  resendLoading,
  success,
  failure,
  registerNavigation,
  resendSuccess,
}

enum AccountStatus { initial, loading, success, failure }

enum FeedbackStatus { initial, loading, success, failure }

enum ProfileStatus { initial, loading, success, failure }

// ── Expenses & Analytics Enums ──────────────────────────────────────────────

enum SplitType {
  equal,
  exact,
  percentage,
  shares,
}

enum ExpenseOrigin {
  group,
  friend,
  global,
  personal,
}

enum ExpenseStatus { initial, loading, success, failure, validationError }

enum SettleUpStatus { initial, loading, success, failure }

enum PersonalExpenseFilter {
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

enum AnalyticsFilter {
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

enum ExpenseBreakdownStatus { initial, loading, success, failure }

// ── Recurring Expenses Enums ──────────────────────────────────────────────

enum RecurringExpensesStatus { initial, loading, loaded, failure }

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

extension RecurrenceFrequencyX on RecurrenceFrequency {
  String get displayName {
    switch (this) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }
}

// ── Friends Enums ──────────────────────────────────────────────────────────

enum FriendsStatus { initial, loading, success, failure }

enum FriendJoinStatus { initial, loading, success, failure }

enum FriendRequestsStatus { initial, loading, success, failure }

enum RespondStatus { initial, loading, success, failure }

enum FriendDetailExpenseStatus { initial, loading, success, failure }

// ── Groups Enums ───────────────────────────────────────────────────────────

enum GroupType {
  trip('trip'),
  home('home'),
  couple('couple'),
  other('other');

  final String name;
  const GroupType(this.name);
}

enum GroupPermission {
  editGroup,
  deleteGroup,
  inviteMembers,
  addMembers,
  exitGroup,
  removeMember,
  changeRole,
}

enum GroupsStatus { initial, loading, success, failure }

enum GroupDetailStatus { initial, loading, success, failure }

enum GroupDetailExpenseStatus { initial, loading, success, failure }

enum CreateGroupStatus { initial, loading, success, failure }

enum JoinGroupStatus { initial, loading, success, failure }

enum AddMembersStatus { initial, loading, loaded, failure }

enum AddMembersSubmitStatus { initial, submitting, success, failure }

// ── Home & Dashboard Enums ────────────────────────────────────────────────

enum HomeDashboardStatus { initial, loading, success, failure }

enum HomeDashboardFilter {
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

// ── Activity Enums ─────────────────────────────────────────────────────────

enum ActivityType {
  settlement,
  expense,
  payment,
  modification,
  added,
  removed,
  deleted,
  restored,
  roleUpdated,
  groupCreated,
  limitExceeded,
  unknown,
}
