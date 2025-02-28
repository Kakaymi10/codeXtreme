import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SegmentationService {
  final String baseUrl =
      'http://127.0.0.1:8000/'; // Replace with your actual API URL

  // Method to segment an image automatically
  Future<String?> segmentImageAuto(String localPath, String patientId) async {
    try {
      print('Segmentation service called with path: $localPath');
      // Check if the file exists and is readable
      final file = File(localPath);
      if (!await file.exists()) {
        print('File does not exist at path: $localPath');
        throw Exception('File not found at the specified path');
      }

      print('File exists, size: ${await file.length()} bytes');
      final fileName = basename(file.path);

      // Create multipart request for the file
      final String apiUrl = '$baseUrl/segment/auto';
      print('Sending request to API: $apiUrl');

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send the request and await response
      print('Sending file to API...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('API response status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('API error response: ${response.body}');
        throw Exception(
          'Failed to segment image: ${response.statusCode} ${response.body}',
        );
      }

      // Save the segmented image locally
      final directory = await getApplicationDocumentsDirectory();
      final segmentedFileName = 'segmented_$fileName';
      final localSegmentedPath =
          '${directory.path}/patients/$patientId/segmented';

      // Create the directory structure if it doesn't exist
      final segmentedDir = Directory(localSegmentedPath);
      if (!await segmentedDir.exists()) {
        await segmentedDir.create(recursive: true);
      }

      final fullPath = '$localSegmentedPath/$segmentedFileName';
      print('Saving segmented image to: $fullPath');

      // Write the response body (image bytes) to a local file
      await File(fullPath).writeAsBytes(response.bodyBytes);

      // Return the local file path (instead of a URL)
      return fullPath;
    } catch (e) {
      print('Error in segmentation service: $e');
      return null;
    }
  }

  // Method to enhance an image
  Future<String?> enhanceImage(String localPath, String patientId) async {
    try {
      // Check if the file exists and is readable
      final file = File(localPath);
      if (!await file.exists()) {
        print('File does not exist at path: $localPath');
        throw Exception('File not found at the specified path');
      }

      print('File exists, size: ${await file.length()} bytes');
      final fileName = basename(file.path);

      // Create multipart request for the file
      final String apiUrl =
          '$baseUrl/enhance'; // Assume we have a separate enhance endpoint
      print('Sending request to API: $apiUrl');

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send the request and await response
      print('Sending file to API...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('API response status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('API error response: ${response.body}');
        throw Exception(
          'Failed to enhance image: ${response.statusCode} ${response.body}',
        );
      }

      // Save the enhanced image locally
      final directory = await getApplicationDocumentsDirectory();
      final enhancedFileName = 'enhanced_$fileName';
      final localEnhancedPath =
          '${directory.path}/patients/$patientId/enhanced';

      // Create the directory structure if it doesn't exist
      final enhancedDir = Directory(localEnhancedPath);
      if (!await enhancedDir.exists()) {
        await enhancedDir.create(recursive: true);
      }

      final fullPath = '$localEnhancedPath/$enhancedFileName';
      print('Saving enhanced image to: $fullPath');

      // Write the response body (image bytes) to a local file
      await File(fullPath).writeAsBytes(response.bodyBytes);

      // Return the local file path (instead of a URL)
      return fullPath;
    } catch (e) {
      print('Error in enhancement service: $e');
      return null;
    }
  }

  // Helper method to get file URI from path
  String getFileUri(String path) {
    return 'file://$path';
  }
}
