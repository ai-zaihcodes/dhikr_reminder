part of 'quote_bloc.dart';

/// Quote events
abstract class QuoteEvent extends Equatable {
  const QuoteEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch all quotes
class QuotesRequested extends QuoteEvent {
  const QuotesRequested();
}

/// Fetch quotes by category
class QuotesByCategoryRequested extends QuoteEvent {
  final String category;

  const QuotesByCategoryRequested(this.category);

  @override
  List<Object?> get props => [category];
}

/// Fetch random quote
class RandomQuoteRequested extends QuoteEvent {
  final List<String>? categories;

  const RandomQuoteRequested({this.categories});

  @override
  List<Object?> get props => [categories];
}

/// Create a new quote
class QuoteCreated extends QuoteEvent {
  final String text;
  final String? translation;
  final String category;
  final String? source;

  const QuoteCreated({
    required this.text,
    this.translation,
    required this.category,
    this.source,
  });

  @override
  List<Object?> get props => [text, translation, category, source];
}

/// Update an existing quote
class QuoteUpdated extends QuoteEvent {
  final QuoteEntity quote;

  const QuoteUpdated(this.quote);

  @override
  List<Object?> get props => [quote];
}

/// Delete a quote
class QuoteDeleted extends QuoteEvent {
  final String id;

  const QuoteDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

/// Fetch categories
class CategoriesRequested extends QuoteEvent {
  const CategoriesRequested();
}
