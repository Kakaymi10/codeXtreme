// treatment_recommendation_screen.dart
import 'package:flutter/material.dart';

class TreatmentRecommendationScreen extends StatelessWidget {
  const TreatmentRecommendationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Recommendations'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Based on your sample analysis',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommended Actions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildRecommendationCard(
              title: 'Primary Care Follow-up',
              description:
                  'Schedule an appointment with your primary care provider within 7 days',
              icon: Icons.calendar_today,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(
              title: 'Medication Adjustment',
              description:
                  'Review current medication schedule with your doctor',
              icon: Icons.medical_services,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(
              title: 'Dietary Changes',
              description:
                  'Increase fluid intake and reduce sodium consumption',
              icon: Icons.restaurant,
              color: Colors.orange,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/results_summary');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('View Full Results'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
