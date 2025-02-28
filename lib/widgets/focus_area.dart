import 'package:flutter/material.dart';

class FocusArea extends StatelessWidget {
  const FocusArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale down on smaller screens
        double scale = 1.0;
        if (MediaQuery.of(context).size.width < 640) {
          scale = 0.8;
        } else if (MediaQuery.of(context).size.width < 991) {
          scale = 0.9;
        }

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 288,
            height: 288,
            child: Stack(
              children: [
                // Outer border
                Container(
                  width: 288,
                  height: 288,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Inner border
                Center(
                  child: Container(
                    width: 256,
                    height: 256,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
