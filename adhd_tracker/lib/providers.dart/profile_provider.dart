
// profile_provider.dart
import 'package:flutter/material.dart';
import 'package:mindle/providers.dart/profile_services.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> submitProfile({
    required String? base64Image,
    required List<String> medications,
    required List<String> symptoms,
    required String strategy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Upload profile picture if available
      if (base64Image != null) {
        final success = await _service.uploadProfilePicture(base64Image);
        if (!success) {
          throw Exception('Failed to upload profile picture');
        }
      }

      // Add medications
      if (medications.isNotEmpty) {
        final success = await _service.addMedications(medications);
        if (!success) {
          throw Exception('Failed to add medications');
        }
      }

      // Add symptoms
      if (symptoms.isNotEmpty) {
        final success = await _service.addSymptoms(symptoms);
        if (!success) {
          throw Exception('Failed to add symptoms');
        }
      }

      // Add strategy
      final success = await _service.addStrategy(strategy);
      if (!success) {
        throw Exception('Failed to add strategy');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}