import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/supabase_error_handler.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/repositories/quote_repository_interface.dart';
import '../datasources/supabase_datasource.dart';
import '../mappers/quote_mapper.dart';
import '../models/quote_model.dart';

/// Implementation of Quote Repository
class QuoteRepositoryImpl implements IQuoteRepository {
  final ISupabaseDataSource _dataSource;

  QuoteRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<QuoteEntity>>> getQuotes() async {
    try {
      if (!_dataSource.isAuthenticated) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final models = await _dataSource.getQuotes();
      final entities = QuoteMapper.toEntityList(models);
      return Right(entities);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: SupabaseErrorHandler.getMessage(e),
        code: e.code,
      ));
    } on Exception catch (e) {
      return Left(ServerFailure(message: SupabaseErrorHandler.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getQuotesByCategory(
    String category,
  ) async {
    try {
      if (!_dataSource.isAuthenticated) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final models = await _dataSource.getQuotesByCategory(category);
      final entities = QuoteMapper.toEntityList(models);
      return Right(entities);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: SupabaseErrorHandler.getMessage(e),
        code: e.code,
      ));
    } on Exception catch (e) {
      return Left(ServerFailure(message: SupabaseErrorHandler.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getCustomQuotes() async {
    try {
      final userId = _dataSource.currentUserId;
      if (userId == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final models = await _dataSource.getCustomQuotes(userId);
      final entities = QuoteMapper.toEntityList(models);
      return Right(entities);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getGlobalQuotes() async {
    try {
      final models = await _dataSource.getGlobalQuotes();
      final entities = QuoteMapper.toEntityList(models);
      return Right(entities);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuoteEntity>> getRandomQuote({
    List<String>? categories,
  }) async {
    try {
      if (!_dataSource.isAuthenticated) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      late List<QuoteModel> models;

      if (categories != null && categories.isNotEmpty) {
        // Fetch quotes from specified categories
        final allQuotes = <QuoteModel>[];
        for (final category in categories) {
          final categoryQuotes = await _dataSource.getQuotesByCategory(category);
          allQuotes.addAll(categoryQuotes);
        }
        models = allQuotes;
      } else {
        // Get all available quotes
        models = await _dataSource.getQuotes();
      }

      if (models.isEmpty) {
        return const Left(ServerFailure(message: 'No quotes available'));
      }

      // Select random quote
      final randomIndex = Random().nextInt(models.length);
      final entity = QuoteMapper.toEntity(models[randomIndex]);

      return Right(entity);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuoteEntity>> getQuoteById(String id) async {
    try {
      final model = await _dataSource.getQuoteById(id);
      if (model == null) {
        return const Left(ServerFailure(message: 'Quote not found'));
      }
      final entity = QuoteMapper.toEntity(model);
      return Right(entity);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuoteEntity>> createQuote({
    required String text,
    String? translation,
    required String category,
    String? source,
  }) async {
    try {
      final userId = _dataSource.currentUserId;
      if (userId == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final model = QuoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        translation: translation,
        category: category,
        source: source,
        isGlobal: false,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdModel = await _dataSource.createQuote(model);
      final entity = QuoteMapper.toEntity(createdModel);
      return Right(entity);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuoteEntity>> updateQuote(QuoteEntity quote) async {
    try {
      final userId = _dataSource.currentUserId;
      if (userId == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      // Only allow updating custom quotes
      if (quote.isGlobal) {
        return const Left(PermissionFailure(
          message: 'Cannot modify global quotes',
        ));
      }

      if (quote.userId != userId) {
        return const Left(PermissionFailure(
          message: 'Cannot modify quotes from other users',
        ));
      }

      final model = QuoteMapper.toModel(quote).copyWith(
        updatedAt: DateTime.now(),
      );

      final updatedModel = await _dataSource.updateQuote(model);
      final entity = QuoteMapper.toEntity(updatedModel);
      return Right(entity);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteQuote(String id) async {
    try {
      final userId = _dataSource.currentUserId;
      if (userId == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      // Get quote first to verify ownership
      final quote = await _dataSource.getQuoteById(id);
      if (quote == null) {
        return const Left(ServerFailure(message: 'Quote not found'));
      }

      if (quote.isGlobal) {
        return const Left(PermissionFailure(
          message: 'Cannot delete global quotes',
        ));
      }

      if (quote.userId != userId) {
        return const Left(PermissionFailure(
          message: 'Cannot delete quotes from other users',
        ));
      }

      await _dataSource.deleteQuote(id);
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final categories = await _dataSource.getCategories();
      return Right(categories);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncQuotes() async {
    // For now, just verify we can fetch quotes
    // In a full implementation, this would sync to local cache
    try {
      await _dataSource.getQuotes();
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
