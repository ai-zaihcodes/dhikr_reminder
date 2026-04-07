import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/user_settings_repository_interface.dart';
import '../datasources/supabase_datasource.dart';
import '../mappers/user_settings_mapper.dart';
import '../models/user_settings_model.dart';

/// Implementation of User Settings Repository
class UserSettingsRepositoryImpl implements IUserSettingsRepository {
  final ISupabaseDataSource _dataSource;

  UserSettingsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, UserSettingsEntity>> getUserSettings() async {
    try {
      final userId = _dataSource.currentUserId;
      if (userId == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final model = await _dataSource.getUserSettings(userId);

      if (model == null) {
        // Create default settings if none exist
        return await createDefaultSettings(userId);
      }

      // Check if we need to reset daily counter
      final settings = UserSettingsMapper.toEntity(model);
      final updatedSettings = await _checkAndResetDailyCounter(settings);

      return Right(updatedSettings);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> createDefaultSettings(
    String userId,
  ) async {
    try {
      final model = UserSettingsModel(
        userId: userId,
        frequencyType: 'everyUnlock',
        dailyLimit: null,
        selectedCategories: const [],
        showTranslation: true,
        isEnabled: true,
        lastReminderTime: null,
        remindersShownToday: 0,
        lastResetDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdModel = await _dataSource.createUserSettings(model);
      final entity = UserSettingsMapper.toEntity(createdModel);
      return Right(entity);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> updateSettings(
    UserSettingsEntity settings,
  ) async {
    try {
      final userId = _dataSource.currentUserId;
      if (userId == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      if (settings.userId != userId) {
        return const Left(PermissionFailure(
          message: 'Cannot modify settings for other users',
        ));
      }

      final model = UserSettingsMapper.toModel(settings).copyWith(
        updatedAt: DateTime.now(),
      );

      final updatedModel = await _dataSource.updateUserSettings(model);
      final entity = UserSettingsMapper.toEntity(updatedModel);
      return Right(entity);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> updateFrequencyType(
    FrequencyType type,
  ) async {
    final settingsResult = await getUserSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(frequencyType: type);
        return await updateSettings(updated);
      },
    );
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> updateDailyLimit(int? limit) async {
    final settingsResult = await getUserSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(dailyLimit: limit);
        return await updateSettings(updated);
      },
    );
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> updateSelectedCategories(
    List<String> categories,
  ) async {
    final settingsResult = await getUserSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(selectedCategories: categories);
        return await updateSettings(updated);
      },
    );
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> toggleTranslation(bool show) async {
    final settingsResult = await getUserSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(showTranslation: show);
        return await updateSettings(updated);
      },
    );
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> toggleEnabled(bool enabled) async {
    final settingsResult = await getUserSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(isEnabled: enabled);
        return await updateSettings(updated);
      },
    );
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> incrementRemindersCount() async {
    final settingsResult = await getUserSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(
          remindersShownToday: settings.remindersShownToday + 1,
          lastReminderTime: DateTime.now(),
        );
        return await updateSettings(updated);
      },
    );
  }

  @override
  Future<Either<Failure, UserSettingsEntity>> resetDailyCounter() async {
    final settingsResult = await getUserSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(
          remindersShownToday: 0,
          lastResetDate: DateTime.now(),
        );
        return await updateSettings(updated);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> shouldShowReminder() async {
    final settingsResult = await getUserSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.shouldShowReminder),
    );
  }

  /// Check if daily counter needs to be reset (new day)
  Future<UserSettingsEntity> _checkAndResetDailyCounter(
    UserSettingsEntity settings,
  ) async {
    final now = DateTime.now();
    final lastReset = settings.lastResetDate;

    if (lastReset == null) {
      return settings;
    }

    // Check if it's a new day
    if (now.year != lastReset.year ||
        now.month != lastReset.month ||
        now.day != lastReset.day) {
      // Reset the counter
      final updated = settings.copyWith(
        remindersShownToday: 0,
        lastResetDate: now,
      );

      // Update in background
      updateSettings(updated);
      return updated;
    }

    return settings;
  }
}
