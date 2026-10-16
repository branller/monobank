import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const MonoBankApp());
}

class MonoBankApp extends StatelessWidget {
  const MonoBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonoBank',
      debugShowCheckedModeBanner: false,
      theme: MonoBankTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
