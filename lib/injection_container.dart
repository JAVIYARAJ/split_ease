import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_ease/features/account/data/datasources/account_remote_data_source.dart';
import 'package:split_ease/features/account/data/repository/account_repository_impl.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';
import 'package:split_ease/features/account/domain/usecases/account_logout.dart';
import 'package:split_ease/features/account/domain/usecases/submit_app_feedback_usecase.dart';
import 'package:split_ease/features/account/presentation/bloc/account_bloc.dart';
import 'package:split_ease/features/account/presentation/bloc/feedback/feedback_cubit.dart';
import 'package:split_ease/features/activity/data/datasources/activity_remote_data_source.dart';
import 'package:split_ease/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:split_ease/features/activity/domain/repositories/activity_repository.dart';
import 'package:split_ease/features/activity/domain/usecases/get_activity_feed_usecase.dart';
import 'package:split_ease/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:split_ease/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:split_ease/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:split_ease/features/auth/domain/usecases/resend_confirmation_email.dart';
import 'package:split_ease/features/auth/domain/usecases/user_sign_up.dart';
import 'package:split_ease/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:split_ease/features/auth/presentation/register/bloc/register_bloc.dart';
import 'package:split_ease/features/friends/data/datasources/friends_remote_data_source.dart';
import 'package:split_ease/features/friends/data/repository/friends_repository_impl.dart';
import 'package:split_ease/features/friends/domain/repository/friends_repository.dart';
import 'package:split_ease/features/friends/domain/usecases/friend_join.dart';
import 'package:split_ease/features/friends/domain/usecases/get_my_friends.dart';
import 'package:split_ease/features/friends/domain/usecases/get_friend_requests.dart';
import 'package:split_ease/features/friends/domain/usecases/get_unread_friend_request_count.dart';
import 'package:split_ease/features/friends/domain/usecases/respond_to_friend_request.dart';
import 'package:split_ease/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_requests_bloc.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_bloc.dart';
import 'package:split_ease/features/friends/domain/usecases/get_friend_expense_history_usecase.dart';
import 'package:split_ease/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:split_ease/features/groups/data/repository/group_repository_impl.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';
import 'package:split_ease/features/groups/domain/usecases/get_all_groups.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_detail.dart';
import 'package:split_ease/features/groups/domain/usecases/group_create.dart';
import 'package:split_ease/features/groups/domain/usecases/check_invite_code.dart';
import 'package:split_ease/features/groups/domain/usecases/join_group.dart';
import 'package:split_ease/features/groups/domain/usecases/update_group.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_settings_bloc.dart';
import 'package:split_ease/features/groups/domain/usecases/leave_group.dart';
import 'package:split_ease/features/groups/domain/usecases/delete_group.dart';
import 'package:split_ease/features/groups/presentation/bloc/join_group_bloc.dart';
import 'package:split_ease/features/groups/domain/usecases/get_friends_with_group_status.dart';
import 'package:split_ease/features/groups/domain/usecases/add_friends_to_group.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_expense_history.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_members.dart';
import 'package:split_ease/features/groups/domain/usecases/get_common_groups_usecase.dart';
import 'package:split_ease/features/groups/domain/usecases/remove_group_member.dart';
import 'package:split_ease/features/groups/domain/usecases/update_member_role.dart';
import 'package:split_ease/features/groups/presentation/bloc/add_members_bloc.dart';
import 'package:split_ease/features/splash/data/datasources/splash_remote_data_source.dart';
import 'package:split_ease/features/splash/data/repository/splash_repository_impl.dart';
import 'package:split_ease/features/splash/domain/repository/splash_repository.dart';
import 'package:split_ease/features/splash/domain/usecases/user_active_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/common/cubit/app_user_cubit.dart';
import 'core/secrets/app_secrets.dart';
import 'core/services/image_picker_service.dart';
import 'core/services/realtime_service.dart';
import 'core/services/data_refresh_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'features/auth/domain/usecases/user_login.dart';

import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/expenses/presentation/bloc/payer/payer_bloc.dart';
import 'features/expenses/presentation/bloc/split/split_bloc.dart';
import 'features/expenses/presentation/bloc/date/date_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_bloc.dart';
import 'package:split_ease/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'features/expenses/data/datasources/expense_remote_data_source.dart';
import 'features/expenses/data/repositories/expense_repository_impl.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/update_expense.dart';
import 'package:split_ease/features/expenses/domain/usecases/add_expense_comment_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/settle_up_usecase.dart';
import 'package:split_ease/features/expenses/presentation/bloc/settle_up/settle_up_cubit.dart';

