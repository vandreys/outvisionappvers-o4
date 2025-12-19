import 'package:flutter/material.dart';
import 'package:outvisionxr/widgets/maple_sample.dart'; // Certifique-se de que o path está correto

void main() {
  runApp(const OutvisionApp());
}

class OutvisionApp extends StatelessWidget {
  const OutvisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OutVision AR - Bienal Curitiba',
      home: const MapSample(),
      theme: ThemeData(
        primarySwatch: Colors.pink, // Cor tema para consistência com markers
        useMaterial3: true,
      ),
    );
  }
}