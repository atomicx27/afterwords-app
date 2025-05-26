import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/recipient_model.dart';
import '../services/auth_service.dart';

class RecipientService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static const Uuid _uuid = Uuid();

  // Create a new recipient
  static Future<RecipientModel> createRecipient({
    required String name,
    required String email,
    String? phoneNumber,
    String? whatsappNumber,
    ContactMethod preferredMethod = ContactMethod.email,
  }) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final recipientId = _uuid.v4();
      final now = DateTime.now();

      final recipientData = {
        'id': recipientId,
        'user_id': userId,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'whatsapp_number': whatsappNumber,
        'preferred_method': preferredMethod.name,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _client.from('recipients').insert(recipientData);

      return RecipientModel.fromJson(recipientData);
    } catch (e) {
      rethrow;
    }
  }

  // Get all recipients for current user
  static Future<List<RecipientModel>> getUserRecipients() async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('recipients')
          .select()
          .eq('user_id', userId)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => RecipientModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get recipient by ID
  static Future<RecipientModel?> getRecipientById(String recipientId) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('recipients')
          .select()
          .eq('id', recipientId)
          .eq('user_id', userId)
          .single();

      return RecipientModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update recipient
  static Future<RecipientModel> updateRecipient(RecipientModel recipient) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updatedRecipient = recipient.copyWith(
        updatedAt: DateTime.now(),
      );

      await _client
          .from('recipients')
          .update(updatedRecipient.toJson())
          .eq('id', recipient.id)
          .eq('user_id', userId);

      return updatedRecipient;
    } catch (e) {
      rethrow;
    }
  }

  // Delete recipient
  static Future<void> deleteRecipient(String recipientId) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('recipients')
          .delete()
          .eq('id', recipientId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get recipients by IDs
  static Future<List<RecipientModel>> getRecipientsByIds(List<String> recipientIds) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      if (recipientIds.isEmpty) return [];

      final response = await _client
          .from('recipients')
          .select()
          .eq('user_id', userId)
          .inFilter('id', recipientIds);

      return (response as List)
          .map((json) => RecipientModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Search recipients by name or email
  static Future<List<RecipientModel>> searchRecipients(String query) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      if (query.isEmpty) return await getUserRecipients();

      final response = await _client
          .from('recipients')
          .select()
          .eq('user_id', userId)
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => RecipientModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Check if email already exists for user
  static Future<bool> emailExists(String email) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('recipients')
          .select('id')
          .eq('user_id', userId)
          .eq('email', email)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get recipients by preferred contact method
  static Future<List<RecipientModel>> getRecipientsByContactMethod(
    ContactMethod method,
  ) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('recipients')
          .select()
          .eq('user_id', userId)
          .eq('preferred_method', method.name)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => RecipientModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Bulk create recipients
  static Future<List<RecipientModel>> createMultipleRecipients(
    List<Map<String, dynamic>> recipientsData,
  ) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final recipients = recipientsData.map((data) {
        return {
          'id': _uuid.v4(),
          'user_id': userId,
          'name': data['name'],
          'email': data['email'],
          'phone_number': data['phone_number'],
          'whatsapp_number': data['whatsapp_number'],
          'preferred_method': (data['preferred_method'] as ContactMethod?)?.name ?? 
                             ContactMethod.email.name,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
      }).toList();

      await _client.from('recipients').insert(recipients);

      return recipients
          .map((json) => RecipientModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}