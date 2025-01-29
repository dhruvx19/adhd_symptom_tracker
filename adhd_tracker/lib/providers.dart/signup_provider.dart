import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindle/utils/constants.dart';
import 'package:mindle/utils/validators.dart';
import 'package:http/http.dart' as http;


class SignUpProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;
  bool get isOtpVerified => _isOtpVerified;
  String? get errorMessage => _errorMessage;
  
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<bool> sendSignUpRequest(String name, String email, String password) async {
    // Input Validations
    if (!Validators.validateName(name)) {
      _errorMessage = 'Name must be at least 2 characters';
      notifyListeners();
      return false;
    }
    if (!Validators.validateEmail(email)) {
      _errorMessage = 'Invalid email format';
      notifyListeners();
      return false;
    }
    if (!Validators.validatePassword(password)) {
      _errorMessage = 'Password must be 8+ chars, with uppercase, lowercase & number';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'emailId': email,
          'password': password,
        }),
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timed out'),
      );
      
      _isLoading = false;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final token = responseBody['data']['token'];
        await _storage.write(key: 'auth_token', value: token);
        
        await sendOtp();
        return true;
      } else {
        _errorMessage = 'Registration failed: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOtp() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse(ApiConstants.sendOtpEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () => throw Exception('OTP send timed out'),
      );
      
      _isLoading = false;
      
      if (response.statusCode == 200) {
        _isOtpSent = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (!Validators.validateOtp(otp)) {
      _errorMessage = 'Invalid OTP format';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse(ApiConstants.verifyOtpEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'otp': otp}),
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () => throw Exception('OTP verification timed out'),
      );
      
      _isLoading = false;
      
      if (response.statusCode == 200) {
        _isOtpVerified = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}