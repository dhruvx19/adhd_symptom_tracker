import 'package:flutter/material.dart';
import 'package:ADHD_Tracker/helpers/notification.dart';
import 'package:ADHD_Tracker/utils/color.dart';
import 'package:provider/provider.dart';
import 'package:ADHD_Tracker/providers.dart/login_provider.dart';
import 'package:ADHD_Tracker/ui/auth/login.dart';
import 'package:ADHD_Tracker/ui/home/mood.dart';
import 'package:ADHD_Tracker/ui/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (!isFirstTime) {
      // Request notification permissions
      if (mounted) {
        await NotificationService.requestPermission(context);
      }

      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      await loginProvider.initialize();

      if (loginProvider.isLoggedIn) {
        // Check if mood is recorded for today
        final lastRecordedDate = prefs.getString('last_mood_date');
        final today = DateTime.now().toIso8601String().split('T')[0];

        await Future.delayed(const Duration(milliseconds: 2000));

        if (!mounted) return;

        if (lastRecordedDate != today) {
          _navigateToPage(MoodPage());
        } else {
          _navigateToPage(HomePage());
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (!mounted) return;
        _navigateToPage(const LoginPage());
      }
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
