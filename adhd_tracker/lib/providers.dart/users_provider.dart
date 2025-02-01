import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mindle/models/ser_details.dart';

class UserProvider extends ChangeNotifier {
  ProfileData? _profileData;
  bool _isLoading = false;
  String? _error;

  ProfileData? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> fetchProfileData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
       final token = await _storage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:2000/api/v1/users/getuserdetails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
