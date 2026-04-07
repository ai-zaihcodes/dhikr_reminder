part of 'settings_bloc.dart';

/// Settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch user settings
class SettingsRequested extends SettingsEvent {
  const SettingsRequested();
}

/// Update user settings
class SettingsUpdated extends SettingsEvent {
  final UserSettingsEntity settings;

  const SettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Change frequency type
class FrequencyTypeChanged extends SettingsEvent {
  final FrequencyType type;

  const FrequencyTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Change daily limit
class DailyLimitChanged extends SettingsEvent {
  final int? limit;

  const DailyLimitChanged(this.limit);

  @override
  List<Object?> get props => [limit];
}

/// Change selected categories
class SelectedCategoriesChanged extends SettingsEvent {
  final List<String> categories;

  const SelectedCategoriesChanged(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Toggle reminder enabled
class ReminderToggled extends SettingsEvent {
  final bool enabled;

  const ReminderToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Increment reminder count (when reminder is shown)
class ReminderShown extends SettingsEvent {
  const ReminderShown();
}
