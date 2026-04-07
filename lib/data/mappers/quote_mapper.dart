import '../../domain/entities/quote_entity.dart';
import '../models/quote_model.dart';

/// Mapper for converting between QuoteModel and QuoteEntity
class QuoteMapper {
  /// Convert model to entity
  static QuoteEntity toEntity(QuoteModel model) {
    return QuoteEntity(
      id: model.id,
      text: model.text,
      translation: model.translation,
      category: model.category,
      source: model.source,
      isGlobal: model.isGlobal,
      userId: model.userId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Convert entity to model
  static QuoteModel toModel(QuoteEntity entity) {
    return QuoteModel(
      id: entity.id,
      text: entity.text,
      translation: entity.translation,
      category: entity.category,
      source: entity.source,
      isGlobal: entity.isGlobal,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert list of models to list of entities
  static List<QuoteEntity> toEntityList(List<QuoteModel> models) {
    return models.map(toEntity).toList();
  }

  /// Convert list of entities to list of models
  static List<QuoteModel> toModelList(List<QuoteEntity> entities) {
    return entities.map(toModel).toList();
  }
}
