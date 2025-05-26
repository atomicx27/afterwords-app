import 'package:flutter/foundation.dart';
import '../models/recipient_model.dart';
import '../services/recipient_service.dart';

class RecipientProvider with ChangeNotifier {
  List<RecipientModel> _recipients = [];
  bool _isLoading = false;
  String? _error;

  List<RecipientModel> get recipients => _recipients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all recipients
  Future<void> loadRecipients() async {
    try {
      _setLoading(true);
      _clearError();

      _recipients = await RecipientService.getUserRecipients();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create a new recipient
  Future<RecipientModel?> createRecipient({
    required String name,
    required String email,
    String? phoneNumber,
    String? whatsappNumber,
    ContactMethod preferredMethod = ContactMethod.email,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if email already exists
      final emailExists = await RecipientService.emailExists(email);
      if (emailExists) {
        _setError('A recipient with this email already exists');
        return null;
      }

      final recipient = await RecipientService.createRecipient(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        whatsappNumber: whatsappNumber,
        preferredMethod: preferredMethod,
      );

      _recipients.add(recipient);
      _sortRecipients();
      notifyListeners();
      return recipient;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update a recipient
  Future<bool> updateRecipient(RecipientModel recipient) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedRecipient = await RecipientService.updateRecipient(recipient);
      
      final index = _recipients.indexWhere((r) => r.id == recipient.id);
      if (index != -1) {
        _recipients[index] = updatedRecipient;
        _sortRecipients();
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

  // Delete a recipient
  Future<bool> deleteRecipient(String recipientId) async {
    try {
      _setLoading(true);
      _clearError();

      await RecipientService.deleteRecipient(recipientId);
      
      _recipients.removeWhere((r) => r.id == recipientId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get recipient by ID
  RecipientModel? getRecipientById(String recipientId) {
    try {
      return _recipients.firstWhere((r) => r.id == recipientId);
    } catch (e) {
      return null;
    }
  }

  // Get recipients by IDs
  List<RecipientModel> getRecipientsByIds(List<String> recipientIds) {
    return _recipients.where((r) => recipientIds.contains(r.id)).toList();
  }

  // Search recipients
  List<RecipientModel> searchRecipients(String query) {
    if (query.isEmpty) return _recipients;
    
    final lowercaseQuery = query.toLowerCase();
    return _recipients.where((recipient) {
      return recipient.name.toLowerCase().contains(lowercaseQuery) ||
             recipient.email.toLowerCase().contains(lowercaseQuery) ||
             (recipient.phoneNumber?.contains(query) ?? false);
    }).toList();
  }

  // Get recipients by contact method
  List<RecipientModel> getRecipientsByContactMethod(ContactMethod method) {
    return _recipients.where((r) => r.preferredMethod == method).toList();
  }

  // Create multiple recipients
  Future<List<RecipientModel>?> createMultipleRecipients(
    List<Map<String, dynamic>> recipientsData,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final newRecipients = await RecipientService.createMultipleRecipients(
        recipientsData,
      );

      _recipients.addAll(newRecipients);
      _sortRecipients();
      notifyListeners();
      
      return newRecipients;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      return await RecipientService.emailExists(email);
    } catch (e) {
      return false;
    }
  }

  // Refresh recipients
  Future<void> refreshRecipients() async {
    await loadRecipients();
  }

  // Sort recipients alphabetically by name
  void _sortRecipients() {
    _recipients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
  int get totalRecipients => _recipients.length;
  
  Map<ContactMethod, int> get contactMethodStats {
    final stats = <ContactMethod, int>{};
    for (final method in ContactMethod.values) {
      stats[method] = _recipients.where((r) => r.preferredMethod == method).length;
    }
    return stats;
  }

  // Get recipients with phone numbers
  List<RecipientModel> get recipientsWithPhone => 
      _recipients.where((r) => r.hasPhoneNumber).toList();

  // Get recipients with WhatsApp
  List<RecipientModel> get recipientsWithWhatsApp => 
      _recipients.where((r) => r.hasWhatsApp).toList();

  // Get email-only recipients
  List<RecipientModel> get emailOnlyRecipients => 
      _recipients.where((r) => r.preferredMethod == ContactMethod.email).toList();
}