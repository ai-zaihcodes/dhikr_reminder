import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/quote_entity.dart';
import '../../../domain/usecases/quote_usecases.dart';

part 'quote_event.dart';
part 'quote_state.dart';

/// BLoC for managing quotes
class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final GetQuotesUseCase _getQuotesUseCase;
  final GetQuotesByCategoryUseCase _getQuotesByCategoryUseCase;
  final GetRandomQuoteUseCase _getRandomQuoteUseCase;
  final CreateQuoteUseCase _createQuoteUseCase;
  final UpdateQuoteUseCase _updateQuoteUseCase;
  final DeleteQuoteUseCase _deleteQuoteUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  QuoteBloc({
    required GetQuotesUseCase getQuotesUseCase,
    required GetQuotesByCategoryUseCase getQuotesByCategoryUseCase,
    required GetRandomQuoteUseCase getRandomQuoteUseCase,
    required CreateQuoteUseCase createQuoteUseCase,
    required UpdateQuoteUseCase updateQuoteUseCase,
    required DeleteQuoteUseCase deleteQuoteUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
  })  : _getQuotesUseCase = getQuotesUseCase,
        _getQuotesByCategoryUseCase = getQuotesByCategoryUseCase,
        _getRandomQuoteUseCase = getRandomQuoteUseCase,
        _createQuoteUseCase = createQuoteUseCase,
        _updateQuoteUseCase = updateQuoteUseCase,
        _deleteQuoteUseCase = deleteQuoteUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        super(const QuoteState()) {
    on<QuotesRequested>(_onQuotesRequested);
    on<QuotesByCategoryRequested>(_onQuotesByCategoryRequested);
    on<RandomQuoteRequested>(_onRandomQuoteRequested);
    on<QuoteCreated>(_onQuoteCreated);
    on<QuoteUpdated>(_onQuoteUpdated);
    on<QuoteDeleted>(_onQuoteDeleted);
    on<CategoriesRequested>(_onCategoriesRequested);
  }

  Future<void> _onQuotesRequested(
    QuotesRequested event,
    Emitter<QuoteState> emit,
  ) async {
    emit(state.copyWith(status: QuoteStatus.loading));

    final result = await _getQuotesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: QuoteStatus.error,
        errorMessage: failure.message,
      )),
      (quotes) => emit(state.copyWith(
        status: QuoteStatus.loaded,
        quotes: quotes,
      )),
    );
  }

  Future<void> _onQuotesByCategoryRequested(
    QuotesByCategoryRequested event,
    Emitter<QuoteState> emit,
  ) async {
    emit(state.copyWith(status: QuoteStatus.loading));

    final result = await _getQuotesByCategoryUseCase(event.category);

    result.fold(
      (failure) => emit(state.copyWith(
        status: QuoteStatus.error,
        errorMessage: failure.message,
      )),
      (quotes) => emit(state.copyWith(
        status: QuoteStatus.loaded,
        quotes: quotes,
      )),
    );
  }

  Future<void> _onRandomQuoteRequested(
    RandomQuoteRequested event,
    Emitter<QuoteState> emit,
  ) async {
    emit(state.copyWith(status: QuoteStatus.loading));

    final result = await _getRandomQuoteUseCase(categories: event.categories);

    result.fold(
      (failure) => emit(state.copyWith(
        status: QuoteStatus.error,
        errorMessage: failure.message,
      )),
      (quote) => emit(state.copyWith(
        status: QuoteStatus.loaded,
        selectedQuote: quote,
      )),
    );
  }

  Future<void> _onQuoteCreated(
    QuoteCreated event,
    Emitter<QuoteState> emit,
  ) async {
    emit(state.copyWith(status: QuoteStatus.loading));

    final result = await _createQuoteUseCase(
      text: event.text,
      translation: event.translation,
      category: event.category,
      source: event.source,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: QuoteStatus.error,
        errorMessage: failure.message,
      )),
      (quote) {
        final updatedQuotes = [...state.quotes, quote];
        emit(state.copyWith(
          status: QuoteStatus.loaded,
          quotes: updatedQuotes,
        ));
      },
    );
  }

  Future<void> _onQuoteUpdated(
    QuoteUpdated event,
    Emitter<QuoteState> emit,
  ) async {
    emit(state.copyWith(status: QuoteStatus.loading));

    final result = await _updateQuoteUseCase(event.quote);

    result.fold(
      (failure) => emit(state.copyWith(
        status: QuoteStatus.error,
        errorMessage: failure.message,
      )),
      (updatedQuote) {
        final updatedQuotes = state.quotes
            .map((q) => q.id == updatedQuote.id ? updatedQuote : q)
            .toList();
        emit(state.copyWith(
          status: QuoteStatus.loaded,
          quotes: updatedQuotes,
        ));
      },
    );
  }

  Future<void> _onQuoteDeleted(
    QuoteDeleted event,
    Emitter<QuoteState> emit,
  ) async {
    emit(state.copyWith(status: QuoteStatus.loading));

    final result = await _deleteQuoteUseCase(event.id);

    result.fold(
      (failure) => emit(state.copyWith(
        status: QuoteStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedQuotes =
            state.quotes.where((q) => q.id != event.id).toList();
        emit(state.copyWith(
          status: QuoteStatus.loaded,
          quotes: updatedQuotes,
        ));
      },
    );
  }

  Future<void> _onCategoriesRequested(
    CategoriesRequested event,
    Emitter<QuoteState> emit,
  ) async {
    emit(state.copyWith(status: QuoteStatus.loading));

    final result = await _getCategoriesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: QuoteStatus.error,
        errorMessage: failure.message,
      )),
      (categories) => emit(state.copyWith(
        status: QuoteStatus.loaded,
        categories: categories,
      )),
    );
  }
}
