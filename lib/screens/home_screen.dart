import 'package:flutter/material.dart';
import '../models/sample_type.dart';
import '../models/scan_result.dart';
import '../services/api_service.dart';
import '../widgets/sample_type_button.dart';
import '../widgets/status_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<ScanResult> _scanResults = [];
  bool _isLoading = false;
  String _error = '';
  final bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchScanResults();
  }

  Future<void> _fetchScanResults({String? query}) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final results = await _apiService.fetchScanResults(query: query);
      setState(() {
        _scanResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCED4DA), width: 2),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with offline status and logo
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusIndicator(isOffline: _isOffline),
                              Text(
                                'MultiScan AI',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Title
                        Padding(
                          padding: const EdgeInsets.only(left: 15, top: 24),
                          child: Text(
                            'Select Sample Type',
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            semanticsLabel: 'Select Sample Type',
                          ),
                        ),

                        // Sample type buttons
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 34,
                            bottom: 25,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SampleTypeButton(
                                      sampleType: SampleType.blood(),
                                      onTap: () {
                                        // Handle blood sample selection
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SampleTypeButton(
                                      sampleType: SampleType.urine(),
                                      onTap: () {
                                        // Handle urine sample selection
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: SampleTypeButton(
                                      sampleType: SampleType.stool(),
                                      onTap: () {
                                        // Handle stool sample selection
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SampleTypeButton(
                                      sampleType: SampleType.sputum(),
                                      onTap: () {
                                        // Handle sputum sample selection
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Recent scans section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent Scans',
                                style: const TextStyle(
                                  color: Color(0xFF374151),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                                semanticsLabel: 'Recent Scans',
                              ),
                              const SizedBox(height: 27),
                              if (_isLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (_error.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _error,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              else if (_scanResults.isEmpty)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No scan results yet',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _scanResults.length,
                                  itemBuilder: (context, index) {
                                    final scan = _scanResults[index];
                                    return ListTile(
                                      title: Text(scan.name),
                                      subtitle: Text(scan.date),
                                      leading: Icon(
                                        _getScanIcon(scan.type),
                                        color: _getScanColor(scan.type),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getScanIcon(String type) {
    switch (type.toLowerCase()) {
      case 'blood':
        return Icons.water_drop;
      case 'urine':
        return Icons.science;
      case 'stool':
        return Icons.circle;
      case 'sputum':
        return Icons.air;
      default:
        return Icons.science;
    }
  }

  Color _getScanColor(String type) {
    switch (type.toLowerCase()) {
      case 'blood':
        return Colors.red;
      case 'urine':
        return Colors.amber;
      case 'stool':
        return Colors.brown;
      case 'sputum':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
