import 'package:cognai/ui/chatbot_screen.dart';
import 'package:cognai/ui/splash_screen.dart';
import 'package:cognai/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognai Chatbot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // adicione isso para tema claro
      darkTheme: AppTheme.darkTheme,
      home: SplashScreen(),
      routes: {
        '/home': (context) => const BotScreen(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
}
