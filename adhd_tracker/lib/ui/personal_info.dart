import 'package:flutter/material.dart';
import 'package:ADHD_Tracker/helpers/theme.dart';
import 'package:ADHD_Tracker/providers.dart/users_provider.dart';
import 'package:provider/provider.dart';

class PersonalInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final profileData = userProvider.profileData;
        if (profileData == null) {
          return Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Personal Information'),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.settings),
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
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Basic Information',
                  children: [
                    _buildInfoTile('Name', profileData.name),
                    _buildInfoTile('Email', profileData.emailId),
                    _buildInfoTile('Member ID', profileData.id),
                  ],
                ),
                SizedBox(height: 24),
                if (profileData.medications.isNotEmpty) ...[
                  _buildSection(
                    title: 'Medications',
                    children: profileData.medications
                        .map((med) => _buildInfoTile('• ', med))
                        .toList(),
                  ),
                  SizedBox(height: 24),
                ],
                if (profileData.symptoms.isNotEmpty) ...[
                  _buildSection(
                    title: 'Symptoms',
                    children: profileData.symptoms
                        .map((symptom) => _buildInfoTile('• ', symptom))
                        .toList(),
                  ),
                  SizedBox(height: 24),
                ],
                if (profileData.strategies.isNotEmpty) ...[
                  _buildSection(
                    title: 'Strategies',
                    children: profileData.strategies
                        .map((strategy) => _buildInfoTile('• ', strategy))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}