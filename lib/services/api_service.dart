import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';

class ApiService {
  // Update base URL to include a host
  final String baseUrl =
      'https://your-api-domain.com/api'; // Replace with your actual API domain

  // For testing/development, you can use a mock response instead
  final bool useMockData =
      true; // Set to false when you have a real API endpoint

  Future<List<ScanResult>> fetchScanResults({String? query}) async {
    if (useMockData) {
      // Return mock data without making an actual HTTP request
      return _getMockScanResults();
    }

    try {
      // Use 'random' for default, otherwise use search query
      final apiUrl =
          query != null && query.isNotEmpty
              ? '$baseUrl/scans?q=$query'
              : '$baseUrl/scans?q=random';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch scan results');
      }

      final data = jsonDecode(response.body);

      if (data['results'] == null) {
        return [];
      }

      final List<dynamic> resultsJson = data['results'];

      // If query is provided, limit to first 2 results
      if (query != null && query.isNotEmpty) {
        resultsJson.length = resultsJson.length > 2 ? 2 : resultsJson.length;
      }

      return resultsJson.map((json) => ScanResult.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching scan results: ${e.toString()}');
    }
  }

  Future<void> submitScan(ScanResult scan) async {
    if (useMockData) {
      // Just pretend to submit and return success
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scans'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(scan.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit scan');
      }
    } catch (e) {
      throw Exception('Error submitting scan: ${e.toString()}');
    }
  }

  // Mock data for testing without an API
  List<ScanResult> _getMockScanResults() {
    return [
      ScanResult(
        id: '1',
        name: 'Blood Test',
        type: 'blood',
        date: '2025-02-25',
        results: {
          'hemoglobin': '14.5 g/dL',
          'white_blood_cells': '7.5 K/uL',
          'platelets': '250 K/uL',
        },
      ),
      ScanResult(
        id: '2',
        name: 'Urine Analysis',
        type: 'urine',
        date: '2025-02-20',
        results: {'color': 'Yellow', 'clarity': 'Clear', 'glucose': 'Negative'},
      ),
      ScanResult(
        id: '3',
        name: 'Sputum Test',
        type: 'sputum',
        date: '2025-02-15',
        results: {
          'bacteria': 'None detected',
          'fungi': 'Negative',
          'mycobacteria': 'Not found',
        },
      ),
    ];
  }
}
