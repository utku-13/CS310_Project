import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('HomeScreen - initState called');
    _loadUserData();
  }

  void _loadUserData() {
    try {
      print('HomeScreen - Loading user data');
      _currentUser = FirebaseAuth.instance.currentUser;
      print('HomeScreen - Current user: ${_currentUser?.email}');
      print('HomeScreen - User UID: ${_currentUser?.uid}');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
        print('HomeScreen - User data loaded successfully');
      }
    } catch (e) {
      print('HomeScreen - Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen - Building widget');
    print('HomeScreen - isLoading: $_isLoading');
    print('HomeScreen - hasError: $_hasError');
    
    if (_isLoading) {
      print('HomeScreen - Showing loading indicator');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError) {
      print('HomeScreen - Showing error state');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hata'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Bir hata oluştu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Bilinmeyen hata',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _loadUserData();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    print('HomeScreen - About to return main Scaffold');

    try {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AIWell - Ana Sayfa'),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  print('HomeScreen - Logout pressed');
                  await FirebaseAuth.instance.signOut();
                  print('HomeScreen - Logout successful');
                } catch (e) {
                  print('HomeScreen - Logout error: $e');
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoş geldiniz!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentUser?.email ?? 'Kullanıcı',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Features Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        context,
                        'Sohbet',
                        Icons.chat_bubble,
                        Colors.green,
                        () => Navigator.pushNamed(context, '/chat'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Görevler',
                        Icons.task,
                        Colors.orange,
                        () => Navigator.pushNamed(context, '/tasks'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Sohbet Geçmişi',
                        Icons.history,
                        Colors.purple,
                        () => Navigator.pushNamed(context, '/chat-history'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Terapi Randevusu',
                        Icons.calendar_today,
                        Colors.red,
                        () => Navigator.pushNamed(context, '/book'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Günlük İpuçları',
                        Icons.lightbulb,
                        Colors.yellow,
                        () => Navigator.pushNamed(context, '/recommendations'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Ayarlar',
                        Icons.settings,
                        Colors.grey,
                        () => Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('HomeScreen - Error building main Scaffold: $e');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hata'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Widget oluşturulurken hata oluştu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon,
      Color backgroundColor, VoidCallback onTap) {
    try {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: backgroundColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('HomeScreen - Error building feature card: $e');
      return Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: const Text('Hata'),
        ),
      );
    }
  }
} 