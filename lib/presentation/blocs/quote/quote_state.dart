part of 'quote_bloc.dart';

/// Quote states
enum QuoteStatus { initial, loading, loaded, error }

/// Quote State class
class QuoteState extends Equatable {
  final QuoteStatus status;
  final List<QuoteEntity> quotes;
  final QuoteEntity? selectedQuote;
  final List<String> categories;
  final String? errorMessage;

  const QuoteState({
    this.status = QuoteStatus.initial,
    this.quotes = const [],
    this.selectedQuote,
    this.categories = const [],
    this.errorMessage,
  });

  QuoteState copyWith({
    QuoteStatus? status,
    List<QuoteEntity>? quotes,
    QuoteEntity? selectedQuote,
    List<String>? categories,
    String? errorMessage,
  }) {
    return QuoteState(
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
      selectedQuote: selectedQuote ?? this.selectedQuote,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        quotes,
        selectedQuote,
        categories,
        errorMessage,
      ];
}
