import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindle/providers.dart/profile_services.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if profile setup was completed
  Future<bool> isProfileComplete() async {
    final completed = await _storage.read(key: 'profile_completed');
    return completed == 'true';
  }

  Future<bool> uploadProfilePicture(String base64Image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.uploadProfilePicture(base64Image);
      if (result) {
        await _storage.write(key: 'profile_picture_uploaded', value: 'true');
      }
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
    final result = await _handleRequest(() => _service.addMedications(medications));
    if (result) {
      await _storage.write(key: 'medications_added', value: 'true');
    }
    return result;
  }

  Future<bool> addSymptoms(List<String> symptoms) async {
    final result = await _handleRequest(() => _service.addSymptoms(symptoms));
    if (result) {
      await _storage.write(key: 'symptoms_added', value: 'true');
    }
    return result;
  }

  Future<bool> addStrategy(String strategy) async {
    final result = await _handleRequest(() => _service.addStrategy(strategy));
    if (result) {
      await _storage.write(key: 'strategy_added', value: 'true');
      // Mark profile as complete when strategy is added (final step)
      await _storage.write(key: 'profile_completed', value: 'true');
    }
    return result;
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

  // Method to clear profile completion status when signing out
  Future<void> clearProfileStatus() async {
    await _storage.delete(key: 'profile_completed');
    await _storage.delete(key: 'profile_picture_uploaded');
    await _storage.delete(key: 'medications_added');
    await _storage.delete(key: 'symptoms_added');
    await _storage.delete(key: 'strategy_added');
  }
}