// profile_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  static const String baseUrl = 'https://freelance-backend-xx6e.onrender.com/api/v1/users';

  Future<bool> uploadProfilePicture(String base64Image) async {
    try {
     

      final response = await http.post(
        Uri.parse('$baseUrl/addprofilepicture'),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers if required
        },
        body: json.encode({
          'profilePicture': base64Image
        }),
      );

      if (response.statusCode != 200) {
        print('Server response: ${response.body}');
        return false;
      }
      return true;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return false;
    }
  }
  

  Future<bool> addMedications(List<String> medications) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addmedication'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'medication': medications
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
      final response = await http.post(
        Uri.parse('$baseUrl/addsymptoms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'symptoms': symptoms
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
      final response = await http.post(
        Uri.parse('$baseUrl/addstrategies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'strategies': strategy
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding strategy: $e');
      return false;
    }
  }
}
