import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user_settings_entity.dart';

/// Repository interface for User Settings operations
abstract class IUserSettingsRepository {
  /// Get user settings for the current user
  Future<Either<Failure, UserSettingsEntity>> getUserSettings();

  /// Create default settings for a new user
  Future<Either<Failure, UserSettingsEntity>> createDefaultSettings(String userId);

  /// Update user settings
  Future<Either<Failure, UserSettingsEntity>> updateSettings(UserSettingsEntity settings);

  /// Update frequency type
  Future<Either<Failure, UserSettingsEntity>> updateFrequencyType(FrequencyType type);

  /// Update daily limit
  Future<Either<Failure, UserSettingsEntity>> updateDailyLimit(int? limit);

  /// Update selected categories
  Future<Either<Failure, UserSettingsEntity>> updateSelectedCategories(List<String> categories);

  /// Toggle translation display
  Future<Either<Failure, UserSettingsEntity>> toggleTranslation(bool show);

  /// Toggle reminder enabled state
  Future<Either<Failure, UserSettingsEntity>> toggleEnabled(bool enabled);

  /// Increment reminders shown count
  Future<Either<Failure, UserSettingsEntity>> incrementRemindersCount();

  /// Reset daily counter
  Future<Either<Failure, UserSettingsEntity>> resetDailyCounter();

  /// Check if reminder should be shown based on settings
  Future<Either<Failure, bool>> shouldShowReminder();
}
