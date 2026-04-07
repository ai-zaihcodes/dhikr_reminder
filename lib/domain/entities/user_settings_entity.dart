import 'package:equatable/equatable.dart';

/// Represents user settings and preferences
class UserSettingsEntity extends Equatable {
  final String userId;
  final FrequencyType frequencyType;
  final int? dailyLimit;
  final List<String> selectedCategories;
  final bool showTranslation;
  final bool isEnabled;
  final DateTime? lastReminderTime;
  final int remindersShownToday;
  final DateTime? lastResetDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserSettingsEntity({
    required this.userId,
    this.frequencyType = FrequencyType.everyUnlock,
    this.dailyLimit,
    this.selectedCategories = const [],
    this.showTranslation = true,
    this.isEnabled = true,
    this.lastReminderTime,
    this.remindersShownToday = 0,
    this.lastResetDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy with modified fields
  UserSettingsEntity copyWith({
    String? userId,
    FrequencyType? frequencyType,
    int? dailyLimit,
    List<String>? selectedCategories,
    bool? showTranslation,
    bool? isEnabled,
    DateTime? lastReminderTime,
    int? remindersShownToday,
    DateTime? lastResetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsEntity(
      userId: userId ?? this.userId,
      frequencyType: frequencyType ?? this.frequencyType,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      showTranslation: showTranslation ?? this.showTranslation,
      isEnabled: isEnabled ?? this.isEnabled,
      lastReminderTime: lastReminderTime ?? this.lastReminderTime,
      remindersShownToday: remindersShownToday ?? this.remindersShownToday,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if daily limit has been reached
  bool get hasReachedDailyLimit {
    if (frequencyType != FrequencyType.limitedPerDay) return false;
    if (dailyLimit == null) return false;
    return remindersShownToday >= dailyLimit!;
  }

  /// Check if reminder should be shown
  bool get shouldShowReminder {
    if (!isEnabled) return false;
    if (frequencyType == FrequencyType.limitedPerDay && hasReachedDailyLimit) {
      return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [
        userId,
        frequencyType,
        dailyLimit,
        selectedCategories,
        showTranslation,
        isEnabled,
        lastReminderTime,
        remindersShownToday,
        lastResetDate,
        createdAt,
        updatedAt,
      ];
}

/// Frequency types for reminders
enum FrequencyType {
  everyUnlock,
  limitedPerDay;

  String get displayName {
    switch (this) {
      case FrequencyType.everyUnlock:
        return 'Every Unlock';
      case FrequencyType.limitedPerDay:
        return 'Limited per Day';
    }
  }

  String get value => name;
}
