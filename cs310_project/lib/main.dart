import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';
import 'screens/tasks_page.dart';
import 'screens/chat_page.dart';
import 'screens/chat_library_page.dart';
import 'screens/chat_history_page.dart';
import 'screens/book_therapy_page.dart';
import 'screens/daily_tips_page.dart';
import 'utils/app_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Well App',
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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/tasks': (context) => const TasksPage(),
        '/settings': (context) => const SettingsPage(),
        '/chat': (context) => const ChatPage(),
        '/chat-library': (context) => const ChatLibraryPage(),
        '/chat-history': (context) => const ChatHistoryPage(),
        '/book': (context) => const BookTherapyPage(),
        '/recommendations': (context) => const DailyTipsPage(),
      },
    );
  }
}
