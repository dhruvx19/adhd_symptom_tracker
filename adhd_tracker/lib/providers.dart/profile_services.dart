import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  static const String baseUrl = 'http://10.0.2.2:2000/api/v1/users';

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String> convertImageToBase64(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    } catch (e) {
      print('Error converting image to base64: $e');
      throw Exception('Failed to convert image');
    }
  }

  Future<bool> uploadProfilePicture(String base64Image) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('$baseUrl/addProfilePicture'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'profilePicture': base64Image, // Send just the base64 string
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }

  Future<bool> addMedications(List<String> medications) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('$baseUrl/addmedication'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'medication': medications,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding medications: $e');
      return false;
    }
  }

  Future<bool> addSymptoms(List<String> symptoms) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('$baseUrl/addsymptoms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'symptoms': symptoms,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding symptoms: $e');
      return false;
    }
  }

  Future<bool> addStrategy(String strategy) async {
  try {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('$baseUrl/addstrategies'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'strategies': [strategy], 
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    print('Error adding strategy: $e');
    return false;
  }
}
}