import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final int colorIndex;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.name,
    required this.colorIndex,
    this.radius = 48,
  });

  static const colors = <Color>[
    Color(0xFFFF7A1A),
    Color(0xFF3F8CFF),
    Color(0xFF2EBD85),
    Color(0xFFB45CFF),
    Color(0xFFFF4D6D),
    Color(0xFFFFC233),
  ];

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = colors[colorIndex.clamp(0, colors.length - 1)];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}