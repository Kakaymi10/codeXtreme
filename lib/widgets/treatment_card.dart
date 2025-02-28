import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TreatmentCard extends StatelessWidget {
  const TreatmentCard({Key? key}) : super(key: key);

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
            'Recommended Treatment',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            semanticsLabel: 'Recommended Treatment section',
          ),
          const SizedBox(height: 16),

          // Treatment Items
          _buildTreatmentItem(
            icon:
                '''<svg width="18" height="16" viewBox="0 0 18 16" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M0 0H18V16H0V0Z" stroke="#E5E7EB"></path>
              <path d="M3.5 3C2.67188 3 2 3.67188 2 4.5V8H5V4.5C5 3.67188 4.32812 3 3.5 3ZM0 4.5C0 2.56562 1.56562 1 3.5 1C5.43437 1 7 2.56562 7 4.5V11.5C7 13.4344 5.43437 15 3.5 15C1.56562 15 0 13.4344 0 11.5V4.5ZM17.3406 12.4812C17.1188 12.8656 16.6 12.8906 16.2844 12.5781L10.4219 6.71562C10.1094 6.40312 10.1313 5.88125 10.5188 5.65938C11.25 5.24063 12.0969 5 13 5C15.7625 5 18 7.2375 18 10C18 10.9031 17.7594 11.75 17.3406 12.4812ZM15.4812 14.3406C14.75 14.7594 13.9031 15 13 15C10.2375 15 8 12.7625 8 10C8 9.09688 8.24063 8.25 8.65938 7.51875C8.88125 7.13438 9.4 7.10938 9.71562 7.42188L15.5781 13.2844C15.8906 13.5969 15.8687 14.1187 15.4812 14.3406Z" fill="#2563EB"></path>
            </svg>''',
            name: 'Amoxicillin',
            description: '500mg, 3 times daily for 10 days',
          ),
          const SizedBox(height: 16),
          _buildTreatmentItem(
            icon:
                '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
              <g clip-path="url(#clip0_1_320)">
                <path d="M8 0C10.1217 0 12.1566 0.842855 13.6569 2.34315C15.1571 3.84344 16 5.87827 16 8C16 10.1217 15.1571 12.1566 13.6569 13.6569C12.1566 15.1571 10.1217 16 8 16C5.87827 16 3.84344 15.1571 2.34315 13.6569C0.842855 12.1566 0 10.1217 0 8C0 5.87827 0.842855 3.84344 2.34315 2.34315C3.84344 0.842855 5.87827 0 8 0ZM7.25 3.75V8C7.25 8.25 7.375 8.48438 7.58437 8.625L10.5844 10.625C10.9281 10.8562 11.3938 10.7625 11.625 10.4156C11.8562 10.0687 11.7625 9.60625 11.4156 9.375L8.75 7.6V3.75C8.75 3.33437 8.41562 3 8 3C7.58437 3 7.25 3.33437 7.25 3.75Z" fill="#2563EB"></path>
              </g>
              <defs>
                <clipPath id="clip0_1_320">
                  <path d="M0 0H16V16H0V0Z" fill="white"></path>
                </clipPath>
              </defs>
            </svg>''',
            name: 'Rest Period',
            description: 'Minimum 24 hours after starting antibiotics',
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentItem({
    required String icon,
    required String name,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Treatment Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: SvgPicture.string(icon, width: 18, height: 16)),
        ),
        const SizedBox(width: 12),
        // Treatment Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
                semanticsLabel: 'Treatment: $name',
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
