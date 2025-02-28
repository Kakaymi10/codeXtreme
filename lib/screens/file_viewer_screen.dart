import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/supabase_config.dart';

class FileViewerScreen extends StatefulWidget {
  const FileViewerScreen({Key? key}) : super(key: key);

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // File properties
  String? _filePath;
  String? _fileUrl;
  String? _fileName;
  String? _patientId;
  String? _sampleType;
  String? _patientName;
  bool _isVideo = false;
  bool _isProcessing = false;

  // Video player
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  // Processing states
  bool _isEnhanced = false;
  bool _isSegmented = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArguments();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _loadArguments() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    setState(() {
      _filePath = args['filePath'];
      _fileUrl = args['fileUrl'];
      _fileName = args['fileName'];
      _patientId = args['patientId'];
      _isVideo = args['isVideo'] ?? false;
      _sampleType = args['sampleType'];
      _patientName = args['patientName'];
    });

    if (_isVideo) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_fileUrl != null) {
      final controller = VideoPlayerController.network(_fileUrl!);
      await controller.initialize();

      if (mounted) {
        setState(() {
          _videoController = controller;
          _isInitialized = true;
        });

        _videoController!.play();
      }
    }
  }

  Future<void> _toggleEnhance() async {
    if (_isProcessing) return;

    if (_isEnhanced) {
      setState(() {
        _isEnhanced = false;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulating image enhancement processing
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isEnhanced = true;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _toggleSegment() async {
    if (_isProcessing) return;

    if (_isSegmented) {
      setState(() {
        _isSegmented = false;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulating image segmentation processing
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isSegmented = true;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _analyzeResults() {
    // Navigate to the analysis screen
    Navigator.pushNamed(
      context,
      '/analysis',
      arguments: {
        'fileUrl': _fileUrl,
        'isEnhanced': _isEnhanced,
        'isSegmented': _isSegmented,
        'patientId': _patientId,
        'sampleType': _sampleType,
        'patientName': _patientName,
      },
    );
  }

  Widget _buildMediaPreview() {
    if (_isVideo) {
      if (_isInitialized && _videoController != null) {
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_videoController!),
              VideoProgressIndicator(_videoController!, allowScrubbing: true),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    } else {
      // For images
      if (_fileUrl != null) {
        return CachedNetworkImage(
          imageUrl: _fileUrl!,
          placeholder:
              (context, url) =>
                  const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.contain,
        );
      } else if (_filePath != null && !kIsWeb) {
        return Image.file(File(_filePath!), fit: BoxFit.contain);
      } else {
        return const Center(child: Text('No image available'));
      }
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

  IconData _getSampleIcon(String type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_fileName ?? 'File Viewer'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Patient info card
          if (_patientName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _getSampleColor(
                      _sampleType ?? '',
                    ).withOpacity(0.2),
                    child: Icon(
                      _getSampleIcon(_sampleType ?? ''),
                      color: _getSampleColor(_sampleType ?? ''),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _patientName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _getSampleTypeName(_sampleType ?? ''),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Media preview (image or video)
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Center(child: _buildMediaPreview()),
            ),
          ),

          // Action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Toggle buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildToggleButton(
                        icon: Icons.auto_fix_high,
                        label: 'Enhance',
                        isActive: _isEnhanced,
                        onPressed: _toggleEnhance,
                        activeColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildToggleButton(
                        icon: Icons.segment,
                        label: 'Segment',
                        isActive: _isSegmented,
                        onPressed: _toggleSegment,
                        activeColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Analyze button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _analyzeResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isProcessing
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Analyze Sample',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
    required Color activeColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? activeColor : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? activeColor : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : Colors.grey[700],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
