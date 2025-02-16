import 'dart:convert';

import 'package:adhd_tracker/ui/auth/create_profile.dart';
import 'package:flutter/material.dart';
import 'package:adhd_tracker/helpers/notification.dart';
import 'package:adhd_tracker/utils/color.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:adhd_tracker/providers.dart/login_provider.dart';
import 'package:adhd_tracker/ui/auth/login.dart';
import 'package:adhd_tracker/ui/home/mood.dart';
import 'package:adhd_tracker/ui/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    
    if (!mounted) return;
    
    setState(() {
      isFirstTime = prefs.getBool('is_first_time') ?? true;
    });

    // First time users should stay on splash screen
    if (isFirstTime) {
      return;
    }

    // Initialize login provider and check token
    await loginProvider.initialize();
    
    if (!mounted) return;

    // Simple logic: If we have a token, go to mood page
    if (loginProvider.isLoggedIn) {
      await Future.delayed(const Duration(milliseconds: 1500)); // Keep splash animation
      if (!mounted) return;
      _navigateToPage(MoodPage()); // Directly go to mood page if logged in
    } else {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _navigateToPage(const LoginPage());
    }
  } catch (e) {
    debugPrint('Error in _initializeApp: $e');
    if (mounted) {
      // Only navigate to login if there's a real authentication issue
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        _navigateToPage(MoodPage()); // If we have a token, still try to go to mood
      } else {
        _navigateToPage(const LoginPage());
      }
    }
  }
}
// Add this new method to check profile completion
Future<bool> _checkProfileCompletion() async {
  try {
    final token = await const FlutterSecureStorage().read(key: 'auth_token');
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('https://freelance-backend-xx6e.onrender.com/api/v1/users/getuserdetails'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data['isProfilePictureSet'] && 
             data['addMedication'] && 
             data['addSymptoms'] && 
             data['addStrategies'];
    }
    return false;
  } catch (e) {
    print('Error checking profile completion: $e');
    return false;
  }
}
  Future<void> _handleGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);

    // Request notification permissions when user clicks "Get Started"
    if (mounted) {
      await NotificationService.requestPermission(context);
    }

    if (!mounted) return;
    _navigateToPage(const LoginPage());
  }

  void _navigateToPage(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.30;
    final fontScale = size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Update the logo container part in the build method:

                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                // Add ClipOval to ensure circular clipping
                                child: Container(
                                  padding: EdgeInsets.all(logoSize *
                                      0.15), // Increase padding for better containment
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'ADHD Tracker',
                                  style: TextStyle(
                                    fontFamily: 'Yaro',
                                    fontSize: 44 * fontScale,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.upeiRed,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),
                                Text(
                                  'Your personal ADHD companion\nPowered by UPEI',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Yaro',
                                    fontSize: 20 * fontScale,
                                    color: AppTheme.upeiGreen.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isFirstTime)
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                          horizontal: size.width * 0.06,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleGetStarted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.upeiRed,
                            minimumSize:
                                Size(double.infinity, size.height * 0.07),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
