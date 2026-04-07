import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Data
import 'data/datasources/supabase_datasource.dart';
import 'data/repositories/quote_repository_impl.dart';
import 'data/repositories/user_settings_repository_impl.dart';

// Domain
import 'domain/repositories/quote_repository_interface.dart';
import 'domain/repositories/user_settings_repository_interface.dart';
import 'domain/usecases/quote_usecases.dart';
import 'domain/usecases/user_settings_usecases.dart';

// Presentation
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/quote/quote_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // External
  getIt.registerLazySingleton(() => Supabase.instance.client);

  // Data Sources
  getIt.registerLazySingleton<ISupabaseDataSource>(
    () => SupabaseDataSource(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<IQuoteRepository>(
    () => QuoteRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<IUserSettingsRepository>(
    () => UserSettingsRepositoryImpl(getIt()),
  );

  // Use Cases - Quotes
  getIt.registerLazySingleton(() => GetQuotesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetQuotesByCategoryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetRandomQuoteUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateQuoteUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateQuoteUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteQuoteUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCategoriesUseCase(getIt()));

  // Use Cases - Settings
  getIt.registerLazySingleton(() => GetUserSettingsUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateUserSettingsUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateFrequencyTypeUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateDailyLimitUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateSelectedCategoriesUseCase(getIt()));
  getIt.registerLazySingleton(() => ToggleReminderEnabledUseCase(getIt()));
  getIt.registerLazySingleton(() => IncrementReminderCountUseCase(getIt()));

  // BLoCs
  getIt.registerFactory(() => AuthBloc(supabaseClient: getIt()));
  getIt.registerFactory(() => QuoteBloc(
        getQuotesUseCase: getIt(),
        getQuotesByCategoryUseCase: getIt(),
        getRandomQuoteUseCase: getIt(),
        createQuoteUseCase: getIt(),
        updateQuoteUseCase: getIt(),
        deleteQuoteUseCase: getIt(),
        getCategoriesUseCase: getIt(),
      ));
  getIt.registerFactory(() => SettingsBloc(
        getUserSettingsUseCase: getIt(),
        updateUserSettingsUseCase: getIt(),
        updateFrequencyTypeUseCase: getIt(),
        updateDailyLimitUseCase: getIt(),
        updateSelectedCategoriesUseCase: getIt(),
        toggleReminderEnabledUseCase: getIt(),
        incrementReminderCountUseCase: getIt(),
      ));
}
