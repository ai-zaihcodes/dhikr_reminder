import 'package:equatable/equatable.dart';

/// Data Transfer Object for Quote
class QuoteModel extends Equatable {
  final String id;
  final String text;
  final String? translation;
  final String category;
  final String? source;
  final bool isGlobal;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QuoteModel({
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

  /// Factory constructor from Supabase JSON
  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      text: json['text'] as String,
      translation: json['translation'] as String?,
      category: json['category'] as String,
      source: json['source'] as String?,
      isGlobal: json['is_global'] as bool? ?? false,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'translation': translation,
      'category': category,
      'source': source,
      'is_global': isGlobal,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  QuoteModel copyWith({
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
    return QuoteModel(
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
