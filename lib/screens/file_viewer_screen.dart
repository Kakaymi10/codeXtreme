import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../services/supabase_config.dart';

class FileViewerScreen extends StatefulWidget {
  const FileViewerScreen({Key? key}) : super(key: key);

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Cache for segmented images
  static final Map<String, String> _segmentedImageCache = {};

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
  String? _segmentedImageUrl; // To store the segmented image URL

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
    } else {
      // Check if we already have a segmented version of this image
      _checkForCachedSegmentedImage();
    }
  }

  void _checkForCachedSegmentedImage() {
    if (_fileUrl != null && _segmentedImageCache.containsKey(_fileUrl)) {
      print('Using cached segmented image for: $_fileUrl');
      // We have a cached segmented image, but don't auto-toggle to it
      _segmentedImageUrl = _segmentedImageCache[_fileUrl];
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

    // If already segmented, toggle back to original image
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
      // Check if we have a cached version first
      if (_fileUrl != null && !_isVideo) {
        if (_segmentedImageCache.containsKey(_fileUrl)) {
          // Use cached version
          setState(() {
            _segmentedImageUrl = _segmentedImageCache[_fileUrl];
            _isSegmented = true;
            _isProcessing = false;
          });
          print('Using cached segmented image: $_segmentedImageUrl');
          return;
        }

        // If not cached, make API call
        final segmentedImage = await _segmentImageWithApi(_fileUrl!);

        if (segmentedImage != null) {
          // Cache the result
          _segmentedImageCache[_fileUrl!] = segmentedImage;

          setState(() {
            _segmentedImageUrl = segmentedImage;
            _isSegmented = true;
          });
        } else {
          throw Exception('Failed to segment image');
        }
      } else {
        throw Exception('No valid image URL to process');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Segmentation error: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String?> _segmentImageWithApi(String imageUrl) async {
    try {
      // Step 1: Download the image from the URL
      print('Downloading image from: $imageUrl');
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      print(
        'Successfully downloaded image: ${response.bodyBytes.length} bytes',
      );
      final imageBytes = response.bodyBytes;

      // Step 2: Create a multipart request to the segment API
      // When running on an emulator, 10.0.2.2 points to the host machine's localhost
      // For a physical device, use your computer's actual IP address on the network
      final apiUrl =
          kIsWeb
              ? 'http://localhost:8000/segment/auto'
              : 'http://10.0.2.2:8000/segment/auto';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: _fileName ?? 'image.jpg',
          ),
        );

      // Step 3: Send the request and get the response
      print('Sending request to API: ${request.url}');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw Exception('API request timed out after 120 seconds');
        },
      );
      print(
        'Received API response with status: ${streamedResponse.statusCode}',
      );

      final apiResponse = await http.Response.fromStream(streamedResponse);

      if (apiResponse.statusCode != 200) {
        print('API error response: ${apiResponse.body}');
        throw Exception('API returned status code ${apiResponse.statusCode}');
      }

      print(
        'Successfully received segmented image: ${apiResponse.bodyBytes.length} bytes',
      );

      // Step 4: Save the segmented image to a persistent directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'segmented_${_patientId ?? ''}_${_fileName ?? DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${appDir.path}/$fileName';
      final tempFile = File(filePath);
      await tempFile.writeAsBytes(apiResponse.bodyBytes);

      print('Saved segmented image to: $filePath');
      return filePath;
    } catch (e) {
      print('Error in segmentation: $e');
      return null;
    }
  }

  void _analyzeResults() {
    // Determine which file URL to use
    String? fileToAnalyze = _fileUrl;

    if (_isSegmented && _segmentedImageUrl != null) {
      // If we have a segmented image, use that for analysis
      fileToAnalyze =
          _segmentedImageUrl!.startsWith('http')
              ? _segmentedImageUrl
              : _segmentedImageUrl;
      print('Using segmented image for analysis: $fileToAnalyze');
    }

    // Navigate to the analysis screen
    Navigator.pushNamed(
      context,
      '/analysis',
      arguments: {
        'fileUrl': fileToAnalyze,
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
      // For images - show segmented image if available
      if (_isSegmented && _segmentedImageUrl != null) {
        if (_segmentedImageUrl!.startsWith('http')) {
          return CachedNetworkImage(
            imageUrl: _segmentedImageUrl!,
            placeholder:
                (context, url) =>
                    const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
          );
        } else {
          // For local file path
          return Image.file(File(_segmentedImageUrl!), fit: BoxFit.contain);
        }
      } else if (_fileUrl != null) {
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
                  if (_segmentedImageCache.containsKey(_fileUrl) &&
                      !_isSegmented)
                    Tooltip(
                      message: 'Segmented version available',
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 16,
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
                        label:
                            _segmentedImageCache.containsKey(_fileUrl) &&
                                    !_isSegmented
                                ? 'Show Segmented'
                                : 'Segment',
                        isActive: _isSegmented,
                        onPressed: _isVideo ? null : _toggleSegment,
                        activeColor: Colors.purple,
                        hasCache:
                            _segmentedImageCache.containsKey(_fileUrl) &&
                            !_isSegmented,
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
    required VoidCallback? onPressed,
    required Color activeColor,
    bool hasCache = false,
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
              color:
                  isActive
                      ? activeColor
                      : hasCache
                      ? Colors.green
                      : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasCache ? Icons.cached : icon,
                size: 18,
                color:
                    isActive
                        ? activeColor
                        : hasCache
                        ? Colors.green
                        : onPressed == null
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isActive
                          ? activeColor
                          : hasCache
                          ? Colors.green
                          : onPressed == null
                          ? Colors.grey[400]
                          : Colors.grey[700],
                  fontWeight:
                      isActive || hasCache
                          ? FontWeight.w600
                          : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
