import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTabBar extends StatelessWidget {
  final int selectedIndex;
  final List<String> tabs;
  final Function(int) onTabSelected;

  const CustomTabBar({
    Key? key,
    required this.selectedIndex,
    required this.tabs,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: InkWell(
              onTap: () => onTabSelected(index),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border:
                      selectedIndex == index
                          ? const Border(
                            bottom: BorderSide(
                              color: Color(0xFF2563EB),
                              width: 2,
                            ),
                          )
                          : null,
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight:
                          selectedIndex == index
                              ? FontWeight.w600
                              : FontWeight.w400,
                      color:
                          selectedIndex == index
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
