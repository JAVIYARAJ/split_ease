import 'package:get_it/get_it.dart';
import 'package:split_ease/features/account/data/datasources/account_remote_data_source.dart';
import 'package:split_ease/features/account/data/repository/account_repository_impl.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';
import 'package:split_ease/features/account/domain/usecases/account_logout.dart';
import 'package:split_ease/features/account/presentation/bloc/account_bloc.dart';
import 'package:split_ease/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:split_ease/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:split_ease/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:split_ease/features/auth/domain/usecases/user_sign_up.dart';
import 'package:split_ease/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:split_ease/features/auth/presentation/register/bloc/register_bloc.dart';
import 'package:split_ease/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:split_ease/features/splash/data/datasources/splash_remote_data_source.dart';
import 'package:split_ease/features/splash/data/repository/splash_repository_impl.dart';
import 'package:split_ease/features/splash/domain/repository/splash_repository.dart';
import 'package:split_ease/features/splash/domain/usecases/user_active_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/secrets/app_secrets.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/user_login.dart';

import 'features/groups/presentation/bloc/groups_bloc.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';
import 'features/welcome/presentation/cubit/welcome_cubit.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'core/common/cubit/app_user_cubit.dart';


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

  // Core Cubits
  sl.registerLazySingleton(() => AppUserCubit());
}



/// Helper to aggregate all feature-module registrations.
void _features() {
  _splash();
  _auth();
  _welcome();
  _home();
}

void _splash() {
  sl.registerFactory<SplashRemoteDataSource>(() => SplashRemoteDataSourceImpl(client: sl<SupabaseClient>()));

  sl.registerFactory<SplashRepository>(() => SplashRepositoryImpl(dataSource: sl<SplashRemoteDataSource>()));

  sl.registerFactory(() => UserActiveSession(sl<SplashRepository>()));

  // Register SplashCubit. Factories return a new instance every time they are called.
  // ViewModels/Blocs/Cubits are usually factories so that their state resets when the screen is recreated.
  sl.registerLazySingleton(() => SplashCubit(sl<UserActiveSession>(), sl<AppUserCubit>()));
}

void _welcome() {
  sl.registerFactory(() => WelcomeCubit());
}

void _home() {
  // Presentation Layer - BLoC (Contains Mock Data Logic)
  sl.registerFactory(() => HomeBloc());
  sl.registerLazySingleton(() => FriendsBloc(),);
  sl.registerLazySingleton(() => GroupsBloc(),);
  sl.registerLazySingleton(() => ActivityBloc(),);

  sl.registerFactory<AccountRemoteDataSource>(() => AccountRemoteDataSourceImpl(sl<SupabaseClient>()),);

  sl.registerFactory<AccountRepository>(() => AccountRepositoryImpl(accountRemoteDataSource: sl<AccountRemoteDataSource>()),);

  sl.registerFactory(() => AccountLogout(sl<AccountRepository>()),);

  sl.registerLazySingleton(() => AccountBloc(accountLogout: sl<AccountLogout>(), appUserCubit: sl<AppUserCubit>()),);

}

/// Registers dependencies for the Authentication feature following Clean Architecture.
/// Flow: Data Source -> Repository -> Use Case -> Bloc
void _auth() {
  // 1. Data Sources (Lowest Level)
  // Handles raw data fetching (API calls, Database, etc.)
  sl.registerFactory<AuthRemoteDataSource>(() => AuthDataSourceDataSourceImpl(client: sl<SupabaseClient>()));

  // 2. Repositories (Data Layer Abstraction)
  // Acts as a bridge between Data Sources and Domain Layer.
  // We register the interface 'AuthRepository' but provide the implementation 'AuthRepositoryImpl'.
  // This allows for easy swapping of implementations (e.g., for testing).
  sl.registerFactory<AuthRepository>(() => AuthRepositoryImpl(authRemoteDataSource: sl<AuthRemoteDataSource>()));

  // 3. Use Cases (Domain Layer)
  // Encapsulates specific business logic. ViewModels/Blocs interact with these.
  sl.registerFactory(() => UserLogin(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => UserSignUp(authRepository: sl<AuthRepository>()));

  // 4. Blocs / State Management (Presentation Layer)
  // Receives user input, calls Use Cases, and emits States to the UI.
  sl.registerFactory(() => LoginBloc(sl<UserLogin>(), sl<AppUserCubit>()));
  sl.registerLazySingleton(() => RegisterBloc(sl<UserSignUp>(), sl<AppUserCubit>()));
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
