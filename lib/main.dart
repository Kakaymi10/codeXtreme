import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/blood_sample_camera_screen.dart';
import 'screens/analysis_progress_screen.dart';
// Import future screens when they're created
// import 'screens/treatment_recommendation_screen.dart';
// import 'screens/results_summary_screen.dart';

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
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/blood_camera': (context) => const BloodSampleCameraScreen(),
        '/analysis_progress': (context) => const AnalysisProgressScreen(),
        // Routes for future screens
        '/treatment_recommendation':
            (context) =>
                const Placeholder(), // Replace with actual screen when created
        '/results_summary':
            (context) =>
                const Placeholder(), // Replace with actual screen when created
      },
    );
  }
}
