import 'package:flutter/material.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Film')),
      body: const Center(child: Text('Layar Movie List')),
    );
  }
}