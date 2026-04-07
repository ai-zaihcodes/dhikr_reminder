import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user_settings_entity.dart';
import '../../repositories/user_settings_repository_interface.dart';

/// Use case for getting user settings
class GetUserSettingsUseCase {
  final IUserSettingsRepository _repository;

  GetUserSettingsUseCase(this._repository);

  Future<Either<Failure, UserSettingsEntity>> call() async {
    return await _repository.getUserSettings();
  }
}

/// Use case for updating user settings
class UpdateUserSettingsUseCase {
  final IUserSettingsRepository _repository;

  UpdateUserSettingsUseCase(this._repository);

  Future<Either<Failure, UserSettingsEntity>> call(UserSettingsEntity settings) async {
    return await _repository.updateSettings(settings);
  }
}

/// Use case for updating frequency type
class UpdateFrequencyTypeUseCase {
  final IUserSettingsRepository _repository;

  UpdateFrequencyTypeUseCase(this._repository);

  Future<Either<Failure, UserSettingsEntity>> call(FrequencyType type) async {
    return await _repository.updateFrequencyType(type);
  }
}

/// Use case for updating daily limit
class UpdateDailyLimitUseCase {
  final IUserSettingsRepository _repository;

  UpdateDailyLimitUseCase(this._repository);

  Future<Either<Failure, UserSettingsEntity>> call(int? limit) async {
    return await _repository.updateDailyLimit(limit);
  }
}

/// Use case for updating selected categories
class UpdateSelectedCategoriesUseCase {
  final IUserSettingsRepository _repository;

  UpdateSelectedCategoriesUseCase(this._repository);

  Future<Either<Failure, UserSettingsEntity>> call(List<String> categories) async {
    return await _repository.updateSelectedCategories(categories);
  }
}

/// Use case for toggling reminder enabled state
class ToggleReminderEnabledUseCase {
  final IUserSettingsRepository _repository;

  ToggleReminderEnabledUseCase(this._repository);

  Future<Either<Failure, UserSettingsEntity>> call(bool enabled) async {
    return await _repository.toggleEnabled(enabled);
  }
}

/// Use case for checking if reminder should be shown
class ShouldShowReminderUseCase {
  final IUserSettingsRepository _repository;

  ShouldShowReminderUseCase(this._repository);

  Future<Either<Failure, bool>> call() async {
    return await _repository.shouldShowReminder();
  }
}

/// Use case for incrementing reminder count
class IncrementReminderCountUseCase {
  final IUserSettingsRepository _repository;

  IncrementReminderCountUseCase(this._repository);

  Future<Either<Failure, UserSettingsEntity>> call() async {
    return await _repository.incrementRemindersCount();
  }
}
