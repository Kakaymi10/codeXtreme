import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import '../services/supabase_config.dart';
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
  final SupabaseClient _supabase = SupabaseConfig.client;
  String? _filePath;
  bool _isVideo = false;
  String _sampleTitle = 'Blood Sample';
  bool _isProcessing = false;
  String _currentQuality = 'Original';
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String _selectedMode = 'Original';
  String? _patientId;
  String? _fileUrl;
  Map<String, dynamic>? _patientInfo;
  String? _scanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Get the arguments passed from the previous screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args.containsKey('filePath')) {
      setState(() {
        _filePath = args['filePath'];
        _isVideo = args['isVideo'] ?? false;
        _patientId = args['patientId'];
        _fileUrl = args['fileUrl'];
      });

      if (_isVideo) {
        _initVideoPlayer(_filePath!);
      }

      // Get patient info from Supabase if we have the patientId
      if (_patientId != null) {
        await _loadPatientInfoFromSupabase(_patientId!);
      }
    } else {
      // Try to load from shared preferences if not passed directly
      final prefs = await SharedPreferences.getInstance();
      final filePath = prefs.getString('uploaded_file_path');
      final isVideo = prefs.getBool('is_video') ?? false;
      final patientInfo = prefs.getString('current_patient');
      final patientId = prefs.getString('patient_id');
      final fileUrl = prefs.getString('file_url');

      if (filePath != null) {
        setState(() {
          _filePath = filePath;
          _isVideo = isVideo;
          _patientId = patientId;
          _fileUrl = fileUrl;
        });

        if (_isVideo) {
          _initVideoPlayer(filePath);
        }
      }

      if (patientInfo != null) {
        final decodedInfo = jsonDecode(patientInfo);
        final sampleType = decodedInfo['sampleType'];
        if (sampleType != null) {
          setState(() {
            _sampleTitle =
                '${sampleType[0].toUpperCase()}${sampleType.substring(1)} Sample';
            _patientInfo = decodedInfo;
          });
        }
      }

      // Get patient info from Supabase if we have the patientId
      if (_patientId != null) {
        await _loadPatientInfoFromSupabase(_patientId!);
      }
    }
  }

  Future<void> _loadPatientInfoFromSupabase(String patientId) async {
    try {
      final data =
          await _supabase
              .from('patients')
              .select()
              .eq('id', patientId)
              .single();

      if (data != null) {
        setState(() {
          _patientInfo = data;
          final sampleType = data['sample_type'];
          if (sampleType != null) {
            _sampleTitle =
                '${sampleType[0].toUpperCase()}${sampleType.substring(1)} Sample';
          }
        });
      }
    } catch (e) {
      // Handle error silently - we'll use what we have from SharedPreferences
      print('Error loading patient info: $e');
    }
  }

  Future<void> _initVideoPlayer(String filePath) async {
    _videoController = VideoPlayerController.file(File(filePath));

    await _videoController!.initialize();
    await _videoController!.setLooping(true);

    setState(() {
      _isVideoInitialized = true;
    });

    _videoController!.play();
  }

  void _enhanceQuality() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
        _currentQuality = 'Enhanced';
        _selectedMode = 'Enhanced';
      });

      // Update the scan record in Supabase
      _updateScanStatus('enhanced');
    });
  }

  void _segmentSample() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
        _selectedMode = 'Segmented';
      });

      // Update the scan record in Supabase
      _updateScanStatus('segmented');
    });
  }

  Future<void> _updateScanStatus(String processing) async {
    try {
      if (_patientId != null && _fileUrl != null) {
        // If scanId exists, update it, otherwise create a new scan record
        if (_scanId != null) {
          await _supabase
              .from('patient_scans')
              .update({
                'processing_status': processing,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', _scanId!);
        } else {
          // Get scan record by patient_id and file_url
          final data =
              await _supabase
                  .from('patient_scans')
                  .select('id')
                  .eq('patient_id', _patientId!)
                  .eq('file_url', _fileUrl!)
                  .maybeSingle();

          if (data != null) {
            _scanId = data['id'];
            await _supabase
                .from('patient_scans')
                .update({
                  'processing_status': processing,
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('id', _scanId!);
          }
        }
      }
    } catch (e) {
      print('Error updating scan status: $e');
    }
  }

  void _analyze() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate processing and create a result record in Supabase
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        if (_patientId != null) {
          final user = _supabase.auth.currentUser;
          if (user == null) {
            throw Exception('User not authenticated');
          }

          // Add an analysis result to Supabase
          final resultData = {
            'user_id': user.id,
            'patient_id': _patientId,
            'sample_type': _patientInfo?['sample_type'] ?? 'blood',
            'result': 'Normal',
            'details': 'Sample analyzed with AI. No abnormalities detected.',
            'created_at': DateTime.now().toIso8601String(),
          };

          final response =
              await _supabase
                  .from('scan_results')
                  .insert(resultData)
                  .select('id')
                  .single();

          final resultId = response['id'];

          setState(() {
            _isProcessing = false;
          });

          // Navigate to results page with the result ID
          Navigator.pushNamed(
            context,
            '/results_summary',
            arguments: {'resultId': resultId},
          );
        } else {
          setState(() {
            _isProcessing = false;
          });

          // Navigate to results summary without an ID
          Navigator.pushNamed(context, '/results_summary');
        }
      } catch (e) {
        print('Error creating analysis result: $e');
        setState(() {
          _isProcessing = false;
        });

        // Navigate anyway
        Navigator.pushNamed(context, '/results_summary');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background - Show either the uploaded file or black background
            SizedBox.expand(child: _buildMediaDisplay()),

            // Grid overlay - only show if we have media
            if (_filePath != null) _buildGridOverlay(),

            // Header with badges
            _buildHeader(),

            // Processing indicator
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Processing...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom controls
            if (_filePath != null) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaDisplay() {
    if (_filePath == null) {
      return Container(color: Colors.black);
    }

    if (_isVideo && _isVideoInitialized) {
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else if (!_isVideo) {
      return Image.file(
        File(_filePath!),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                _sampleTitle,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // Show settings dialog
                  _showPatientInfoDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_filePath != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                custom.Badge(
                  label: 'Mode: $_selectedMode',
                  backgroundColor: Colors.black.withOpacity(0.4),
                ),
                custom.Badge(
                  label: 'Quality: $_currentQuality',
                  backgroundColor:
                      _currentQuality == 'Enhanced'
                          ? const Color(0xFF22C55E).withOpacity(0.9)
                          : Colors.orange.withOpacity(0.9),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showPatientInfoDialog() {
    if (_patientInfo == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Patient Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${_patientInfo?['name'] ?? 'Unknown'}'),
                SizedBox(height: 8),
                Text('ID: ${_patientInfo?['patient_id'] ?? 'Unknown'}'),
                SizedBox(height: 8),
                Text('Age: ${_patientInfo?['age'] ?? 'Unknown'}'),
                SizedBox(height: 8),
                Text('Gender: ${_patientInfo?['gender'] ?? 'Unknown'}'),
                SizedBox(height: 8),
                Text(
                  'Sample Type: ${_patientInfo?['sample_type'] ?? 'Unknown'}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
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

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0),
              Colors.black.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode selection
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton('Original', _selectedMode == 'Original'),
                  const SizedBox(width: 10),
                  _buildModeButton('Enhanced', _selectedMode == 'Enhanced'),
                  const SizedBox(width: 10),
                  _buildModeButton('Segmented', _selectedMode == 'Segmented'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  'Enhance',
                  Icons.auto_fix_high,
                  _enhanceQuality,
                ),
                _buildActionButton(
                  'Segment',
                  Icons.content_cut,
                  _segmentSample,
                ),
                _buildActionButton('Analyze', Icons.analytics, _analyze),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.blue.withOpacity(0.8)
                  : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          mode,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
