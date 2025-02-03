import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ADHD_Tracker/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  ProfileData? _profileData;
  bool _isLoading = false;
  String? _error;

  ProfileData? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
    final _client = http.Client();
  static const timeout = Duration(seconds: 30);

  Future<void> fetchProfileData() async {
    _isLoading = true;
    _error = null;

    try {
       final token = await _storage.read(key: 'auth_token');
      final request = http.Request(
        'GET',
        Uri.parse('https://freelance-backend-xx6e.onrender.com/api/v1/users/getuserdetails'),
      );
      
      // Add headers
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Send the request with timeout
      final response = await http.Response.fromStream(
        await _client
            .send(request)
            .timeout(timeout, onTimeout: () {
              throw TimeoutException('Request timed out');
            }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          _profileData = ProfileData.fromJson(jsonResponse['data']);
        } else {
          _error = jsonResponse['message'] ?? 'Failed to load profile data';
        }
      } else {
        _error = 'Failed to load profile data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
