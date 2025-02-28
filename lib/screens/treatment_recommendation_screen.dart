import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/pathogen_card.dart' as pathogen;
import '../widgets/treatment_card.dart' as treatment;
import '../widgets/patient_info_card.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/app_footer.dart';

class TreatmentRecommendationScreen extends StatefulWidget {
  const TreatmentRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<TreatmentRecommendationScreen> createState() =>
      _TreatmentRecommendationScreenState();
}

class _TreatmentRecommendationScreenState
    extends State<TreatmentRecommendationScreen> {
  int _selectedTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF9FAFB),
          child: Column(
            children: [
              // Header
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF4B5563),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Go back',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    // Title
                    Text(
                      'Treatment Information',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      semanticsLabel: 'Treatment Information page',
                    ),
                    // Share button
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Color(0xFF4B5563),
                        size: 20,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share functionality coming soon'),
                          ),
                        );
                      },
                      tooltip: 'Share information',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              CustomTabBar(
                selectedIndex: _selectedTabIndex,
                onTabSelected: _onTabSelected,
                tabs: const ['Treatment', 'Education'],
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      pathogen.PathogenCard(),
                      const SizedBox(height: 16),
                      treatment.TreatmentCard(),
                      const SizedBox(height: 16),
                      const PatientInfoCard(),
                    ],
                  ),
                ),
              ),

              // Footer
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
