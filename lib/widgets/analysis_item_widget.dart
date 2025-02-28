import 'package:flutter/material.dart';
import '../models/analysis_item.dart';

class AnalysisItemWidget extends StatelessWidget {
  final AnalysisItem item;

  const AnalysisItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.name,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color:
                  item.isActive
                      ? const Color(0xFF374151)
                      : const Color(0xFF6B7280),
            ),
            semanticsLabel:
                '${item.name} ${item.isActive ? 'active' : 'pending'}',
          ),
        ],
      ),
    );
  }
}
