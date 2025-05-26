import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((AuthState data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _user = null;
        notifyListeners();
      }
    });

    // Load user if already signed in
    if (AuthService.isAuthenticated) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      _user = await AuthService.getUserProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        await _loadUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _user = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await AuthService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      await AuthService.updatePassword(newPassword);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _setLoading(true);
      _clearError();

      await AuthService.updateUserProfile(updatedUser);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> performCheckIn() async {
    try {
      _setLoading(true);
      _clearError();

      await AuthService.updateLastCheckIn();
      await _loadUserProfile(); // Reload to get updated check-in time
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCheckInInterval(int hours) async {
    try {
      if (_user == null) return false;

      _setLoading(true);
      _clearError();

      final updatedUser = _user!.copyWith(
        checkInIntervalHours: hours,
        updatedAt: DateTime.now(),
      );

      await AuthService.updateUserProfile(updatedUser);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
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

  // Getters for check-in status
  bool get isOverdue => _user?.isOverdue ?? false;
  Duration? get timeUntilDeadline => _user?.timeUntilDeadline;
  DateTime? get lastCheckIn => _user?.lastCheckIn;
  int get checkInIntervalHours => _user?.checkInIntervalHours ?? 24;
}