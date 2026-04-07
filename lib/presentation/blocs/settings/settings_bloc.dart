import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_settings_entity.dart';
import '../../../domain/usecases/user_settings_usecases.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// BLoC for managing user settings
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetUserSettingsUseCase _getUserSettingsUseCase;
  final UpdateUserSettingsUseCase _updateUserSettingsUseCase;
  final UpdateFrequencyTypeUseCase _updateFrequencyTypeUseCase;
  final UpdateDailyLimitUseCase _updateDailyLimitUseCase;
  final UpdateSelectedCategoriesUseCase _updateSelectedCategoriesUseCase;
  final ToggleReminderEnabledUseCase _toggleReminderEnabledUseCase;
  final IncrementReminderCountUseCase _incrementReminderCountUseCase;

  SettingsBloc({
    required GetUserSettingsUseCase getUserSettingsUseCase,
    required UpdateUserSettingsUseCase updateUserSettingsUseCase,
    required UpdateFrequencyTypeUseCase updateFrequencyTypeUseCase,
    required UpdateDailyLimitUseCase updateDailyLimitUseCase,
    required UpdateSelectedCategoriesUseCase updateSelectedCategoriesUseCase,
    required ToggleReminderEnabledUseCase toggleReminderEnabledUseCase,
    required IncrementReminderCountUseCase incrementReminderCountUseCase,
  })  : _getUserSettingsUseCase = getUserSettingsUseCase,
        _updateUserSettingsUseCase = updateUserSettingsUseCase,
        _updateFrequencyTypeUseCase = updateFrequencyTypeUseCase,
        _updateDailyLimitUseCase = updateDailyLimitUseCase,
        _updateSelectedCategoriesUseCase = updateSelectedCategoriesUseCase,
        _toggleReminderEnabledUseCase = toggleReminderEnabledUseCase,
        _incrementReminderCountUseCase = incrementReminderCountUseCase,
        super(const SettingsState()) {
    on<SettingsRequested>(_onSettingsRequested);
    on<SettingsUpdated>(_onSettingsUpdated);
    on<FrequencyTypeChanged>(_onFrequencyTypeChanged);
    on<DailyLimitChanged>(_onDailyLimitChanged);
    on<SelectedCategoriesChanged>(_onSelectedCategoriesChanged);
    on<ReminderToggled>(_onReminderToggled);
    on<ReminderShown>(_onReminderShown);
  }

  Future<void> _onSettingsRequested(
    SettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final result = await _getUserSettingsUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      )),
    );
  }

  Future<void> _onSettingsUpdated(
    SettingsUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final result = await _updateUserSettingsUseCase(event.settings);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      )),
    );
  }

  Future<void> _onFrequencyTypeChanged(
    FrequencyTypeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final result = await _updateFrequencyTypeUseCase(event.type);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      )),
    );
  }

  Future<void> _onDailyLimitChanged(
    DailyLimitChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final result = await _updateDailyLimitUseCase(event.limit);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      )),
    );
  }

  Future<void> _onSelectedCategoriesChanged(
    SelectedCategoriesChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final result = await _updateSelectedCategoriesUseCase(event.categories);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      )),
    );
  }

  Future<void> _onReminderToggled(
    ReminderToggled event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final result = await _toggleReminderEnabledUseCase(event.enabled);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      )),
    );
  }

  Future<void> _onReminderShown(
    ReminderShown event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _incrementReminderCountUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      )),
    );
  }
}
