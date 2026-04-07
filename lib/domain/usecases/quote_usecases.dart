import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/quote_entity.dart';
import '../repositories/quote_repository_interface.dart';

/// Use case for getting all quotes
class GetQuotesUseCase {
  final IQuoteRepository _repository;

  GetQuotesUseCase(this._repository);

  Future<Either<Failure, List<QuoteEntity>>> call() async {
    return await _repository.getQuotes();
  }
}

/// Use case for getting quotes by category
class GetQuotesByCategoryUseCase {
  final IQuoteRepository _repository;

  GetQuotesByCategoryUseCase(this._repository);

  Future<Either<Failure, List<QuoteEntity>>> call(String category) async {
    return await _repository.getQuotesByCategory(category);
  }
}

/// Use case for getting a random quote
class GetRandomQuoteUseCase {
  final IQuoteRepository _repository;

  GetRandomQuoteUseCase(this._repository);

  Future<Either<Failure, QuoteEntity>> call({List<String>? categories}) async {
    return await _repository.getRandomQuote(categories: categories);
  }
}

/// Use case for creating a custom quote
class CreateQuoteUseCase {
  final IQuoteRepository _repository;

  CreateQuoteUseCase(this._repository);

  Future<Either<Failure, QuoteEntity>> call({
    required String text,
    String? translation,
    required String category,
    String? source,
  }) async {
    return await _repository.createQuote(
      text: text,
      translation: translation,
      category: category,
      source: source,
    );
  }
}

/// Use case for updating a quote
class UpdateQuoteUseCase {
  final IQuoteRepository _repository;

  UpdateQuoteUseCase(this._repository);

  Future<Either<Failure, QuoteEntity>> call(QuoteEntity quote) async {
    return await _repository.updateQuote(quote);
  }
}

/// Use case for deleting a quote
class DeleteQuoteUseCase {
  final IQuoteRepository _repository;

  DeleteQuoteUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await _repository.deleteQuote(id);
  }
}

/// Use case for getting available categories
class GetCategoriesUseCase {
  final IQuoteRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<Either<Failure, List<String>>> call() async {
    return await _repository.getCategories();
  }
}
