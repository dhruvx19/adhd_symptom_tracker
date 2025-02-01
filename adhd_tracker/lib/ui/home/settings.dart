import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mindle/providers.dart/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:mindle/models/ser_details.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchProfileData();
  }
  Widget _buildProfileImage(String? base64Image) {
  if (base64Image == null || base64Image.isEmpty) {
    return CircleAvatar(
      radius: 40,
      child: Icon(Icons.person, size: 40),
    );
  }

  try {
    return CircleAvatar(
      radius: 40,
      backgroundImage: MemoryImage(base64Decode(base64Image)),
      onBackgroundImageError: (e, stack) {
        print('Error loading image: $e');
      
      },
    );
  } catch (e) {
    print('Error decoding base64 image: $e');
    return CircleAvatar(
      radius: 40,
      child: Icon(Icons.error, size: 40),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Settings action
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final profileData = provider.profileData;
          if (profileData == null) {
            return Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                       _buildProfileImage(profileData.profilePicture),
                      SizedBox(height: 16),
                      Text(
                        profileData.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Personal information'),
                  subtitle: Text(profileData.emailId),
                  isThreeLine: true,
                  onTap: () {
                    // Handle navigation
                  },
                ),
                Divider(),
                if (profileData.medications.isNotEmpty) ...[
                  ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text('Medications'),
                    subtitle: Text(profileData.medications.join(', ')),
                  ),
                  Divider(),
                ],
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Login and security'),
                  onTap: () {
                    // Handle navigation
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share the app'),
                  onTap: () {
                    // Handle share action
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                  onTap: () {
                    // Handle logout
                  },
                ),
                SizedBox(height: 24),
                Center(
                  child: Text(
                    'Member ID ${profileData.id}',
                    style: TextStyle(color: Colors.grey),
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
