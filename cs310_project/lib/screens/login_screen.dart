import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        
        _emailController.clear();
        _passwordController.clear();
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.defaultPadding),
                  child: Column(
                    children: [
                      // Logo ve Başlık Bölümü
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: AppStyles.primaryGradient,
                                borderRadius: BorderRadius.circular(60),
                                boxShadow: AppStyles.elevatedShadow,
                              ),
                              child: const Icon(
                                Icons.psychology,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppStyles.largePadding),
                            Text(
                              'AIWell',
                              style: AppStyles.headingStyle.copyWith(
                                color: AppStyles.primaryColor,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppStyles.smallPadding),
                            Text(
                              'Yapay Zeka Destekli\nRuh Sağlığı Asistanı',
                              style: AppStyles.bodyMediumStyle.copyWith(
                                fontSize: 18,
                                color: AppStyles.textSecondaryColor,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      // Form Bölümü
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
                                    'Giriş Yap',
                                    style: AppStyles.headingMediumStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                
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
                                    hint: 'Şifrenizi girin',
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
                                
                                // Login Button
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: AppStyles.primaryGradient,
                                    borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                                    boxShadow: AppStyles.elevatedShadow,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
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
                                        : Text(
                                            'Giriş Yap',
                                            style: AppStyles.buttonStyle.copyWith(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                  ),
                                ),
                                
                                const SizedBox(height: AppStyles.defaultPadding),
                                
                                // Forgot Password
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/reset-password');
                                  },
                                  child: Text(
                                    'Şifremi Unuttum',
                                    style: AppStyles.bodyMediumStyle.copyWith(
                                      color: AppStyles.primaryColor,
                                      fontWeight: FontWeight.w500,
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
                              'Hesabınız yok mu?',
                              style: AppStyles.bodyMediumStyle.copyWith(
                                color: AppStyles.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: AppStyles.smallPadding),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
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
                                  'Kayıt Ol',
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