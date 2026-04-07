import 'package:equatable/equatable.dart';

import '../../domain/entities/user_settings_entity.dart';

/// Data Transfer Object for User Settings
class UserSettingsModel extends Equatable {
  final String userId;
  final String frequencyType;
  final int? dailyLimit;
  final List<String> selectedCategories;
  final bool showTranslation;
  final bool isEnabled;
  final DateTime? lastReminderTime;
  final int remindersShownToday;
  final DateTime? lastResetDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserSettingsModel({
    required this.userId,
    this.frequencyType = 'everyUnlock',
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

  /// Factory constructor from Supabase JSON
  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      userId: json['user_id'] as String,
      frequencyType: json['frequency_type'] as String? ?? 'everyUnlock',
      dailyLimit: json['daily_limit'] as int?,
      selectedCategories: (json['selected_categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      showTranslation: json['show_translation'] as bool? ?? true,
      isEnabled: json['is_enabled'] as bool? ?? true,
      lastReminderTime: json['last_reminder_time'] != null
          ? DateTime.parse(json['last_reminder_time'] as String)
          : null,
      remindersShownToday: json['reminders_shown_today'] as int? ?? 0,
      lastResetDate: json['last_reset_date'] != null
          ? DateTime.parse(json['last_reset_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'frequency_type': frequencyType,
      'daily_limit': dailyLimit,
      'selected_categories': selectedCategories,
      'show_translation': showTranslation,
      'is_enabled': isEnabled,
      'last_reminder_time': lastReminderTime?.toIso8601String(),
      'reminders_shown_today': remindersShownToday,
      'last_reset_date': lastResetDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  UserSettingsModel copyWith({
    String? userId,
    String? frequencyType,
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
    return UserSettingsModel(
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

  /// Convert frequency type string to enum
  FrequencyType get frequencyTypeEnum {
    switch (frequencyType) {
      case 'limitedPerDay':
        return FrequencyType.limitedPerDay;
      case 'everyUnlock':
      default:
        return FrequencyType.everyUnlock;
    }
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
