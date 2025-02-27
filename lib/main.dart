import 'package:flutter/material.dart';

void main() {
  runApp(const MedicalSampleApp());
}

class MedicalSampleApp extends StatefulWidget {
  const MedicalSampleApp({Key? key}) : super(key: key);

  @override
  State<MedicalSampleApp> createState() => _MedicalSampleAppState();
}

class _MedicalSampleAppState extends State<MedicalSampleApp> {
  String _currentLanguage = 'EN';
  bool get _isEnglish => _currentLanguage == 'EN';

  void _changeLanguage(String? language) {
    if (language != null) {
      setState(() {
        _currentLanguage = language;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Sample Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: SampleTypePage(
        isEnglish: _isEnglish,
        currentLanguage: _currentLanguage,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

class SampleTypePage extends StatelessWidget {
  final bool isEnglish;
  final String currentLanguage;
  final Function(String?) onLanguageChanged;

  const SampleTypePage({
    Key? key,
    required this.isEnglish,
    required this.currentLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Text translations
    final String selectSampleTypeText =
        isEnglish ? 'Select Sample Type' : 'Hitamo Ubwoko bw\'Ibizamini';
    final String recentScansText =
        isEnglish ? 'Recent Scans' : 'Ibizamini Bishyashya';
    final String bloodText = isEnglish ? 'Blood' : 'Amaraso';
    final String urineText = isEnglish ? 'Urine' : 'Inkari';
    final String stoolText = isEnglish ? 'Stool' : 'Amabyi';
    final String sputumText = isEnglish ? 'Sputum' : 'Igororwa';
    final String offlineText = isEnglish ? 'Offline' : 'Nta murandasi';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.wifi_off, color: Colors.grey[600], size: 20),
          ],
        ),
        title: Text(
          offlineText,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: currentLanguage,
              icon: const Icon(Icons.language, color: Colors.grey),
              elevation: 16,
              underline: Container(height: 0),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              onChanged: onLanguageChanged,
              items:
                  <String>['EN', 'RW'].map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              value == currentLanguage
                                  ? Colors.grey[200]
                                  : Colors.transparent,
                        ),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectSampleTypeText,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2639),
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildSampleTypeCard(
                  title: bloodText,
                  icon: Icons.water_drop,
                  color: const Color(0xFFD9483B),
                ),
                _buildSampleTypeCard(
                  title: urineText,
                  icon: Icons.science,
                  color: const Color(0xFFE9C33F),
                ),
                _buildSampleTypeCard(
                  title: stoolText,
                  icon: Icons.science,
                  color: const Color(0xFF8B5A2B),
                ),
                _buildSampleTypeCard(
                  title: sputumText,
                  icon: Icons.air,
                  color: const Color(0xFF4169E1),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              recentScansText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2639),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRecentScanButton(
                  icon: Icons.water_drop,
                  color: Colors.red,
                ),
                const SizedBox(width: 16),
                _buildRecentScanButton(
                  icon: Icons.science,
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                _buildRecentScanButton(icon: Icons.air, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleTypeCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanButton({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: color, size: 30)),
    );
  }
}
