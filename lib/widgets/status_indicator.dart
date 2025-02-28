import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isOffline;

  const StatusIndicator({Key? key, required this.isOffline}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isOffline ? Icons.wifi_off : Icons.wifi,
          size: 16,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 8),
        Text(
          isOffline ? 'Offline' : 'Online',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
            height: 1,
          ),
          semanticsLabel: isOffline ? 'Offline status' : 'Online status',
        ),
      ],
    );
  }
}
