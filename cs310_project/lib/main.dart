import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  
  // Configure Firestore for offline support
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env file not found. Make sure to create it with your GEMINI_API_KEY');
  }
  
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
        title: 'CS310 Project',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          scaffoldBackgroundColor: AppStyles.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppStyles.primaryColor,
            primary: AppStyles.primaryColor,
            secondary: AppStyles.secondaryColor,
          ),
        ),
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          print('MyApp - Route requested: ${settings.name}');
          
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
          print('AuthWrapper - ConnectionState: ${snapshot.connectionState}');
          print('AuthWrapper - HasData: ${snapshot.hasData}');
          print('AuthWrapper - HasError: ${snapshot.hasError}');
          if (snapshot.hasError) {
            print('AuthWrapper - Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            print('AuthWrapper - User: ${snapshot.data?.email}');
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('AuthWrapper - Showing loading indicator');
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData) {
            print('AuthWrapper - User authenticated, navigating to home');
            // Use Navigator to properly handle the route
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/home');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          print('AuthWrapper - User not authenticated, navigating to welcome');
          // Use Navigator to properly handle the route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
