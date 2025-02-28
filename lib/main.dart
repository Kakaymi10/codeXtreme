import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/blood_sample_camera_screen.dart';
import 'screens/analysis_progress_screen.dart';
import 'screens/results_summary_screen.dart';
import 'screens/treatment_recommendation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Sample Collection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.grey[100],
        // Add color scheme for consistent colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF1A73E8),
          error: const Color(0xFFE53935),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/blood_camera': (context) => const BloodSampleCameraScreen(),
        '/analysis_progress': (context) => const AnalysisProgressScreen(),
        '/results_summary': (context) => const ResultsScreen(),
        '/treatment_recommendation':
            (context) => const TreatmentRecommendationScreen(),
      },
    );
  }
}
