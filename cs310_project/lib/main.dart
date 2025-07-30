import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'screens/reset_password_screen.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasData) {
            print('AuthWrapper - Navigating to HomeScreen');
            return const HomeScreen();
          }
          
          print('AuthWrapper - Navigating to WelcomePage');
          return const WelcomePage();
        },
      );
    } catch (e) {
      // Fallback to WelcomePage if Firebase is not properly configured
      print('Firebase auth error: $e');
      return const WelcomePage();
    }
  }
}
