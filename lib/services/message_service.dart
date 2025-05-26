import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/message_model.dart';
import '../services/auth_service.dart';

class MessageService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static const Uuid _uuid = Uuid();

  // Create a new message
  static Future<MessageModel> createMessage({
    required String title,
    String? content,
    required MessageType type,
    File? mediaFile,
    List<String> recipientIds = const [],
  }) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      String? mediaUrl;
      String? mediaPath;

      // Upload media file if provided
      if (mediaFile != null) {
        final uploadResult = await uploadMediaFile(mediaFile, type);
        mediaUrl = uploadResult['url'];
        mediaPath = uploadResult['path'];
      }

      final messageId = _uuid.v4();
      final now = DateTime.now();

      final messageData = {
        'id': messageId,
        'user_id': userId,
        'title': title,
        'content': content,
        'type': type.name,
        'media_url': mediaUrl,
        'media_path': mediaPath,
        'status': MessageStatus.draft.name,
        'recipient_ids': recipientIds,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _client.from('messages').insert(messageData);

      return MessageModel.fromJson(messageData);
    } catch (e) {
      rethrow;
    }
  }

  // Get all messages for current user
  static Future<List<MessageModel>> getUserMessages() async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get message by ID
  static Future<MessageModel?> getMessageById(String messageId) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('messages')
          .select()
          .eq('id', messageId)
          .eq('user_id', userId)
          .single();

      return MessageModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update message
  static Future<MessageModel> updateMessage(MessageModel message) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updatedMessage = message.copyWith(
        updatedAt: DateTime.now(),
      );

      await _client
          .from('messages')
          .update(updatedMessage.toJson())
          .eq('id', message.id)
          .eq('user_id', userId);

      return updatedMessage;
    } catch (e) {
      rethrow;
    }
  }

  // Delete message
  static Future<void> deleteMessage(String messageId) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get message to check for media files
      final message = await getMessageById(messageId);
      if (message?.mediaPath != null) {
        // Delete media file from storage
        await _client.storage
            .from('messages')
            .remove([message!.mediaPath!]);
      }

      await _client
          .from('messages')
          .delete()
          .eq('id', messageId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Schedule message for delivery
  static Future<MessageModel> scheduleMessage(
    String messageId,
    DateTime scheduledFor,
  ) async {
    try {
      final message = await getMessageById(messageId);
      if (message == null) throw Exception('Message not found');

      final updatedMessage = message.copyWith(
        status: MessageStatus.scheduled,
        scheduledFor: scheduledFor,
        updatedAt: DateTime.now(),
      );

      return await updateMessage(updatedMessage);
    } catch (e) {
      rethrow;
    }
  }

  // Upload media file to Supabase Storage
  static Future<Map<String, String>> uploadMediaFile(
    File file,
    MessageType type,
  ) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileExtension = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExtension';
      final filePath = '$userId/${type.name}/$fileName';

      await _client.storage
          .from('messages')
          .upload(filePath, file);

      final publicUrl = _client.storage
          .from('messages')
          .getPublicUrl(filePath);

      return {
        'url': publicUrl,
        'path': filePath,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Get messages that need to be sent (for dead man's switch)
  static Future<List<MessageModel>> getMessagesToSend(String userId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('user_id', userId)
          .eq('status', MessageStatus.scheduled.name);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Mark message as sent
  static Future<void> markMessageAsSent(String messageId) async {
    try {
      await _client
          .from('messages')
          .update({
            'status': MessageStatus.sent.name,
            'sent_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
    } catch (e) {
      rethrow;
    }
  }

  // Mark message as failed
  static Future<void> markMessageAsFailed(String messageId, String reason) async {
    try {
      await _client
          .from('messages')
          .update({
            'status': MessageStatus.failed.name,
            'metadata': {'failure_reason': reason},
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
    } catch (e) {
      rethrow;
    }
  }

  // Get messages by status
  static Future<List<MessageModel>> getMessagesByStatus(MessageStatus status) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('messages')
          .select()
          .eq('user_id', userId)
          .eq('status', status.name)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}