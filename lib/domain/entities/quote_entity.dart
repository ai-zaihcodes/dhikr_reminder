import 'package:equatable/equatable.dart';

/// Represents a Dhikr quote in the domain layer
class QuoteEntity extends Equatable {
  final String id;
  final String text;
  final String? translation;
  final String category;
  final String? source;
  final bool isGlobal;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QuoteEntity({
    required this.id,
    required this.text,
    this.translation,
    required this.category,
    this.source,
    required this.isGlobal,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy with modified fields
  QuoteEntity copyWith({
    String? id,
    String? text,
    String? translation,
    String? category,
    String? source,
    bool? isGlobal,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuoteEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      category: category ?? this.category,
      source: source ?? this.source,
      isGlobal: isGlobal ?? this.isGlobal,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        translation,
        category,
        source,
        isGlobal,
        userId,
        createdAt,
        updatedAt,
      ];
}

/// Enum for quote categories
enum QuoteCategory {
  morning,
  evening,
  general,
  forgiveness,
  gratitude,
  protection,
  custom;

  String get displayName {
    switch (this) {
      case QuoteCategory.morning:
        return 'Morning';
      case QuoteCategory.evening:
        return 'Evening';
      case QuoteCategory.general:
        return 'General';
      case QuoteCategory.forgiveness:
        return 'Forgiveness';
      case QuoteCategory.gratitude:
        return 'Gratitude';
      case QuoteCategory.protection:
        return 'Protection';
      case QuoteCategory.custom:
        return 'Custom';
    }
  }

  String get value => name;
}
