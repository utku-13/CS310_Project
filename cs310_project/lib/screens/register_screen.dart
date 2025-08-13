import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        
        // AuthWrapper will automatically handle navigation
        // No need to manually navigate
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppStyles.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_add,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Hesap Oluştur',
              style: AppStyles.headingSmallStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.defaultPadding),
                  child: Column(
                    children: [
                      // Header Section
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: AppStyles.primaryGradient,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: AppStyles.elevatedShadow,
                              ),
                              child: const Icon(
                                Icons.person_add,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppStyles.defaultPadding),
                            Text(
                              'AIWell\'e Hoş Geldiniz',
                              style: AppStyles.headingMediumStyle.copyWith(
                                color: AppStyles.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppStyles.smallPadding),
                            Text(
                              'Hesabınızı oluşturarak başlayın',
                              style: AppStyles.bodyMediumStyle.copyWith(
                                color: AppStyles.textSecondaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      // Form Section
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppStyles.largePadding),
                          decoration: AppStyles.elevatedCardDecoration,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: AppStyles.largePadding),
                                  child: Text(
                                    'Kayıt Formu',
                                    style: AppStyles.headingSmallStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                
                                // Name Field
                                TextFormField(
                                  controller: _nameController,
                                  decoration: AppStyles.textFieldDecoration(
                                    'Ad Soyad',
                                    hint: 'Adınızı ve soyadınızı girin',
                                    prefixIcon: Icons.person_outline,
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen adınızı girin';
                                    }
                                    if (value.trim().split(' ').length < 2) {
                                      return 'Lütfen ad ve soyadınızı girin';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppStyles.defaultPadding),
                                
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  decoration: AppStyles.textFieldDecoration(
                                    'E-posta Adresi',
                                    hint: 'ornek@email.com',
                                    prefixIcon: Icons.email_outlined,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen e-posta adresinizi girin';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Lütfen geçerli bir e-posta adresi girin';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppStyles.defaultPadding),
                                
                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: AppStyles.textFieldDecoration(
                                    'Şifre',
                                    hint: 'En az 6 karakter',
                                    prefixIcon: Icons.lock_outline,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword 
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                        color: AppStyles.textSecondaryColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen şifrenizi girin';
                                    }
                                    if (value.length < 6) {
                                      return 'Şifre en az 6 karakter olmalıdır';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppStyles.defaultPadding),
                                
                                // Confirm Password Field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: AppStyles.textFieldDecoration(
                                    'Şifre Tekrarı',
                                    hint: 'Şifrenizi tekrar girin',
                                    prefixIcon: Icons.lock_outline,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword 
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                        color: AppStyles.textSecondaryColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _obscureConfirmPassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen şifrenizi tekrar girin';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Şifreler eşleşmiyor';
                                    }
                                    return null;
                                  },
                                ),
                                
                                // Error Message
                                if (_errorMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: AppStyles.defaultPadding),
                                    padding: const EdgeInsets.all(AppStyles.smallPadding),
                                    decoration: BoxDecoration(
                                      color: AppStyles.errorColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
                                      border: Border.all(
                                        color: AppStyles.errorColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: AppStyles.errorColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: AppStyles.bodyMediumStyle.copyWith(
                                              color: AppStyles.errorColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                const SizedBox(height: AppStyles.largePadding),
                                
                                // Register Button
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: AppStyles.primaryGradient,
                                    borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                                    boxShadow: AppStyles.elevatedShadow,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
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
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_add,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Hesap Oluştur',
                                                style: AppStyles.buttonStyle.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom Links
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zaten hesabınız var mı?',
                              style: AppStyles.bodyMediumStyle.copyWith(
                                color: AppStyles.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: AppStyles.smallPadding),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppStyles.defaultPadding,
                                  vertical: AppStyles.smallPadding,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppStyles.primaryColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                                ),
                                child: Text(
                                  'Giriş Yap',
                                  style: AppStyles.buttonStyle.copyWith(
                                    color: AppStyles.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
        ),
      ),
    );
  }
} 