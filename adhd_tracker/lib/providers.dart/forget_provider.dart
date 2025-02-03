import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ForgotPasswordProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String? _errorMessage;
  String? _emailId;
  String? _authToken;

  final _storage = FlutterSecureStorage();

  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;
  bool get isOtpVerified => _isOtpVerified;
  String? get errorMessage => _errorMessage;

  Future<bool> sendPasswordResetOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://freelance-backend-xx6e.onrender.com/api/v1/users/forgot-password/otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailId': email}),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        _isOtpSent = true;
        _emailId = email;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorMessage(response.body);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Network error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPasswordResetOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://freelance-backend-xx6e.onrender.com/api/v1/users/forgot-password/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailId': email,
          'otp': otp
        }),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        _authToken = responseBody['token'];
        
        // Save token securely
        await _storage.write(key: 'reset_password_token', value: _authToken);

        _isOtpVerified = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorMessage(response.body);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Network error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve the token from secure storage
      final token = await _storage.read(key: 'reset_password_token');

      final response = await http.post(
        Uri.parse('https://freelance-backend-xx6e.onrender.com/api/v1/users/forgot-password/update-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'newPassword': newPassword}),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        // Clear the stored token
        await _storage.delete(key: 'reset_password_token');

        // Reset all states
        _isOtpSent = false;
        _isOtpVerified = false;
        _emailId = null;
        _authToken = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorMessage(response.body);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Network error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Helper method to parse error messages from API responses
  String _parseErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> body = json.decode(responseBody);
      return body['message'] ?? 'An unknown error occurred';
    } catch (e) {
      return 'An unknown error occurred';
    }
  }
}