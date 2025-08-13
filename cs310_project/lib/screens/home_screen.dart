import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  User? _currentUser;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
        _animationController.forward();
      }
    } catch (e) {
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppStyles.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppStyles.primaryGradient,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AIWell',
                style: AppStyles.headingStyle.copyWith(
                  color: AppStyles.primaryColor,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: AppStyles.backgroundColor,
        appBar: AppBar(
          title: const Text('Hata'),
          backgroundColor: AppStyles.errorColor,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppStyles.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppStyles.errorColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bir hata oluştu',
                  style: AppStyles.headingMediumStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Bilinmeyen hata',
                  style: AppStyles.bodyMediumStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _loadUserData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: AppStyles.primaryButtonStyle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppStyles.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AIWell',
              style: AppStyles.headingSmallStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  // Handle error
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppStyles.largePadding),
                    decoration: BoxDecoration(
                      gradient: AppStyles.primaryGradient,
                      borderRadius: BorderRadius.circular(AppStyles.largeBorderRadius),
                      boxShadow: AppStyles.elevatedShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hoş geldiniz!',
                                    style: AppStyles.headingSmallStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentUser?.email ?? 'Kullanıcı',
                                    style: AppStyles.bodyStyle.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Bugün kendinizi nasıl hissediyorsunuz?',
                          style: AppStyles.bodyStyle.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppStyles.largePadding),
                  
                  // Features Grid
                  Text(
                    'Hizmetlerimiz',
                    style: AppStyles.headingMediumStyle,
                  ),
                  const SizedBox(height: AppStyles.defaultPadding),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppStyles.defaultPadding,
                    mainAxisSpacing: AppStyles.defaultPadding,
                    childAspectRatio: 1.1,
                    children: [
                      _buildFeatureCard(
                        context,
                        'AI Sohbet',
                        Icons.chat_bubble_outline,
                        'Yapay zeka ile sohbet edin',
                        AppStyles.primaryGradient,
                        () => Navigator.pushNamed(context, '/chat'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Görevler',
                        Icons.task_alt,
                        'Günlük görevlerinizi takip edin',
                        AppStyles.secondaryGradient,
                        () => Navigator.pushNamed(context, '/tasks'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Sohbet Geçmişi',
                        Icons.history,
                        'Önceki sohbetlerinizi görün',
                        const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                        ),
                        () => Navigator.pushNamed(context, '/chat-history'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Terapi Randevusu',
                        Icons.calendar_today,
                        'Uzmanlarla görüşün',
                        const LinearGradient(
                          colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
                        ),
                        () => Navigator.pushNamed(context, '/book'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Günlük İpuçları',
                        Icons.lightbulb_outline,
                        'Faydalı öneriler alın',
                        AppStyles.accentGradient,
                        () => Navigator.pushNamed(context, '/recommendations'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Ayarlar',
                        Icons.settings,
                        'Hesap ayarlarınızı yönetin',
                        const LinearGradient(
                          colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)],
                        ),
                        () => Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: AppStyles.elevatedCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppStyles.headingSmallStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppStyles.bodyMediumStyle.copyWith(
                    fontSize: 12,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 