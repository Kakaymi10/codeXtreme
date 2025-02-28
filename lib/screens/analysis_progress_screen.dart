import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../widgets/progress_circle.dart';
import '../widgets/analysis_item_widget.dart';
import '../widgets/loading_dots.dart';
import '../models/analysis_item.dart';
import '../services/analysis_service.dart';

class AnalysisProgressScreen extends StatefulWidget {
  const AnalysisProgressScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisProgressScreen> createState() => _AnalysisProgressScreenState();
}

class _AnalysisProgressScreenState extends State<AnalysisProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  final AnalysisService _analysisService = AnalysisService();
  double _progress = 0.68; // Initial progress value

  @override
  void initState() {
    super.initState();

    // Set up animation for progress circle
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: _progress).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Listen for progress updates
    _analysisService.progressStream.listen((progress) {
      setState(() {
        _progress = progress;
        _progressAnimation = Tween<double>(
          begin: _progressAnimation.value,
          end: progress,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        _animationController.forward(from: 0.0);
      });
    });

    // Start analysis simulation
    _analysisService.startAnalysis();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _analysisService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match app background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF3F4F6),
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: SingleChildScrollView(child: _buildContent())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const BackButton(),
            behavior: HitTestBehavior.opaque,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Analysis in Progress',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                semanticsLabel: 'Analysis in Progress Screen',
              ),
            ),
          ),
          // Empty SizedBox to balance the back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProgressCircle(),
        const SizedBox(height: 32),
        _buildImageContainer(),
        const SizedBox(height: 32),
        _buildAnalysisBox(),
        const SizedBox(height: 32),
        _buildProcessingStatus(),
      ],
    );
  }

  Widget _buildProgressCircle() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return ProgressCircle(
          progress: _progressAnimation.value,
          size: 192,
          backgroundColor: const Color(0xFFE5E7EB),
          progressColor: const Color(0xFF4F46E5),
        );
      },
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: MediaQuery.of(context).size.width > 640 ? 256 : double.infinity,
      height:
          MediaQuery.of(context).size.width > 640
              ? 256
              : MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
            blurRadius: 15,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        'https://cdn.builder.io/api/v1/image/assets/TEMP/120f55dcb85593bdcc81db7f3d0f57e561c8294a',
        fit: BoxFit.cover,
        semanticLabel: 'Medical scan image',
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              color: const Color(0xFF4F46E5),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 64),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisBox() {
    return Container(
      width: double.infinity,
      padding:
          MediaQuery.of(context).size.width > 640
              ? const EdgeInsets.all(24)
              : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MicroscopeIcon(),
              const SizedBox(width: 12),
              Text(
                'Checking for:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  color: Colors.black,
                ),
                semanticsLabel: 'Checking for the following conditions',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children:
                _analysisService.analysisItems
                    .map((item) => AnalysisItemWidget(item: item))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AIProcessingIcon(),
        const SizedBox(width: 8),
        const Text(
          'AI Processing',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF4F46E5),
          ),
        ),
        const SizedBox(width: 4),
        const LoadingDots(color: Color(0xFF4F46E5), size: 8, spacing: 4),
      ],
    );
  }
}

// Custom Painters for Icons
class BackButton extends StatelessWidget {
  const BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 20,
      child: CustomPaint(
        painter: BackButtonPainter(),
        size: const Size(18, 20),
      ),
    );
  }
}

class BackButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = const Color(0xFF374151)
          ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0.367188, 9.11719);
    path.cubicTo(-0.121094, 9.60547, -0.121094, 10.3984, 0.367188, 10.8867);
    path.lineTo(6.61719, 17.1367);
    path.cubicTo(7.10547, 17.625, 7.89844, 17.625, 8.38672, 17.1367);
    path.cubicTo(8.875, 16.6484, 8.875, 15.8555, 8.38672, 15.3672);
    path.lineTo(4.26562, 11.25);
    path.lineTo(16.25, 11.25);
    path.cubicTo(16.9414, 11.25, 17.5, 10.6914, 17.5, 10);
    path.cubicTo(17.5, 9.30859, 16.9414, 8.75, 16.25, 8.75);
    path.lineTo(4.26953, 8.75);
    path.lineTo(8.38281, 4.63281);
    path.cubicTo(8.87109, 4.14453, 8.87109, 3.35156, 8.38281, 2.86328);
    path.cubicTo(7.89453, 2.375, 7.10156, 2.375, 6.61328, 2.86328);
    path.lineTo(0.363281, 9.11328);
    path.lineTo(0.367188, 9.11719);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MicroscopeIcon extends StatelessWidget {
  const MicroscopeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: MicroscopePainter(),
        size: const Size(20, 20),
      ),
    );
  }
}

class MicroscopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = const Color(0xFF4F46E5)
          ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(6.25, 1.25);
    path.cubicTo(6.25, 0.558594, 6.80859, 0, 7.5, 0);
    path.lineTo(8.75, 0);
    path.cubicTo(9.44141, 0, 10, 0.558594, 10, 1.25);
    path.cubicTo(10.6914, 1.25, 11.25, 1.80859, 11.25, 2.5);
    path.lineTo(11.25, 11.25);
    path.cubicTo(11.25, 11.9414, 10.6914, 12.5, 10, 12.5);
    path.cubicTo(10, 13.1914, 9.44141, 13.75, 8.75, 13.75);
    path.lineTo(7.5, 13.75);
    path.cubicTo(6.80859, 13.75, 6.25, 13.1914, 6.25, 12.5);
    path.cubicTo(5.55859, 12.5, 5, 11.9414, 5, 11.25);
    path.lineTo(5, 2.5);
    path.cubicTo(5, 1.80859, 5.55859, 1.25, 6.25, 1.25);
    path.moveTo(1.25, 17.5);
    path.lineTo(12.5, 17.5);
    path.cubicTo(15.2617, 17.5, 17.5, 15.2617, 17.5, 12.5);
    path.cubicTo(17.5, 9.73828, 15.2617, 7.5, 12.5, 7.5);
    path.lineTo(12.5, 5);
    path.cubicTo(16.6406, 5, 20, 8.35938, 20, 12.5);
    path.cubicTo(20, 14.4219, 19.2773, 16.1719, 18.0898, 17.5);
    path.lineTo(18.75, 17.5);
    path.cubicTo(19.4414, 17.5, 20, 18.0586, 20, 18.75);
    path.cubicTo(20, 19.4414, 19.4414, 20, 18.75, 20);
    path.lineTo(12.5, 20);
    path.lineTo(1.25, 20);
    path.cubicTo(0.558594, 20, 0, 19.4414, 0, 18.75);
    path.cubicTo(0, 18.0586, 0.558594, 17.5, 1.25, 17.5);
    path.moveTo(4.375, 15);
    path.lineTo(11.875, 15);
    path.cubicTo(12.2188, 15, 12.5, 15.2812, 12.5, 15.625);
    path.cubicTo(12.5, 15.9688, 12.2188, 16.25, 11.875, 16.25);
    path.lineTo(4.375, 16.25);
    path.cubicTo(4.03125, 16.25, 3.75, 15.9688, 3.75, 15.625);
    path.cubicTo(3.75, 15.2812, 4.03125, 15, 4.375, 15);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AIProcessingIcon extends StatelessWidget {
  const AIProcessingIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 20,
      child: CustomPaint(
        painter: AIProcessingPainter(),
        size: const Size(25, 20),
      ),
    );
  }
}

class AIProcessingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = const Color(0xFF4F46E5)
          ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(12.8125, 0.224);
    path.cubicTo(13.5039, 0.224, 14.0625, 0.782593, 14.0625, 1.474);
    path.lineTo(14.0625, 3.974);
    path.lineTo(18.75, 3.974);
    path.cubicTo(20.3047, 3.974, 21.5625, 5.23181, 21.5625, 6.7865);
    path.lineTo(21.5625, 17.4115);
    path.cubicTo(21.5625, 18.9662, 20.3047, 20.224, 18.75, 20.224);
    path.lineTo(6.875, 20.224);
    path.cubicTo(5.32031, 20.224, 4.0625, 18.9662, 4.0625, 17.4115);
    path.lineTo(4.0625, 6.7865);
    path.cubicTo(4.0625, 5.23181, 5.32031, 3.974, 6.875, 3.974);
    path.lineTo(11.5625, 3.974);
    path.lineTo(11.5625, 1.474);
    path.cubicTo(11.5625, 0.782593, 12.1211, 0.224, 12.8125, 0.224);
    path.moveTo(8.4375, 15.224);
    path.cubicTo(8.09375, 15.224, 7.8125, 15.5052, 7.8125, 15.849);
    path.cubicTo(7.8125, 16.1927, 8.09375, 16.474, 8.4375, 16.474);
    path.lineTo(9.6875, 16.474);
    path.cubicTo(10.0312, 16.474, 10.3125, 16.1927, 10.3125, 15.849);
    path.cubicTo(10.3125, 15.5052, 10.0312, 15.224, 9.6875, 15.224);
    path.lineTo(8.4375, 15.224);
    path.moveTo(12.1875, 15.224);
    path.cubicTo(11.8438, 15.224, 11.5625, 15.5052, 11.5625, 15.849);
    path.cubicTo(11.5625, 16.1927, 11.8438, 16.474, 12.1875, 16.474);
    path.lineTo(13.4375, 16.474);
    path.cubicTo(13.7812, 16.474, 14.0625, 16.1927, 14.0625, 15.849);
    path.cubicTo(14.0625, 15.5052, 13.7812, 15.224, 13.4375, 15.224);
    path.lineTo(12.1875, 15.224);
    path.moveTo(15.9375, 15.224);
    path.cubicTo(15.5938, 15.224, 15.3125, 15.5052, 15.3125, 15.849);
    path.cubicTo(15.3125, 16.1927, 15.5938, 16.474, 15.9375, 16.474);
    path.lineTo(17.1875, 16.474);
    path.cubicTo(17.5312, 16.474, 17.8125, 16.1927, 17.8125, 15.849);
    path.cubicTo(17.8125, 15.5052, 17.5312, 15.224, 17.1875, 15.224);
    path.lineTo(15.9375, 15.224);
    path.moveTo(10.625, 10.224);
    path.cubicTo(10.625, 9.8096, 10.4604, 9.41217, 10.1674, 9.11914);
    path.cubicTo(9.87433, 8.82612, 9.4769, 8.6615, 9.0625, 8.6615);
    path.cubicTo(8.6481, 8.6615, 8.25067, 8.82612, 7.95765, 9.11914);
    path.cubicTo(7.66462, 9.41217, 7.5, 9.8096, 7.5, 10.224);
    path.cubicTo(7.5, 10.6384, 7.66462, 11.0358, 7.95765, 11.3289);
    path.cubicTo(8.25067, 11.6219, 8.6481, 11.7865, 9.0625, 11.7865);
    path.cubicTo(9.4769, 11.7865, 9.87433, 11.6219, 10.1674, 11.3289);
    path.cubicTo(10.4604, 11.0358, 10.625, 10.6384, 10.625, 10.224);
    path.moveTo(16.5625, 11.7865);
    path.cubicTo(16.9769, 11.7865, 17.3743, 11.6219, 17.6674, 11.3289);
    path.cubicTo(17.9604, 11.0358, 18.125, 10.6384, 18.125, 10.224);
    path.cubicTo(18.125, 9.8096, 17.9604, 9.41217, 17.6674, 9.11914);
    path.cubicTo(17.3743, 8.82612, 16.9769, 8.6615, 16.5625, 8.6615);
    path.cubicTo(16.1481, 8.6615, 15.7507, 8.82612, 15.4576, 9.11914);
    path.cubicTo(15.1646, 9.41217, 15, 9.8096, 15, 10.224);
    path.cubicTo(15, 10.6384, 15.1646, 11.0358, 15.4576, 11.3289);
    path.cubicTo(15.7507, 11.6219, 16.1481, 11.7865, 16.5625, 11.7865);
    path.moveTo(2.1875, 8.974);
    path.lineTo(2.8125, 8.974);
    path.lineTo(2.8125, 16.474);
    path.lineTo(2.1875, 16.474);
    path.cubicTo(1.15234, 16.474, 0.3125, 15.6342, 0.3125, 14.599);
    path.lineTo(0.3125, 10.849);
    path.cubicTo(0.3125, 9.81384, 1.15234, 8.974, 2.1875, 8.974);
    path.moveTo(23.4375, 8.974);
    path.cubicTo(24.4727, 8.974, 25.3125, 9.81384, 25.3125, 10.849);
    path.lineTo(25.3125, 14.599);
    path.cubicTo(25.3125, 15.6342, 24.4727, 16.474, 23.4375, 16.474);
    path.lineTo(22.8125, 16.474);
    path.lineTo(22.8125, 8.974);
    path.lineTo(23.4375, 8.974);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
