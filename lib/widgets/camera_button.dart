import 'package:flutter/material.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Simulate taking a photo and navigate to analysis progress
        _captureAndNavigate(context);
      },
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD1D5DB), width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _captureAndNavigate(BuildContext context) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Simulate capture processing time
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog and navigate to analysis progress
    Navigator.of(context).pop(); // Close loading dialog
    Navigator.pushNamed(context, '/analysis_progress');
  }
}
