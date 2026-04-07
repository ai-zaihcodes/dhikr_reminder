import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Supabase errors and returns user-friendly messages
class SupabaseErrorHandler {
  static String getMessage(dynamic error) {
    if (error is AuthException) {
      return _handleAuthError(error);
    }
    
    if (error is PostgrestException) {
      return _handleDatabaseError(error);
    }
    
    if (error.toString().contains('500')) {
      return 'Server error. Please check:\n'
          '1. Database schema is created in Supabase\n'
          '2. Run the schema.sql file in Supabase SQL Editor\n'
          '3. Supabase project is active';
    }
    
    if (error.toString().contains('SocketException') || 
        error.toString().contains('Network')) {
      return 'Network error. Please check your internet connection.';
    }
    
    return 'An unexpected error occurred: ${error.toString()}';
  }
  
  static String _handleAuthError(AuthException error) {
    switch (error.statusCode) {
      case '400':
        if (error.message.contains('Email not confirmed')) {
          return 'Please check your email to confirm your account.';
        }
        return 'Invalid email or password.';
      case '401':
        return 'Session expired. Please sign in again.';
      case '422':
        return 'Email already registered.';
      default:
        return error.message;
    }
  }
  
  static String _handleDatabaseError(PostgrestException error) {
    if (error.code == 'PGRST116') {
      return 'Table not found. Please run the database schema in Supabase SQL Editor.';
    }
    if (error.code == '42501') {
      return 'Permission denied. Check Row Level Security policies.';
    }
    if (error.message.contains('relation') && error.message.contains('does not exist')) {
      return 'Database table missing. Run schema.sql in Supabase dashboard.';
    }
    return error.message;
  }
  
  /// Check if error is related to missing tables
  static bool isMissingTableError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('does not exist') || 
           errorStr.contains('pgrst116') ||
           errorStr.contains('500');
  }
  
  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('socket') || 
           errorStr.contains('network') ||
           errorStr.contains('connection');
  }
}
