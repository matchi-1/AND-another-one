import 'package:flutter/material.dart';

class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Mode')),
      body: const Center(
        child: Text(
          'Mode Select Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}