import 'package:flutter/material.dart';

/// A widget that displays a results summary with an image.
///
/// This widget creates a container with a border and rounded corners,
/// containing an image that maintains its aspect ratio.
class ResultsSummary extends StatelessWidget {
  /// The image to display in the results summary.
  /// This can be either an icon or a placeholder image.
  final Widget image;

  /// Creates a ResultsSummary widget.
  ///
  /// The [image] parameter is required and specifies the image to display.
  const ResultsSummary({
    Key? key,
    required this.image,
    required String imageUrl,
  }) : super(key: key);

  /// Factory constructor to create a ResultsSummary with an icon
  factory ResultsSummary.withIcon({
    Key? key,
    required IconData icon,
    required Color iconColor,
    double iconSize = 80.0,
  }) {
    return ResultsSummary(
      key: key,
      image: Icon(icon, color: iconColor, size: iconSize),
      imageUrl: '',
    );
  }

  /// Factory constructor to create a ResultsSummary with a placeholder
  factory ResultsSummary.withPlaceholder({
    Key? key,
    String text = 'Results Summary',
  }) {
    return ResultsSummary(
      key: key,
      image: Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      imageUrl: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromRGBO(206, 212, 218, 1),
            width: 2,
          ),
        ),
        clipBehavior:
            Clip.antiAlias, // Ensures the image respects the border radius
        child: AspectRatio(
          aspectRatio: 1 / 0.46, // Match the aspect ratio from the design
          child: image,
        ),
      ),
    );
  }
}
