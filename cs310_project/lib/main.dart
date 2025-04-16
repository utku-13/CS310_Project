import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';

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
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/book': (context) => const WelcomePage(),
        '/chat': (context) => const WelcomePage(),
        '/chat-history': (context) => const WelcomePage(),
        '/chat-library': (context) => const WelcomePage(),
        '/settings': (context) => const SettingsPage(),
        '/recommendations': (context) => const WelcomePage(),
      },
    );
  }
}
