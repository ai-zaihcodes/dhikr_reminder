import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/quote_entity.dart';

/// Repository interface for Quote operations
abstract class IQuoteRepository {
  /// Get all quotes for the current user (global + custom)
  Future<Either<Failure, List<QuoteEntity>>> getQuotes();

  /// Get quotes filtered by category
  Future<Either<Failure, List<QuoteEntity>>> getQuotesByCategory(String category);

  /// Get only custom quotes for the current user
  Future<Either<Failure, List<QuoteEntity>>> getCustomQuotes();

  /// Get global/default quotes
  Future<Either<Failure, List<QuoteEntity>>> getGlobalQuotes();

  /// Get a random quote based on selected categories
  Future<Either<Failure, QuoteEntity>> getRandomQuote({List<String>? categories});

  /// Get a quote by ID
  Future<Either<Failure, QuoteEntity>> getQuoteById(String id);

  /// Create a new custom quote
  Future<Either<Failure, QuoteEntity>> createQuote({
    required String text,
    String? translation,
    required String category,
    String? source,
  });

  /// Update an existing custom quote
  Future<Either<Failure, QuoteEntity>> updateQuote(QuoteEntity quote);

  /// Delete a custom quote
  Future<Either<Failure, Unit>> deleteQuote(String id);

  /// Get all available categories
  Future<Either<Failure, List<String>>> getCategories();

  /// Sync quotes from remote (for offline support)
  Future<Either<Failure, Unit>> syncQuotes();
}
