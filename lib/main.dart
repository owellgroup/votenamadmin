import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const VotenamAdminApp());
}

class VotenamAdminApp extends StatelessWidget {
  const VotenamAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Votenam Admin - Namibia Voting System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppTheme.primaryBlue,
        scaffoldBackgroundColor: AppTheme.lightGrey,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryBlue,
          primary: AppTheme.primaryBlue,
          secondary: AppTheme.accentRed,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppTheme.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.primaryButtonStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

