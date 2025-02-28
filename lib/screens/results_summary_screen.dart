// results_summary_screen.dart
import 'package:flutter/material.dart';

class ResultsSummaryScreen extends StatelessWidget {
  const ResultsSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results Summary'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.red, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Blood Sample',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sample Date: February 28, 2025',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Key Findings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildResultItem(
                      name: 'Hemoglobin',
                      value: '14.5 g/dL',
                      normalRange: '13.5-17.5 g/dL',
                      status: 'Normal',
                    ),
                    const Divider(),
                    _buildResultItem(
                      name: 'White Blood Cells',
                      value: '11.2 K/uL',
                      normalRange: '4.5-11.0 K/uL',
                      status: 'High',
                      isAbnormal: true,
                    ),
                    const Divider(),
                    _buildResultItem(
                      name: 'Platelets',
                      value: '250 K/uL',
                      normalRange: '150-450 K/uL',
                      status: 'Normal',
                    ),
                    const Divider(),
                    _buildResultItem(
                      name: 'Glucose',
                      value: '95 mg/dL',
                      normalRange: '70-100 mg/dL',
                      status: 'Normal',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Analysis Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Your sample shows slightly elevated white blood cell count, which may indicate a minor infection or inflammation. All other parameters are within normal ranges. Please consult with your healthcare provider for a comprehensive evaluation.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/treatment_recommendation');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('View Treatment Recommendations'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: const Text('Return to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem({
    required String name,
    required String value,
    required String normalRange,
    required String status,
    bool isAbnormal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(name, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isAbnormal ? Colors.red : Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Range: $normalRange',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isAbnormal ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
