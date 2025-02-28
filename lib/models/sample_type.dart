import 'package:flutter/material.dart';

class SampleType {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  const SampleType({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  // Factory methods for predefined sample types
  factory SampleType.blood() {
    return const SampleType(
      id: 'blood',
      name: 'Blood',
      color: Color(0xFFDC2626), // Red
      icon: Icons.water_drop,
    );
  }

  factory SampleType.urine() {
    return const SampleType(
      id: 'urine',
      name: 'Urine',
      color: Color(0xFFEAB308), // Yellow
      icon: Icons.science,
    );
  }

  factory SampleType.stool() {
    return const SampleType(
      id: 'stool',
      name: 'Stool',
      color: Color(0xFF8B4513), // Brown
      icon: Icons.science,
    );
  }

  factory SampleType.sputum() {
    return const SampleType(
      id: 'sputum',
      name: 'Sputum',
      color: Color(0xFF2563EB), // Blue
      icon: Icons.air,
    );
  }
}
