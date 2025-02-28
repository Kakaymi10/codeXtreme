import 'package:flutter/material.dart';
import '../models/sample_type.dart';

class SampleTypeButton extends StatelessWidget {
  final SampleType sampleType;
  final VoidCallback onTap;

  const SampleTypeButton({
    Key? key,
    required this.sampleType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: sampleType.color,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 34),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                sampleType.icon,
                color: Colors.white,
                size: 30,
                semanticLabel: '${sampleType.name} icon',
              ),
              const SizedBox(height: 12),
              Text(
                sampleType.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
                semanticsLabel: sampleType.name,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
