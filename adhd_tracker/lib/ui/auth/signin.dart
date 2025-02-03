import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ADHD_Tracker/providers.dart/signup_provider.dart';
import 'package:ADHD_Tracker/ui/auth/create_profile.dart';
import 'package:ADHD_Tracker/ui/auth/login.dart';
import 'package:ADHD_Tracker/utils/color.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final Color darkPurple = const Color(0xFF2D2642);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _handleSignUp(BuildContext context, SignUpProvider provider) async {
    // Hide keyboard when signup is initiated
    FocusScope.of(context).unfocus();

    final success = await provider.sendSignUpRequest(nameController.text.trim(),
        emailController.text.trim(), passwordController.text);

    if (!success && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  
  void _navigateToProfilePage(BuildContext context) {
    if (!mounted) return;

    // Get the existing provider instance
    final signUpProvider = context.read<SignUpProvider>();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: signUpProvider,
          child: const ProfileCreationPage(),
        ),
      ),
    );
  }

  void _handleOtpVerification(
      BuildContext context, SignUpProvider provider) async {
    // Hide keyboard when OTP verification is initiated
    FocusScope.of(context).unfocus();

    final success = await provider.verifyOtp(otpController.text.trim());

    if (success) {
      final storage = FlutterSecureStorage();
      await storage.write(key: 'profile_creation_pending', value: 'true');
      _navigateToProfilePage(context);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
  static Future<bool> checkProfileCreationNeeded() async {
    final storage = FlutterSecureStorage();
    final isPending = await storage.read(key: 'profile_creation_pending');
    return isPending == 'true';
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width / 375.0;
    return ChangeNotifierProvider(
      create: (_) => SignUpProvider(),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.upeiGreen),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Consumer<SignUpProvider>(
          builder: (context, provider, child) {
            return GestureDetector(
              onTap: () => FocusScope.of(context)
                  .unfocus(), // Dismiss keyboard on tap outside
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'ADHD Tracker',
                            style: TextStyle(
                              fontFamily: 'Yaro',
                              fontSize: 40 * fontScale,
                              fontWeight: FontWeight.bold,
                              color: darkPurple,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Name TextField
                        Text('Name',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: darkPurple,
                              ),
                            )),
                        const SizedBox(height: 4),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email TextField
                        Text('Email',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: darkPurple,
                              ),
                            )),
                        const SizedBox(height: 4),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter email',
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password TextField
                        Text('Password',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: darkPurple,
                              ),
                            )),
                        const SizedBox(height: 4),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        if (provider.isOtpSent) ...[
                          const SizedBox(height: 16),
                          Text('OTP',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: darkPurple,
                                ),
                              )),
                          const SizedBox(height: 4),
                          TextField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter 6-digit OTP',
                              fillColor: Colors.grey[200],
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final provider = Provider.of<SignUpProvider>(
                                  context,
                                  listen: false);

                              if (!provider.isOtpSent) {
                                // Initial sign-up: validate fields and send OTP
                                _handleSignUp(context, provider);
                              } else if (provider.isOtpSent &&
                                  !provider.isOtpVerified) {
                                // OTP verification stage
                                _handleOtpVerification(context, provider);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.upeiRed,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              !provider.isOtpSent ? 'Sign Up' : 'Verify OTP',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  if (provider.isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.transparent,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.upeiRed),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
