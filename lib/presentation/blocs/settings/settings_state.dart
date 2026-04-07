part of 'settings_bloc.dart';

/// Settings states
enum SettingsStatus { initial, loading, loaded, error }

/// Settings State class
class SettingsState extends Equatable {
  final SettingsStatus status;
  final UserSettingsEntity? settings;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    UserSettingsEntity? settings,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }

  bool get isReminderEnabled => settings?.isEnabled ?? false;
  bool get isLimitedMode =>
      settings?.frequencyType == FrequencyType.limitedPerDay;
  int get remindersShown => settings?.remindersShownToday ?? 0;
  int? get dailyLimit => settings?.dailyLimit;
  bool get hasReachedLimit => settings?.hasReachedDailyLimit ?? false;

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
