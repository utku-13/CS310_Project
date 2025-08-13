import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              child: Column(
                children: [
                  // Logo ve Başlık Bölümü
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              gradient: AppStyles.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppStyles.elevatedShadow,
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppStyles.extraLargePadding),
                        
                        // App Name
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'AIWell',
                              style: AppStyles.headingStyle.copyWith(
                                color: AppStyles.primaryColor,
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppStyles.defaultPadding),
                        
                        // Tagline
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Yapay Zeka Destekli\nRuh Sağlığı Asistanı',
                              style: AppStyles.bodyMediumStyle.copyWith(
                                fontSize: 18,
                                color: AppStyles.textSecondaryColor,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppStyles.smallPadding),
                        
                        // Subtitle
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Kendinizi daha iyi hissetmeniz için buradayız',
                              style: AppStyles.bodySmallStyle.copyWith(
                                fontSize: 14,
                                color: AppStyles.textLightColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Buttons Section
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Login Button
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: AppStyles.primaryGradient,
                              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                              boxShadow: AppStyles.elevatedShadow,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppStyles.defaultPadding,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.login,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Giriş Yap',
                                    style: AppStyles.buttonStyle.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppStyles.defaultPadding),
                        
                        // Signup Button
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                              border: Border.all(
                                color: AppStyles.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppStyles.defaultPadding,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_add,
                                    color: AppStyles.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kayıt Ol',
                                    style: AppStyles.buttonStyle.copyWith(
                                      color: AppStyles.primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppStyles.largePadding),
                        
                        // Features Preview
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFeaturePreview(
                                Icons.chat_bubble_outline,
                                'AI Sohbet',
                                AppStyles.primaryColor,
                              ),
                              _buildFeaturePreview(
                                Icons.task_alt,
                                'Görevler',
                                AppStyles.secondaryColor,
                              ),
                              _buildFeaturePreview(
                                Icons.lightbulb_outline,
                                'İpuçları',
                                AppStyles.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePreview(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppStyles.captionStyle.copyWith(
            color: AppStyles.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 