import 'package:split_ease/features/expenses/domain/usecases/get_expense_detail_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/restore_expense_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_participants_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_categories.dart';
import 'features/groups/domain/usecases/group_insert_icon.dart';
import 'features/groups/presentation/bloc/groups_bloc.dart';
import 'features/groups/presentation/bloc/create_group_bloc.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/welcome/presentation/cubit/welcome_cubit.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/data/datasources/app_settings_local_data_source.dart';
import 'core/data/repositories/app_settings_repository_impl.dart';
import 'core/domain/repositories/app_settings_repository.dart';
import 'core/domain/usecases/is_first_time_user.dart';
import 'core/domain/usecases/set_first_time_user_seen.dart';

// Service Locator (Shared Instance)
// This is the central repository where all dependencies (objects) are stored and retrieved.
// We use 'GetIt' to manage dependency injection throughout the app.
final sl = GetIt.instance;

/// Initializer for all dependencies.
/// Call this method in `main()` before running the app.
Future<void> init() async {
  await _core(); // Initialize core external services (e.g., Supabase, Firebase, LocalStorage)
  _features(); // Initialize feature-specific dependencies
}

/// Registers core system-level dependencies.
Future<void> _core() async {
  // Initialize Supabase client
  final sc = await Supabase.initialize(url: AppSecrets.supabaseUrl, anonKey: AppSecrets.supabaseAnonKey);

  // Register SupabaseClient as a Lazy Singleton.
  // 'LazySingleton' means the instance is created only when it's first requested,
  // and the same instance is returned for subsequent calls.
  sl.registerLazySingleton(() => sc.client);

  // Services
  sl.registerLazySingleton(() => ImagePicker());
  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl(sl()));
  sl.registerLazySingleton<RealtimeService>(() => RealtimeService(client: sl<SupabaseClient>()));
  sl.registerLazySingleton(() => DataRefreshCubit());

  // Local Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // App Settings
  sl.registerLazySingleton<AppSettingsLocalDataSource>(() => AppSettingsLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AppSettingsRepository>(() => AppSettingsRepositoryImpl(sl()));
  sl.registerLazySingleton(() => IsFirstTimeUser(sl()));
  sl.registerLazySingleton(() => SetFirstTimeUserSeen(sl()));

  // Core Cubits
  sl.registerLazySingleton(() => AppUserCubit());
}



/// Helper to aggregate all feature-module registrations.
void _features() {
  _splash();
  _auth();
  _welcome();
  _home();
  _friend();
  _group();
  _inviteCode();
  _profile();
  _expense();
}

void _expense() {
  // Use cases
  sl.registerLazySingleton(() => AddExpenseUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExpense(repository: sl()));
  sl.registerLazySingleton(() => GetExpenseDetailUseCase(sl()));

  sl.registerLazySingleton(() => DeleteExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenseParticipantsUsecase(repository: sl()));
  sl.registerLazySingleton(() => AddExpenseCommentUseCase(sl()));
  sl.registerLazySingleton(() => SettleUpUseCase(sl()));
  sl.registerLazySingleton(() => RestoreExpenseUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<ExpenseRemoteDataSource>(() => ExpenseRemoteDataSourceImpl(client: sl<SupabaseClient>())); // Note: explicit cast to SupabaseClient if needed, or just sl() since we registered sc.client as SupabaseClient

  sl.registerLazySingleton(() => GetCommonGroupsUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenseCategories(sl()));

  sl.registerFactory(() => ExpenseBloc(
        addExpenseUseCase: sl(),
        updateExpenseUseCase: sl(),
        getGroupMembers: sl(),
        getCommonGroupsUseCase: sl(),
        getExpenseParticipantsUsecase: sl(),
        getExpenseCategories: sl(),
        dataRefreshCubit: sl(),
      ));

  sl.registerFactory(() => SettleUpCubit(
        settleUpUseCase: sl(),
        getCommonGroupsUseCase: sl(),
        dataRefreshCubit: sl(),
      ));
  sl.registerFactory(() => ExpenseDetailBloc(
        sl<GetExpenseDetailUseCase>(),
        sl<DeleteExpenseUseCase>(),
        sl<RestoreExpenseUseCase>(),
        sl<GetGroupMembers>(),
        sl<AddExpenseCommentUseCase>(),
        sl<AppUserCubit>(),
        sl<DataRefreshCubit>(),
      ));
  sl.registerFactory(() => PayerBloc());
  sl.registerFactory(() => SplitBloc());
  sl.registerFactory(() => DateBloc());
}

void _profile() {
  sl.registerFactory<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(client: sl<SupabaseClient>()));
  sl.registerFactory<ProfileRepository>(() => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()));
  sl.registerFactory(() => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerFactory(() => ProfileBloc(
        updateProfileUseCase: sl<UpdateProfileUseCase>(),
        appUserCubit: sl<AppUserCubit>(),
        imagePickerService: sl<ImagePickerService>(),
      ));
}

