import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Get current session
  static Session? get currentSession => _client.auth.currentSession;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user != null) {
        // Create user profile in our custom users table
        await _createUserProfile(response.user!, fullName);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Update last check-in time
        await updateLastCheckIn();
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  static Future<UserModel?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response = await _client
          .from('users')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(UserModel user) async {
    try {
      await _client
          .from('users')
          .update(user.toJson())
          .eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  // Update last check-in time
  static Future<void> updateLastCheckIn() async {
    try {
      if (currentUser == null) return;

      await _client
          .from('users')
          .update({
            'last_check_in': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser!.id);

      // Log the check-in
      await _logCheckIn();
    } catch (e) {
      rethrow;
    }
  }

  // Create user profile in custom table
  static Future<void> _createUserProfile(User user, String? fullName) async {
    try {
      final now = DateTime.now();
      await _client.from('users').insert({
        'id': user.id,
        'email': user.email!,
        'full_name': fullName ?? user.userMetadata?['full_name'],
        'avatar_url': user.userMetadata?['avatar_url'],
        'last_check_in': now.toIso8601String(),
        'check_in_interval_hours': 24, // Default to daily
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
    } catch (e) {
      // User profile might already exist, ignore error
    }
  }

  // Log check-in activity
  static Future<void> _logCheckIn() async {
    try {
      if (currentUser == null) return;

      await _client.from('check_in_logs').insert({
        'id': _generateUuid(),
        'user_id': currentUser!.id,
        'check_in_time': DateTime.now().toIso8601String(),
        'is_successful': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't throw
      print('Failed to log check-in: $e');
    }
  }

  // Generate UUID (simple implementation)
  static String _generateUuid() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (999 * (DateTime.now().microsecond / 1000000))).round().toString();
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}