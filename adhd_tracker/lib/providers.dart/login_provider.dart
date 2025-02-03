import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ADHD_Tracker/helpers/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  bool _isLoggedIn = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;

  // Constants
  static const String _baseUrl =
      'https://freelance-backend-xx6e.onrender.com/api/v1';
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Initialize provider and check for existing token
  Future<void> initialize() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) {
      _token = token;
      _isLoggedIn = true;
      await NotificationService.initializeNotifications();

      await NotificationService.scheduleDailyReminder();
    }
    notifyListeners();
  }

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> responseData) async {
    final token = responseData['data'] as String;

    if (token.isEmpty) {
      throw Exception('No token received from server');
    }

    // Store token
    await _secureStorage.write(key: _tokenKey, value: token);

    _token = token;
    _isLoggedIn = true;
    _clearError();

    // Schedule daily notification when user logs in
    await NotificationService.scheduleDailyReminder();

    notifyListeners();
  }

  // Login method
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email and password are required';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final response = await http.post(
        Uri.parse('$_baseUrl/users/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'emailId': email.trim(),
          'password': password,
        }),
      );

      // Log response for debugging
      debugPrint('Login Response Status: ${response.statusCode}');
      debugPrint('Login Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        await _handleSuccessfulLogin(responseData);
        return true;
      } else {
        _handleLoginError(response.statusCode, responseData);
        return false;
      }
    } catch (e) {
      _handleException(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  //Logout
  Future<void> logout() async {
    try {
      _setLoading(true);

      // Clear stored data
      await _secureStorage.delete(key: _tokenKey);

      // Cancel daily reminder
      await AwesomeNotifications().cancelSchedule(0);

      // Reset state
      _token = null;
      _isLoggedIn = false;
      _clearError();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error during logout: ${e.toString()}';
      debugPrint('Logout Error: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Handle login error
  void _handleLoginError(int statusCode, Map<String, dynamic> responseData) {
    _errorMessage = responseData['message'] ?? 'Login failed. Please try again';
    notifyListeners();
  }

  // Handle exceptions
  void _handleException(dynamic e) {
    debugPrint('Login Error: $e');
    if (e.toString().contains('SocketException')) {
      _errorMessage = 'Network error. Please check your connection';
    } else {
      _errorMessage = 'An unexpected error occurred. Please try again';
    }
    notifyListeners();
  }

  // Check login status
  Future<bool> checkLoginStatus() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      _isLoggedIn = token != null;
      if (_isLoggedIn) {
        _token = token;
      }
      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all state (useful for testing or reset)
  Future<void> clearState() async {
    await _secureStorage.deleteAll();
    _isLoading = false;
    _errorMessage = null;
    _token = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