void _group() {

  sl.registerFactory<GroupRemoteDataSource>(() => GroupRemoteDataSourceImpl(client: sl<SupabaseClient>()));

  sl.registerFactory<GroupRepository>(() => GroupRepositoryImpl(dataSource: sl<GroupRemoteDataSource>()));

  sl.registerFactory(() => GroupInsertIcon(groupRepository: sl<GroupRepository>()),);

  sl.registerFactory(() => GroupCreate(groupRepository: sl<GroupRepository>()),);
  
  sl.registerFactory(() => CheckInviteCode(groupRepository: sl<GroupRepository>()));

  sl.registerFactory(() => UpdateGroup(repository: sl<GroupRepository>()),);

  sl.registerFactory(() => CreateGroupBloc(sl<ImagePickerService>(),sl<GroupInsertIcon>(),sl<GroupCreate>(), sl<CheckInviteCode>(),sl<UpdateGroup>(), sl<DataRefreshCubit>()));


  sl.registerFactory(() => GetGroupDetail(groupRepository: sl<GroupRepository>()),);

  sl.registerFactory(() => GetGroupExpenseHistory(groupRepository: sl<GroupRepository>()),);

  sl.registerFactory(() => GroupDetailBloc(
    getGroupDetail: sl<GetGroupDetail>(),
    getGroupExpenseHistory: sl<GetGroupExpenseHistory>(),
  ));

  sl.registerFactory(() => LeaveGroup(groupRepository: sl<GroupRepository>()));
  sl.registerFactory(() => RemoveGroupMember(groupRepository: sl<GroupRepository>()));
  sl.registerFactory(() => DeleteGroup(groupRepository: sl<GroupRepository>()));
  sl.registerFactory(() => UpdateMemberRole(sl<GroupRepository>()));

  sl.registerFactory(() => GroupSettingsBloc(
    getGroupDetail: sl<GetGroupDetail>(),
    deleteGroup: sl<DeleteGroup>(),
    leaveGroup: sl<LeaveGroup>(),
    removeGroupMember: sl<RemoveGroupMember>(),
    updateMemberRole: sl<UpdateMemberRole>(),
    authRepository: sl<AuthRepository>(),
    getGroupExpenseHistory: sl<GetGroupExpenseHistory>(),
    dataRefreshCubit: sl<DataRefreshCubit>(),
  ));

  sl.registerFactory(() => GetFriendsWithGroupStatus(groupRepository: sl<GroupRepository>()));
  sl.registerFactory(() => AddFriendsToGroup(groupRepository: sl<GroupRepository>()));
  sl.registerFactory(() => GetGroupMembers(sl<GroupRepository>()));
  sl.registerFactory(() => AddMembersBloc(
    getFriendsWithGroupStatus: sl<GetFriendsWithGroupStatus>(),
    addFriendsToGroup: sl<AddFriendsToGroup>(),
    dataRefreshCubit: sl<DataRefreshCubit>(),
  ));
}

void _friend() {

}

void _splash() {
  sl.registerFactory<SplashRemoteDataSource>(() => SplashRemoteDataSourceImpl(client: sl<SupabaseClient>()));

  sl.registerFactory<SplashRepository>(() => SplashRepositoryImpl(dataSource: sl<SplashRemoteDataSource>()));

  sl.registerFactory(() => UserActiveSession(sl<SplashRepository>()));

  // Register SplashCubit. Factories return a new instance every time they are called.
  // ViewModels/Blocs/Cubits are usually factories so that their state resets when the screen is recreated.
  sl.registerLazySingleton(() => SplashCubit(sl<UserActiveSession>(), sl<AppUserCubit>(), sl<IsFirstTimeUser>()));
}

void _welcome() {
  sl.registerFactory(() => WelcomeCubit(sl<SetFirstTimeUserSeen>()));
}

