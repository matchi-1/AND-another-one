import 'package:flutter/material.dart';

class LogicGuidePage extends StatelessWidget {
  const LogicGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logic Guide')),
      body: const Center(
        child: Text(
          'Logic Guide Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}