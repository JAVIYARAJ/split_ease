import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:split_ease/features/auth/presentation/login/pages/login_page.dart';
import 'package:split_ease/features/auth/presentation/register/bloc/register_bloc.dart';
import 'package:split_ease/features/auth/presentation/register/pages/register_page.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_bloc.dart';
import 'package:split_ease/features/expenses/presentation/pages/expense_detail_page.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:split_ease/features/groups/presentation/bloc/join_group_bloc.dart';
import 'package:split_ease/features/home/presentation/pages/home_page.dart';
import 'package:split_ease/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:split_ease/features/welcome/presentation/cubit/welcome_cubit.dart';
import 'package:split_ease/features/welcome/presentation/pages/welcome_page.dart';

import '../../features/account/presentation/bloc/category_limits/category_limits_bloc.dart';
import '../../features/account/presentation/pages/category_limits_page.dart';
import '../../features/account/presentation/pages/user_qr_page.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/expenses/presentation/bloc/personal_expenses/personal_expenses_bloc.dart';
import '../../features/expenses/presentation/bloc/settle_up/settle_up_cubit.dart';
// Import pages
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/category_selection_page.dart';
import '../../features/expenses/presentation/pages/date_selection_page.dart';
import '../../features/expenses/presentation/pages/expense_note_page.dart';
import '../../features/expenses/presentation/pages/expense_pdf_preview_page.dart';
import '../../features/expenses/presentation/pages/payer_selection_page.dart';
import '../../features/expenses/presentation/pages/personal_expenses_page.dart';
import '../../features/expenses/presentation/pages/record_payment_page.dart';
import '../../features/expenses/presentation/pages/settle_up_selection_page.dart';
import '../../features/expenses/presentation/pages/split_options_page.dart';
import '../../features/friends/presentation/bloc/friend_detail_bloc.dart';
import '../../features/friends/presentation/pages/friend_detail_page.dart';
import '../../features/friends/presentation/pages/friend_requests_page.dart';
import '../../features/groups/presentation/bloc/create_group_bloc.dart';
import '../../features/groups/presentation/pages/add_members_page.dart';
import '../../features/groups/presentation/pages/create_group_page.dart';
import '../../features/groups/presentation/pages/enter_invite_code_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import '../../features/groups/presentation/pages/group_qr_page.dart';
import '../../features/groups/presentation/pages/group_settings_page.dart';
import '../../features/groups/presentation/pages/qr_scanner_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/splash/presentation/pages/splash_pages.dart';
import '../../features/recurring_expenses/presentation/bloc/recurring_expenses_bloc.dart';
import '../../features/recurring_expenses/presentation/bloc/recurring_expenses_event.dart';
import '../../features/recurring_expenses/presentation/pages/recurring_expenses_page.dart';
import '../../features/recurring_expenses/presentation/pages/add_edit_recurring_expense_page.dart';
import '../../features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import '../../injection_container.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<SplashCubit>(),
              child: SplashPages(),
            ));
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<WelcomeCubit>(),
              child: WelcomePage(),
            ));
      case AppRoutes.login:
        return MaterialPageRoute(
            builder: (_) =>
                BlocProvider(
                  create: (context) => sl<LoginBloc>(),
                  child: LoginPage(),
                ));
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<RegisterBloc>(),
              child: RegisterPage(),
            ));
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<HomeBloc>(),
              child: HomePage(),
            ));
      case AppRoutes.createGroup:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<CreateGroupBloc>(),
              child: const CreateGroupPage(),
            ), settings: RouteSettings(name: settings.name, arguments: settings.arguments));
      case AppRoutes.groupDetail:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<GroupDetailBloc>(),
              child: GroupDetailPage(),
            ),
            settings: RouteSettings(arguments: settings.arguments, name: settings.name)
        );
      case AppRoutes.friendDetail:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<FriendDetailBloc>(),
              child: const FriendDetailPage(),
            ),
            settings: RouteSettings(arguments: settings.arguments, name: settings.name)
        );
      case AppRoutes.enterInviteCode:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<JoinGroupBloc>(),
              child: EnterInviteCodePage(),
            ));
      case AppRoutes.addExpense:
        return MaterialPageRoute(
            builder: (_) =>
                BlocProvider(
                  create: (context) => sl<ExpenseBloc>(),
                  child: AddExpensePage(),
                ),
            settings: RouteSettings(arguments: settings.arguments, name: settings.name));
      case AppRoutes.payerSelection:
        return MaterialPageRoute(
            builder: (_) => const PayerSelectionPage(),
            settings: RouteSettings(arguments: settings.arguments, name: settings.name));
      case AppRoutes.splitOptions:
        return MaterialPageRoute(
            builder: (_) => const SplitOptionsPage(),
            settings: RouteSettings(arguments: settings.arguments, name: settings.name));
      case AppRoutes.dateSelection:
        return MaterialPageRoute(
            builder: (_) => const DateSelectionPage(),
            settings: RouteSettings(arguments: settings.arguments, name: settings.name));
      case AppRoutes.expanseDetail:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (context) => sl<ExpenseDetailBloc>(),
              child: const ExpenseDetailPage(),
            ),
            settings: RouteSettings(arguments: settings.arguments, name: settings.name)
        );
      case AppRoutes.addMembers:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddMembersPage(groupId: args['groupId']),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.groupSettings:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GroupSettingsPage(groupId: args['groupId']),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.friendRequests:
        return MaterialPageRoute(
          builder: (_) => const FriendRequestsPage(),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.qrScanner:
        return MaterialPageRoute(
          builder: (_) => const QrScannerPage(),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.editProfile:
        final user = settings.arguments as UserEntity;
        return MaterialPageRoute(
          builder: (_) => EditProfilePage(user: user),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.userQr:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => UserQrPage(
            userId: args['userId'],
            userName: args['userName'],
            userAvatar: args['userAvatar'],
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.groupQr:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GroupQrPage(
            inviteCode: args['inviteCode'],
            groupName: args['groupName'],
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.expensePdfPreview:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ExpensePdfPreviewPage(
            pdfPath: args['pdfPath'],
            expenseDescription: args['expenseDescription'],
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.expenseNote:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ExpenseNotePage(
            initialNote: args['initialNote'] ?? '',
            maxCharacters: args['maxCharacters'] ?? 1000,
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.settleUpSelection:
        return MaterialPageRoute(
          builder: (_) => const SettleUpSelectionPage(),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.recordPayment:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<SettleUpCubit>(),
            child: const RecordPaymentPage(),
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.categorySelection:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CategorySelectionPage(
            categories: args['categories'],
            selectedCategory: args['selectedCategory'],
            lastUsedCategoryId: args['lastUsedCategoryId'],
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.categoryLimits:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<CategoryLimitsBloc>(),
            child: const CategoryLimitsPage(),
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.personalExpenses:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<PersonalExpensesBloc>(),
            child: const PersonalExpensesPage(),
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.recurringExpenses:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<RecurringExpensesBloc>()..add(LoadRecurringExpensesEvent()),
            child: const RecurringExpensesPage(),
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      case AppRoutes.addEditRecurringExpense:
        final existingTemplate = settings.arguments as RecurringExpenseEntity?;
        return MaterialPageRoute(
          builder: (context) => AddEditRecurringExpensePage(
            existingTemplate: existingTemplate,
          ),
          settings: RouteSettings(arguments: settings.arguments, name: settings.name),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }
}
