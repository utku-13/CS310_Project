import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Mevcut kullanıcı adını alıp, düzenleme alanına yerleştir
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      _newNameController.text = user.displayName!;
    }
  }
  
  @override
  void dispose() {
    _newNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // Kullanıcı adını güncelleme
  Future<void> _updateName() async {
    if (_newNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a name';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _authService.updateDisplayName(_newNameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_errorMessage')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Şifre değiştirme
  Future<void> _changePassword() async {
    // Form doğrulama
    if (_oldPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your current password')),
      );
      return;
    } 
    
    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a new password')),
      );
      return;
    } 
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _authService.changePassword(
        _oldPasswordController.text.trim(), 
        _newPasswordController.text.trim()
      );
      
      // Başarılı mesajı göster
      if (mounted) {
        // Form alanlarını temizle
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_errorMessage')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            _buildNameChangeSection(),
            const SizedBox(height: 24),
            _buildPasswordChangeSection(),
            const SizedBox(height: 24),
            _buildSignOutButton(),
          ],
        ),
    );
  }

  Widget _buildNameChangeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newNameController,
              decoration: const InputDecoration(
                labelText: 'New Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateName,
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordChangeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          await _authService.signOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/welcome',
              (route) => false,
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade100,
        foregroundColor: Colors.red.shade900,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Text('Sign Out'),
    );
  }
} 