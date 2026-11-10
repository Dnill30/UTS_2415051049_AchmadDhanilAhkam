import 'package:flutter/material.dart';
import '../widgets/screen_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ScreenPlaceholder(title: 'Home', icon: Icons.home_outlined);
}