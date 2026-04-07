import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/supabase_error_handler.dart';
import '../models/quote_model.dart';
import '../models/user_settings_model.dart';

/// Remote data source using Supabase
abstract class ISupabaseDataSource {
  /// Quotes
  Future<List<QuoteModel>> getQuotes();
  Future<List<QuoteModel>> getQuotesByCategory(String category);
  Future<List<QuoteModel>> getGlobalQuotes();
  Future<List<QuoteModel>> getCustomQuotes(String userId);
  Future<QuoteModel?> getQuoteById(String id);
  Future<QuoteModel> createQuote(QuoteModel quote);
  Future<QuoteModel> updateQuote(QuoteModel quote);
  Future<void> deleteQuote(String id);
  Future<List<String>> getCategories();

  /// User Settings
  Future<UserSettingsModel?> getUserSettings(String userId);
  Future<UserSettingsModel> createUserSettings(UserSettingsModel settings);
  Future<UserSettingsModel> updateUserSettings(UserSettingsModel settings);

  /// Auth
  String? get currentUserId;
  bool get isAuthenticated;
}

/// Implementation of Supabase data source
class SupabaseDataSource implements ISupabaseDataSource {
  final SupabaseClient _client;

  SupabaseDataSource(this._client);

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  bool get isAuthenticated => _client.auth.currentUser != null;

  @override
  Future<List<QuoteModel>> getQuotes() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('quotes')
        .select()
        .or('is_global.eq.true,user_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => QuoteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<QuoteModel>> getQuotesByCategory(String category) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('quotes')
        .select()
        .eq('category', category)
        .or('is_global.eq.true,user_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => QuoteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<QuoteModel>> getGlobalQuotes() async {
    final response = await _client
        .from('quotes')
        .select()
        .eq('is_global', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => QuoteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<QuoteModel>> getCustomQuotes(String userId) async {
    final response = await _client
        .from('quotes')
        .select()
        .eq('user_id', userId)
        .eq('is_global', false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => QuoteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuoteModel?> getQuoteById(String id) async {
    final response = await _client
        .from('quotes')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return QuoteModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<QuoteModel> createQuote(QuoteModel quote) async {
    final response = await _client
        .from('quotes')
        .insert(quote.toJson())
        .select()
        .single();

    return QuoteModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<QuoteModel> updateQuote(QuoteModel quote) async {
    final response = await _client
        .from('quotes')
        .update(quote.toJson())
        .eq('id', quote.id)
        .select()
        .single();

    return QuoteModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteQuote(String id) async {
    await _client.from('quotes').delete().eq('id', id);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _client
        .from('quotes')
        .select('category')
        .order('category');

    final categories = (response as List)
        .map((json) => json['category'] as String)
        .toSet()
        .toList();

    return categories;
  }

  @override
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserSettingsModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserSettingsModel> createUserSettings(UserSettingsModel settings) async {
    final response = await _client
        .from('profiles')
        .insert(settings.toJson())
        .select()
        .single();

    return UserSettingsModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserSettingsModel> updateUserSettings(UserSettingsModel settings) async {
    final response = await _client
        .from('profiles')
        .update(settings.toJson())
        .eq('user_id', settings.userId)
        .select()
        .single();

    return UserSettingsModel.fromJson(response as Map<String, dynamic>);
  }
}
