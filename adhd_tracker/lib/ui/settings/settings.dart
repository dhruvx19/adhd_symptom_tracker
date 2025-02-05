import 'dart:convert';

import 'package:ADHD_Tracker/ui/representation/mood/mood_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ADHD_Tracker/helpers/theme.dart';
import 'package:ADHD_Tracker/providers.dart/login_provider.dart';
import 'package:ADHD_Tracker/providers.dart/users_provider.dart';
import 'package:ADHD_Tracker/services/change_pass.dart';
import 'package:ADHD_Tracker/ui/auth/login.dart';
import 'package:ADHD_Tracker/ui/personal_info.dart';
import 'package:ADHD_Tracker/ui/representation/mood/mood_chart.dart';
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
      return CircleAvatar(
        radius: 40,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.person,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
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
      return CircleAvatar(
        radius: 40,
        backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
        child: Icon(
          Icons.error,
          size: 40,
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {

    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (themeProvider.isDarkMode) {
      themeProvider.setLightMode(); // You'll need to add this method to your ThemeProvider
    }
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      await loginProvider.logout();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to logout. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
            onSelected: (value) {
              if (value == 'theme') {
                themeProvider.toggleTheme();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      themeProvider.isDarkMode
                          ? 'Switch to Light Mode'
                          : 'Switch to Dark Mode',
                    ),
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
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildListTile(
                  icon: Icons.person,
                  title: 'Personal information',
                  subtitle: profileData.emailId,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalInformationPage(),
                    ),
                  ),
                ),
                _buildDivider(),
                if (profileData.medications.isNotEmpty) ...[
                  _buildListTile(
                    icon: Icons.medical_services,
                    title: 'Medications',
                    subtitle: profileData.medications.join(', '),
                  ),
                  _buildDivider(),
                ],
                _buildListTile(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                  ),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.bar_chart,
                  title: 'Records',
                  subtitle: 'View progress and reports',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnalyticsPage()),
                  ),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.web,
                  title: 'Resources',
                  subtitle: 'Helpful Resources',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResourcesPage()),
                  ),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.share,
                  title: 'Share the app',
                  onTap: () => Share.share(
                    'Check out ADHD_Tracker App! It helps you track your medications and symptoms.',
                    subject: 'ADHD_Tracker App',
                  ),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  onTap: _handleLogout,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Member ID ${profileData.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    );
  }
}

// final collections = [
//     {
//       'title': 'ADHD and Relationships',
//       'imageUrl':
//           'https://images.unsplash.com/photo-1529156069898-49953e39b3ac',
//       'url':
//           'https://www.helpguide.org/articles/add-adhd/adult-adhd-attention-deficit-disorder-and-relationships.htm'
//     },
//     // ... other items
//   ];

//   final resources = collections
//       .map((item) => ResourceModel.fromMap(item))
//       .toList();