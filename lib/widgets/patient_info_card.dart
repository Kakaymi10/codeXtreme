import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientInfoCard extends StatelessWidget {
  const PatientInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Patient Information',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            semanticsLabel: 'Patient Information section',
          ),
          const SizedBox(height: 16),

          // Patient Details
          _buildDetailRow(label: 'Patient ID', value: 'P-2025-0123'),
          const SizedBox(height: 12),
          _buildDetailRow(label: 'Scan Date', value: 'Feb 15, 2025'),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
          semanticsLabel: '$label: $value',
        ),
      ],
    );
  }
}
