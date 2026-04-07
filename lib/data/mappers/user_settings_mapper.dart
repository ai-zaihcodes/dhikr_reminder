import '../../domain/entities/user_settings_entity.dart';
import '../models/user_settings_model.dart';

/// Mapper for converting between UserSettingsModel and UserSettingsEntity
class UserSettingsMapper {
  /// Convert model to entity
  static UserSettingsEntity toEntity(UserSettingsModel model) {
    return UserSettingsEntity(
      userId: model.userId,
      frequencyType: model.frequencyTypeEnum,
      dailyLimit: model.dailyLimit,
      selectedCategories: model.selectedCategories,
      showTranslation: model.showTranslation,
      isEnabled: model.isEnabled,
      lastReminderTime: model.lastReminderTime,
      remindersShownToday: model.remindersShownToday,
      lastResetDate: model.lastResetDate,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Convert entity to model
  static UserSettingsModel toModel(UserSettingsEntity entity) {
    return UserSettingsModel(
      userId: entity.userId,
      frequencyType: entity.frequencyType.value,
      dailyLimit: entity.dailyLimit,
      selectedCategories: entity.selectedCategories,
      showTranslation: entity.showTranslation,
      isEnabled: entity.isEnabled,
      lastReminderTime: entity.lastReminderTime,
      remindersShownToday: entity.remindersShownToday,
      lastResetDate: entity.lastResetDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
