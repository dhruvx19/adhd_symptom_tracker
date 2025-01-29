import 'package:flutter/material.dart';

class AppColors {
  static const softPurple = Color(0xFF8D5BFF);
  static const darkPurple = Color(0xFF2D2642);
  static const backgroundWhite = Colors.white;
  static const errorRed = Colors.red;
}

class ApiConstants {
  static const baseUrl = 'https://freelance-backend-xx6e.onrender.com/api/v1';
  static const registerEndpoint = '$baseUrl/users/register';
  static const sendOtpEndpoint = '$baseUrl/users/sendotp';
  static const verifyOtpEndpoint = '$baseUrl/users/verifyotp';
}