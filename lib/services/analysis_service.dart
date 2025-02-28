import 'dart:async';
import '../models/analysis_item.dart';

class AnalysisService {
  // Simulated analysis progress
  double _progress = 0.0;
  final _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  // Analysis items
  final List<AnalysisItem> _analysisItems = [
    AnalysisItem(name: 'Pneumonia Detection', isActive: true),
    AnalysisItem(name: 'Tuberculosis Screening'),
    AnalysisItem(name: 'Lung Nodule Analysis'),
  ];
  List<AnalysisItem> get analysisItems => _analysisItems;

  // Singleton pattern
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  AnalysisService._internal() {
    // Initialize with starting progress
    _progress = 0.68; // 68%
    _progressController.add(_progress);
  }

  // Start analysis simulation
  void startAnalysis() {
    // Simulate progress updates
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_progress < 1.0) {
        _progress += 0.05;
        if (_progress > 1.0) _progress = 1.0;
        _progressController.add(_progress);

        // Update active analysis item based on progress
        if (_progress > 0.75 && !_analysisItems[1].isActive) {
          _analysisItems[1] = AnalysisItem(
            name: _analysisItems[1].name,
            isActive: true,
          );
        }
        if (_progress > 0.9 && !_analysisItems[2].isActive) {
          _analysisItems[2] = AnalysisItem(
            name: _analysisItems[2].name,
            isActive: true,
          );
        }
      } else {
        timer.cancel();
      }
    });
  }

  void dispose() {
    _progressController.close();
  }
}
