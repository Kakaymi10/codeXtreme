import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:file_selector/file_selector.dart'
    show XTypeGroup, XFile, openFile;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sample_type.dart';
import '../models/scan_result.dart';
import '../services/api_service.dart';
import '../services/supabase_config.dart';
import '../widgets/sample_type_button.dart';
import '../widgets/status_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final SupabaseClient _supabase = SupabaseConfig.client;
  bool _isLoading = false;
  String _error = '';
  bool _isOffline = false;

  // Patient information controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();
  String _selectedSampleType = '';

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  // Fetch user profile from Supabase to pre-fill organization details if available
  Future<void> _fetchUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data =
            await _supabase
                .from('profiles')
                .select()
                .eq('id', user.id)
                .single();

        // You could use organization info if needed
        // final organization = data['organization'];
      }
    } catch (e) {
      // Silently handle error - user profile might not exist yet
    }
  }

  // Show patient information modal
  void _showPatientInfoModal(String sampleType) {
    _selectedSampleType = sampleType;

    // Reset controllers
    _nameController.clear();
    _ageController.clear();
    _genderController.clear();
    _patientIdController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPatientInfoModal(),
    );
  }

  // Build the patient information modal
  Widget _buildPatientInfoModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Patient Information',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Sample Type: ${_getSampleTypeName(_selectedSampleType)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _getSampleColor(_selectedSampleType),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _patientIdController,
              decoration: const InputDecoration(
                labelText: 'Patient ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter patient ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter patient name';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter age';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _genderController,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter gender';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _savePatientInfo(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save patient information to Supabase and proceed to the next screen
  Future<void> _savePatientInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _supabase.auth.currentUser;

        if (user == null) {
          throw Exception('User not authenticated');
        }

        final timestamp = DateTime.now().toIso8601String();

        // Create patient record in Supabase
        final patientData = {
          'user_id': user.id,
          'patient_id': _patientIdController.text,
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'gender': _genderController.text,
          'sample_type': _selectedSampleType,
          'created_at': timestamp,
        };

        final response = await _supabase
            .from('patients')
            .insert(patientData)
            .select('id');
        final patientId = response[0]['id'];

        // Save current patient in SharedPreferences for easy access
        final patientInfo = {
          'supabase_id': patientId,
          'patientId': _patientIdController.text,
          'name': _nameController.text,
          'age': _ageController.text,
          'gender': _genderController.text,
          'sampleType': _selectedSampleType,
          'timestamp': timestamp,
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_patient', jsonEncode(patientInfo));

        Navigator.pop(context); // Close modal
        _showScanOptionsModal(patientId); // Show scan options
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving patient info: $e')),
        );
      }
    }
  }

  // Show scan options modal (microscope view or upload)
  void _showScanOptionsModal(String patientId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Scan Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.remove_red_eye, color: Colors.blue[700]),
                  title: const Text('View from Microscope'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToMicroscopeView(patientId);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.upload_file, color: Colors.green[700]),
                  title: const Text('Upload Cell Scan'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCameraScreen(patientId);
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Navigate to microscope view
  void _navigateToMicroscopeView(String patientId) {
    Navigator.pushNamed(
      context,
      '/file_viewer',
      arguments: {'sampleType': _selectedSampleType, 'patientId': patientId},
    );
  }

  Future<void> _navigateToCameraScreen(String patientId) async {
    try {
      // Show a loading indicator first to give feedback to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preparing file upload...')));

      // Define allowed file types based on platform
      final List<XTypeGroup> acceptedTypeGroups = <XTypeGroup>[
        XTypeGroup(
          label: 'Images',
          extensions: <String>['jpg', 'jpeg', 'png'],
          mimeTypes: <String>['image/jpeg', 'image/png'],
        ),
        XTypeGroup(
          label: 'Videos',
          extensions: <String>['mp4', 'mov'],
          mimeTypes: <String>['video/mp4', 'video/quicktime'],
        ),
      ];

      // Open file selector
      XFile? file = await openFile(acceptedTypeGroups: acceptedTypeGroups);

      if (file != null) {
        // Clear the initial snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show a new loading indicator for file processing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing file, please wait...')),
        );

        final user = _supabase.auth.currentUser;
        if (user == null) {
          throw Exception('User not authenticated');
        }

        // Create unique name for the file
        final fileName = file.name;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileExt = fileName.split('.').last.toLowerCase();
        bool isVideo = fileExt == 'mp4' || fileExt == 'mov';

        // Sanitize the file name to remove invalid characters
        final sanitizedFileName = fileName.replaceAll(
          RegExp(r'[^a-zA-Z0-9\.]'),
          '_',
        );

        // Prepare file for upload
        final fileBytes = await file.readAsBytes();
        final uploadPath =
            '${user.id}/$patientId/${timestamp}_$sanitizedFileName';

        // Upload file to Supabase storage in sample_scans bucket
        final fileResponse = await _supabase.storage
            .from('sample_scans')
            .uploadBinary(uploadPath, fileBytes);

        if (fileResponse.isEmpty) {
          throw Exception('Failed to upload file');
        }

        // Get public URL for the uploaded file
        final fileUrl = _supabase.storage
            .from('sample_scans')
            .getPublicUrl(uploadPath);
        print('File uploaded to: $fileUrl');
        // Try to create file data in patient_scans table
        try {
          // Store file metadata in patient_scans table
          final fileData = {
            'patient_id': patientId,
            'file_path': uploadPath, // Use the upload path
            'file_url': fileUrl,
            'file_name': sanitizedFileName,
            'is_video': isVideo,
            'sample_type': _selectedSampleType,
            'processing_status': 'uploaded', // Updated status
          };

          // Insert into patient_scans table
          final response = await _supabase
              .from('patient_scans')
              .insert(fileData)
              .select('id'); // Return the inserted record's ID

          print('File uploaded and metadata saved to database');

          // Get the ID of the inserted scan
          final scanId = response[0]['id'];

          // Clear any previous snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File processed successfully!')),
          );

          // Navigate directly to the file viewer screen
          Navigator.pushNamed(
            context,
            '/file_viewer',
            arguments: {
              'scanId': scanId,
              'filePath': uploadPath,
              'isVideo': isVideo,
              'fileName': sanitizedFileName,
              'fileUrl': fileUrl,
              'patientId': patientId,
              'sampleType': _selectedSampleType,
              'patientName': _nameController.text,
            },
          );
        } catch (dbError) {
          // Log error and show user-friendly message
          print('Error saving file metadata: $dbError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving file: ${dbError.toString()}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        // User canceled the picker
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No file selected')));
      }
    } catch (e) {
      // Clear any loading indicators
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Log the error for debugging
      print('Error in _navigateToCameraScreen: $e');

      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing file: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _getSampleTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'blood':
        return 'Blood Sample';
      case 'urine':
        return 'Urine Sample';
      case 'stool':
        return 'Stool Sample';
      case 'sputum':
        return 'Sputum Sample';
      default:
        return 'Unknown Sample';
    }
  }

  Color _getSampleColor(String type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('MultiScan AI'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
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
                                        _showPatientInfoModal('blood');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SampleTypeButton(
                                      sampleType: SampleType.urine(),
                                      onTap: () {
                                        _showPatientInfoModal('urine');
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
                                        _showPatientInfoModal('stool');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SampleTypeButton(
                                      sampleType: SampleType.sputum(),
                                      onTap: () {
                                        _showPatientInfoModal('sputum');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Instructions or welcome text
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.biotech,
                                    size: 80,
                                    color: Colors.blue[300],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Select a sample type above to begin scanning',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
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
}
