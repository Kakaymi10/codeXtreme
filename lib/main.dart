import 'package:flutter/material.dart';
import 'services/supabase_config.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';
import 'screens/blood_sample_camera_screen.dart';
import 'screens/analysis_progress_screen.dart';
import 'screens/results_summary_screen.dart';
import 'screens/treatment_recommendation_screen.dart';
import 'screens/file_viewer_screen.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/': (context) => const AuthWrapper(child: HomeScreen()),
        '/blood_camera':
            (context) => const AuthWrapper(child: BloodSampleCameraScreen()),

        '/camera': // Generic camera fallback
            (context) => const AuthWrapper(child: BloodSampleCameraScreen()),

        '/file_viewer':
            (context) => const AuthWrapper(child: FileViewerScreen()),

        '/analysis_progress':
            (context) => const AuthWrapper(child: AnalysisProgressScreen()),
        '/results_summary':
            (context) => const AuthWrapper(child: ResultsScreen()),
        '/treatment_recommendation':
            (context) =>
                const AuthWrapper(child: TreatmentRecommendationScreen()),
      },
    );
  }
}

// Wrapper widget to ensure user is authenticated
class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthRequiredState(child: child);
  }
}
