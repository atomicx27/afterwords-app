import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class MessageProvider with ChangeNotifier {
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter messages by status
  List<MessageModel> get draftMessages => 
      _messages.where((m) => m.status == MessageStatus.draft).toList();
  
  List<MessageModel> get scheduledMessages => 
      _messages.where((m) => m.status == MessageStatus.scheduled).toList();
  
  List<MessageModel> get sentMessages => 
      _messages.where((m) => m.status == MessageStatus.sent).toList();

  // Load all messages
  Future<void> loadMessages() async {
    try {
      _setLoading(true);
      _clearError();

      _messages = await MessageService.getUserMessages();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create a new message
  Future<MessageModel?> createMessage({
    required String title,
    String? content,
    required MessageType type,
    File? mediaFile,
    List<String> recipientIds = const [],
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final message = await MessageService.createMessage(
        title: title,
        content: content,
        type: type,
        mediaFile: mediaFile,
        recipientIds: recipientIds,
      );

      _messages.insert(0, message);
      notifyListeners();
      return message;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update a message
  Future<bool> updateMessage(MessageModel message) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedMessage = await MessageService.updateMessage(message);
      
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a message
  Future<bool> deleteMessage(String messageId) async {
    try {
      _setLoading(true);
      _clearError();

      await MessageService.deleteMessage(messageId);
      
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Schedule a message
  Future<bool> scheduleMessage(String messageId, DateTime scheduledFor) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedMessage = await MessageService.scheduleMessage(
        messageId,
        scheduledFor,
      );
      
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get message by ID
  MessageModel? getMessageById(String messageId) {
    try {
      return _messages.firstWhere((m) => m.id == messageId);
    } catch (e) {
      return null;
    }
  }

  // Get messages by type
  List<MessageModel> getMessagesByType(MessageType type) {
    return _messages.where((m) => m.type == type).toList();
  }

  // Get messages by recipient
  List<MessageModel> getMessagesByRecipient(String recipientId) {
    return _messages.where((m) => m.recipientIds.contains(recipientId)).toList();
  }

  // Search messages
  List<MessageModel> searchMessages(String query) {
    if (query.isEmpty) return _messages;
    
    final lowercaseQuery = query.toLowerCase();
    return _messages.where((message) {
      return message.title.toLowerCase().contains(lowercaseQuery) ||
             (message.content?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Upload media file
  Future<Map<String, String>?> uploadMediaFile(File file, MessageType type) async {
    try {
      _setLoading(true);
      _clearError();

      return await MessageService.uploadMediaFile(file, type);
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Load messages by status
  Future<void> loadMessagesByStatus(MessageStatus status) async {
    try {
      _setLoading(true);
      _clearError();

      final messages = await MessageService.getMessagesByStatus(status);
      
      // Update the messages list with the filtered results
      _messages.removeWhere((m) => m.status == status);
      _messages.addAll(messages);
      _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    await loadMessages();
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Statistics
  int get totalMessages => _messages.length;
  int get draftCount => draftMessages.length;
  int get scheduledCount => scheduledMessages.length;
  int get sentCount => sentMessages.length;
  
  Map<MessageType, int> get messageTypeStats {
    final stats = <MessageType, int>{};
    for (final type in MessageType.values) {
      stats[type] = _messages.where((m) => m.type == type).length;
    }
    return stats;
  }
}