import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        children: [
          _buildSection(
            title: 'Account',
            children: [
              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () {
                  // TODO: Navigate to profile page
                },
              ),
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // TODO: Navigate to notifications settings
                },
              ),
              _buildSettingTile(
                icon: Icons.security_outlined,
                title: 'Privacy',
                onTap: () {
                  // TODO: Navigate to privacy settings
                },
              ),
            ],
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          _buildSection(
            title: 'Preferences',
            children: [
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: false, // TODO: Implement theme switching
                  onChanged: (value) {
                    // TODO: Toggle dark mode
                  },
                ),
              ),
              _buildSettingTile(
                icon: Icons.language_outlined,
                title: 'Language',
                trailing: const Text('English'),
                onTap: () {
                  // TODO: Show language selection
                },
              ),
            ],
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          _buildSection(
            title: 'Support',
            children: [
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Show help center
                },
              ),
              _buildSettingTile(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                onTap: () {
                  // TODO: Show feedback form
                },
              ),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  // TODO: Show about page
                },
              ),
            ],
          ),
          const SizedBox(height: AppStyles.defaultPadding * 2),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppStyles.defaultPadding,
            bottom: AppStyles.defaultPadding / 2,
          ),
          child: Text(
            title,
            style: AppStyles.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
} 