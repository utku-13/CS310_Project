import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'screens/welcome_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_page.dart';
import 'screens/tasks_page.dart';
import 'screens/chat_page.dart';
import 'screens/chat_library_page.dart';
import 'screens/chat_history_page.dart';
import 'screens/book_therapy_page.dart';
import 'screens/daily_tips_page.dart';
import 'utils/app_styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/reset_password_screen.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure URL strategy for web
  usePathUrlStrategy();
  
  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure Firestore for better error handling
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false, // Offline modu kapat
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'AIWell - Ruh Sağlığı Asistanı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          scaffoldBackgroundColor: AppStyles.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppStyles.primaryColor,
            primary: AppStyles.primaryColor,
            secondary: AppStyles.secondaryColor,
            surface: AppStyles.surfaceColor,
            background: AppStyles.backgroundColor,
            error: AppStyles.errorColor,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppStyles.textPrimaryColor,
            onBackground: AppStyles.textPrimaryColor,
            onError: Colors.white,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: AppStyles.headingSmallStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: AppStyles.primaryButtonStyle,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: AppStyles.outlineButtonStyle,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppStyles.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              borderSide: BorderSide(
                color: AppStyles.textLightColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              borderSide: BorderSide(
                color: AppStyles.textLightColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              borderSide: const BorderSide(
                color: AppStyles.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              borderSide: const BorderSide(color: AppStyles.errorColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppStyles.defaultPadding,
              vertical: AppStyles.smallPadding,
            ),
            labelStyle: AppStyles.bodyMediumStyle.copyWith(
              color: AppStyles.textSecondaryColor,
            ),
            hintStyle: AppStyles.bodyMediumStyle.copyWith(
              color: AppStyles.textLightColor,
            ),
          ),
          cardTheme: CardThemeData(
            color: AppStyles.cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
            ),
            shadowColor: AppStyles.cardShadow.first.color,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.largeBorderRadius),
            ),
            backgroundColor: AppStyles.surfaceColor,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
            ),
            backgroundColor: AppStyles.textPrimaryColor,
            contentTextStyle: AppStyles.bodyStyle.copyWith(color: Colors.white),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
            ),
          ),
        ),
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          // Check if user is authenticated
          final user = FirebaseAuth.instance.currentUser;
          
          if (user != null) {
            // User is authenticated
            switch (settings.name) {
              case '/':
              case '/home':
                return MaterialPageRoute(builder: (_) => const HomeScreen());
              case '/welcome':
                return MaterialPageRoute(builder: (_) => const WelcomePage());
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/register':
                return MaterialPageRoute(builder: (_) => const RegisterScreen());
              case '/tasks':
                return MaterialPageRoute(builder: (_) => const TasksPage());
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsPage());
              case '/chat':
                return MaterialPageRoute(builder: (_) => ChatPage(key: UniqueKey()));
              case '/chat-library':
                return MaterialPageRoute(builder: (_) => const ChatLibraryPage());
              case '/chat-history':
                return MaterialPageRoute(builder: (_) => const ChatHistoryPage());
              case '/book':
                return MaterialPageRoute(builder: (_) => const BookTherapyPage());
              case '/recommendations':
                return MaterialPageRoute(builder: (_) => const DailyTipsPage());
              case '/reset-password':
                return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
              default:
                return MaterialPageRoute(builder: (_) => const HomeScreen());
            }
          } else {
            // User is not authenticated
            switch (settings.name) {
              case '/':
              case '/welcome':
                return MaterialPageRoute(builder: (_) => const WelcomePage());
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/register':
                return MaterialPageRoute(builder: (_) => const RegisterScreen());
              case '/reset-password':
                return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
              default:
                return MaterialPageRoute(builder: (_) => const WelcomePage());
            }
          }
        },
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/tasks': (context) => const TasksPage(),
          '/settings': (context) => const SettingsPage(),
          '/chat': (context) => ChatPage(key: UniqueKey()),
          '/chat-library': (context) => const ChatLibraryPage(),
          '/chat-history': (context) => const ChatHistoryPage(),
          '/book': (context) => const BookTherapyPage(),
          '/recommendations': (context) => const DailyTipsPage(),
          '/reset-password': (context) => const ResetPasswordScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppStyles.backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppStyles.primaryGradient,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: AppStyles.elevatedShadow,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'AIWell',
                      style: AppStyles.headingStyle.copyWith(
                        color: AppStyles.primaryColor,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Yapay Zeka Destekli Ruh Sağlığı Asistanı',
                      style: AppStyles.bodyMediumStyle.copyWith(
                        color: AppStyles.textSecondaryColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (snapshot.hasData) {
            // Use Navigator to properly handle the route
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/home');
            });
            return Scaffold(
              backgroundColor: AppStyles.backgroundColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          
          // Use Navigator to properly handle the route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return Scaffold(
            backgroundColor: AppStyles.backgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } catch (e) {
      // Fallback to WelcomePage if Firebase is not properly configured
      print('Firebase auth error: $e');
      return const WelcomePage();
    }
  }
}
