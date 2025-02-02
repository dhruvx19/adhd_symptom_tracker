// medication_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicationProvider with ChangeNotifier {
 String medicationName = '';
  String dosage = '';
  String timeOfTheDay = '';
  List<String> effects = [];
  bool isLoading = false;
  String error = '';
  String? successMessage;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  void updateMedicationName(String value) {
    medicationName = value;
    notifyListeners();
  }

  void updateDosage(String value) {
    dosage = value;
    notifyListeners();
  }

  void updateTimeOfDay(String value) {
    timeOfTheDay = value;
    notifyListeners();
  }

  void updateEffects(String value) {
    effects = value.split(',').map((e) => e.trim()).toList();
    notifyListeners();
  }

   Future<bool> submitMedication(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        error = 'Authentication token not found';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final url = 'https://freelance-backend-xx6e.onrender.com/api/v1/medication/addmedication';
      final requestBody = {
        'medicationName': medicationName,
        'dosage': dosage,
        'timeOfTheDay': timeOfTheDay,
        'effects': effects,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        successMessage = responseData['message'] ?? 'Medication added successfully';
        clearForm();
        
        // Show success message and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate after showing the message
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
        
        return true;
      } else {
        try {
          final errorData = json.decode(response.body);
          error = errorData['message'] ?? errorData['error'] ?? 'Failed to submit medication';
        } catch (e) {
          error = 'Failed to submit medication. Status code: ${response.statusCode}';
        }
        return false;
      }
    } catch (e) {
      error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    medicationName = '';
    dosage = '';
    timeOfTheDay = '';
    effects = [];
    error = '';
    successMessage = null;
    notifyListeners();
  }
}