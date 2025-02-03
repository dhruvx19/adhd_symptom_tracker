import 'package:ADHD_Tracker/providers.dart/forget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/color.dart';
import '../../utils/constants.dart';



class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final Color darkPurple = const Color(0xFF2D2642);

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool isNewPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  void _handleSendOtp(BuildContext context, ForgotPasswordProvider provider) async {
    // Hide keyboard when OTP sending is initiated
    FocusScope.of(context).unfocus();

    final success = await provider.sendPasswordResetOtp(emailController.text.trim());

    if (!success && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _handleVerifyOtp(BuildContext context, ForgotPasswordProvider provider) async {
    // Hide keyboard when OTP verification is initiated
    FocusScope.of(context).unfocus();

    final success = await provider.verifyPasswordResetOtp(
      emailController.text.trim(), 
      otpController.text.trim()
    );

    if (!success && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _handleResetPassword(BuildContext context, ForgotPasswordProvider provider) async {
    // Hide keyboard when password reset is initiated
    FocusScope.of(context).unfocus();

    final success = await provider.resetPassword(newPasswordController.text);

    if (success) {
      // Navigate back to login or show success dialog
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset successfully'),
          backgroundColor: AppTheme.upeiGreen,
        ),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width / 375.0;

    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordProvider(),
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
        body: Consumer<ForgotPasswordProvider>(
          builder: (context, provider, child) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Reset Password',
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
                        
                        // Email TextField (always visible)
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

                        // OTP TextField (appears after OTP is sent)
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

                        // New Password TextField (appears after OTP verification)
                        if (provider.isOtpVerified) ...[
                          const SizedBox(height: 16),
                          Text('New Password',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: darkPurple,
                                ),
                              )),
                          const SizedBox(height: 4),
                          TextField(
                            controller: newPasswordController,
                            obscureText: !isNewPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Enter new password',
                              fillColor: Colors.grey[200],
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isNewPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    isNewPasswordVisible = !isNewPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final provider = Provider.of<ForgotPasswordProvider>(
                                  context,
                                  listen: false);

                              // Determine which action to take based on current state
                              if (!provider.isOtpSent) {
                                // Send OTP
                                _handleSendOtp(context, provider);
                              } else if (provider.isOtpSent && !provider.isOtpVerified) {
                                // Verify OTP
                                _handleVerifyOtp(context, provider);
                              } else if (provider.isOtpVerified) {
                                // Reset Password
                                _handleResetPassword(context, provider);
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
                              !provider.isOtpSent 
                                  ? 'Send OTP' 
                                  : (!provider.isOtpVerified 
                                      ? 'Verify OTP' 
                                      : 'Reset Password'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Loading indicator
                  if (provider.isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
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