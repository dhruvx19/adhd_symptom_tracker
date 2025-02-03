import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ADHD_Tracker/helpers/theme.dart';
import 'package:ADHD_Tracker/providers.dart/login_provider.dart';
import 'package:ADHD_Tracker/providers.dart/users_provider.dart';
import 'package:ADHD_Tracker/services/change_pass.dart';
import 'package:ADHD_Tracker/ui/auth/login.dart';
import 'package:ADHD_Tracker/ui/personal_info.dart';
import 'package:ADHD_Tracker/ui/representation/mood_representation.dart';
import 'package:ADHD_Tracker/ui/settings/resources.dart';
import 'package:provider/provider.dart';
import 'package:ADHD_Tracker/models/user_model.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchProfileData();
    });
    Provider.of<UserProvider>(context, listen: false).fetchProfileData();
  }

  Widget _buildProfileImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return const CircleAvatar(
        radius: 40,
        child: Icon(Icons.person, size: 40),
      );
    }

    try {
      return CircleAvatar(
        radius: 40,
        backgroundImage: MemoryImage(base64Decode(base64Image)),
        onBackgroundImageError: (e, stack) {
          if (kDebugMode) {
            print('Error loading image: $e');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding base64 image: $e');
      }
      return const CircleAvatar(
        radius: 40,
        child: Icon(Icons.error, size: 40),
      );
    }
  }

  Future<void> _handleLogout() async {
    try {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      await loginProvider.logout();

      // Navigate to login page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == 'theme') {
                context.read<ThemeProvider>().toggleTheme();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.brightness_6),
                    SizedBox(width: 8),
                    Text('Toggle Theme'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final profileData = provider.profileData;
          if (profileData == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      _buildProfileImage(profileData.profilePicture),
                      const SizedBox(height: 16),
                      Text(
                        profileData.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Personal information'),
                  subtitle: Text(profileData.emailId),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInformationPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                if (profileData.medications.isNotEmpty) ...[
                  ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: const Text('Medications'),
                    subtitle: Text(profileData.medications.join(', ')),
                  ),
                  const Divider(),
                ],
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePasswordPage()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Records'),
                  subtitle: const Text('View progress and reports'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoodChartScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.web),
                  title: const Text('Resources'),
                  subtitle: Text('Helpful Resources'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResourcesPage
                        (),
                      ),
                    );
                  },
                ),
                
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share the app'),
                  onTap: () {
                    Share.share(
                      'Check out ADHD_Tracker App! It helps you track your medications and symptoms.',
                      subject: 'ADHD_Tracker App',
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log Out'),
                  onTap: () {
                    _handleLogout();
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Member ID ${profileData.id}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
