import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/badge.dart' as custom;
import '../widgets/focus_area.dart';
import '../widgets/camera_button.dart';

class BloodSampleCameraScreen extends StatefulWidget {
  const BloodSampleCameraScreen({super.key});

  @override
  State<BloodSampleCameraScreen> createState() =>
      _BloodSampleCameraScreenState();
}

class _BloodSampleCameraScreenState extends State<BloodSampleCameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.9),
            ),

            // Grid overlay
            _buildGridOverlay(),

            // Header with badges
            _buildHeader(),

            // Focus area
            const Center(child: FocusArea()),

            // Focus text
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'Tap anywhere to focus',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),

            // Camera button
            const Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(child: CameraButton()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.5), Colors.black.withOpacity(0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          custom.Badge(
            label: 'Blood Sample',
            backgroundColor: Colors.black.withOpacity(0.4),
          ),
          custom.Badge(
            label: 'Quality: Good',
            backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay() {
    return SizedBox.expand(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
