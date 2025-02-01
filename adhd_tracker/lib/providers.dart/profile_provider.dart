
// profile_provider.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mindle/providers.dart/profile_services.dart';

class ProfileProvider extends ChangeNotifier {
  
  final ProfileService _service = ProfileService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

    Future<bool> uploadProfilePicture(String base64Image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.uploadProfilePicture(base64Image);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update the convertImageToBase64 method in your ProfileCreationPage
  Future<String?> convertImageToBase64(File imageFile) async {
    try {
      return await ProfileService.convertImageToBase64(imageFile);
    } catch (e) {
      _error = 'Failed to process image: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addMedications(List<String> medications) async {
    return _handleRequest(() => _service.addMedications(medications));
  }

  Future<bool> addSymptoms(List<String> symptoms) async {
    return _handleRequest(() => _service.addSymptoms(symptoms));
  }

  Future<bool> addStrategy(String strategy) async {
    return _handleRequest(() => _service.addStrategy(strategy));
  }

  Future<bool> _handleRequest(Future<bool> Function() request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await request();
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}