void _home() {
  // Presentation Layer - BLoC (Contains Mock Data Logic)
  sl.registerFactory(() => HomeBloc());

  sl.registerFactory<FriendsRemoteDataSource>(() => FriendsRemoteDataSourceImpl(client: sl<SupabaseClient>()),);

  sl.registerFactory<FriendsRepository>(() => FriendsRepositoryImpl(friendsRemoteDataSource: sl<FriendsRemoteDataSource>()),);

  sl.registerFactory(() => FriendJoin(friendsRepository: sl<FriendsRepository>()),);
  sl.registerFactory(() => GetMyFriends(friendsRepository: sl<FriendsRepository>()),);
  sl.registerFactory(() => GetFriendRequests(friendsRepository: sl<FriendsRepository>()),);
  sl.registerFactory(() => RespondToFriendRequest(friendsRepository: sl<FriendsRepository>()),);

  sl.registerFactory(() => GetUnreadFriendRequestCount(friendsRepository: sl<FriendsRepository>()),);

  sl.registerFactory(() => FriendsBloc(friendJoin: sl<FriendJoin>(), getMyFriends: sl<GetMyFriends>(), getUnreadFriendRequestCount: sl<GetUnreadFriendRequestCount>(), dataRefreshCubit: sl<DataRefreshCubit>()),);
  sl.registerFactory(() => FriendRequestsBloc(getFriendRequests: sl<GetFriendRequests>(), respondToFriendRequest: sl<RespondToFriendRequest>(), dataRefreshCubit: sl<DataRefreshCubit>()),);

  sl.registerFactory(() => GetFriendExpenseHistoryUseCase(sl<FriendsRepository>()),);
  sl.registerFactory(() => FriendDetailBloc(getFriendExpenseHistoryUseCase: sl<GetFriendExpenseHistoryUseCase>()),);

  sl.registerFactory(() => GetAllGroups(groupRepository: sl<GroupRepository>()),);
  sl.registerFactory(() => GroupsBloc(getAllGroups: sl<GetAllGroups>()),);
  sl.registerFactory<ActivityRemoteDataSource>(() => ActivityRemoteDataSourceImpl(client: sl<SupabaseClient>()));
  sl.registerFactory<ActivityRepository>(() => ActivityRepositoryImpl(remoteDataSource: sl<ActivityRemoteDataSource>()));
  sl.registerFactory(() => GetActivityFeedUseCase(sl<ActivityRepository>()));
  sl.registerFactory(() => ActivityBloc(getActivityFeedUseCase: sl<GetActivityFeedUseCase>()));

  sl.registerFactory<AccountRemoteDataSource>(() => AccountRemoteDataSourceImpl(sl<SupabaseClient>()),);

  sl.registerFactory<AccountRepository>(() => AccountRepositoryImpl(accountRemoteDataSource: sl<AccountRemoteDataSource>()),);

  sl.registerFactory(() => AccountLogout(sl<AccountRepository>()),);
  sl.registerFactory(() => SubmitAppFeedbackUseCase(sl<AccountRepository>()),);

  sl.registerFactory(() => AccountBloc(
        accountLogout: sl<AccountLogout>(),
        appUserCubit: sl<AppUserCubit>(),
      ));
      
  sl.registerFactory(() => FeedbackCubit(sl<SubmitAppFeedbackUseCase>()));
}


/// Registers dependencies for the Authentication feature following Clean Architecture.
/// Flow: Data Source -> Repository -> Use Case -> Bloc
void _auth() {
  // 1. Data Sources (Lowest Level)
  // Handles raw data fetching (API calls, Database, etc.)
  sl.registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: sl<SupabaseClient>()));

  // 2. Repositories (Data Layer Abstraction)
  // Acts as a bridge between Data Sources and Domain Layer.
  // We register the interface 'AuthRepository' but provide the implementation 'AuthRepositoryImpl'.
  // This allows for easy swapping of implementations (e.g., for testing).
  sl.registerFactory<AuthRepository>(() => AuthRepositoryImpl(authRemoteDataSource: sl<AuthRemoteDataSource>()));

  // 3. Use Cases (Domain Layer)
  // Encapsulates specific business logic. ViewModels/Blocs interact with these.
  sl.registerFactory(() => UserLogin(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => UserSignUp(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => ResendConfirmationEmail(sl<AuthRepository>()));
  sl.registerFactory(() => GoogleSignInUseCase(sl<AuthRepository>()));

  // 4. Blocs / State Management (Presentation Layer)
  // Receives user input, calls Use Cases, and emits States to the UI.
  sl.registerFactory(() => LoginBloc(
        userLogin: sl<UserLogin>(),
        resendConfirmationEmail: sl<ResendConfirmationEmail>(),
        googleSignInUseCase: sl<GoogleSignInUseCase>(),
        appUserCubit: sl<AppUserCubit>(),
      ));
  sl.registerFactory(() => RegisterBloc(sl<UserSignUp>(), sl<GoogleSignInUseCase>(), sl<AppUserCubit>()));
}

void _inviteCode(){

  sl.registerFactory(() => JoinGroup(groupRepository: sl<GroupRepository>()),);

  sl.registerFactory(() => JoinGroupBloc(joinGroup: sl<JoinGroup>()),);
}

/* 
  Dependency Injection Flow Summary:
  
  UI (Presentation Layer)
    ⬇ calls
  Bloc/Cubit (State Management)
    ⬇ calls
  Use Cases (Domain Logic)
    ⬇ calls
  Repository Interface (Domain abstraction)
    ⬇ implemented by
  Repository Implementation (Data Layer)
    ⬇ calls
  Data Source (API/DB Wrapper)
    ⬇ calls
  External Client (Supabase/Dio/SharedPrefs)
*/
