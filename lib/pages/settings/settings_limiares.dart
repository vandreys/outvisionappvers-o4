import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';

class LimiaresPage extends StatelessWidget {
  const LimiaresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.limiares.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Container(height: 3, width: 48, color: Colors.black),
            const SizedBox(height: 28),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2F1%20-%20Da%20esquerda%20para%20a%20direita%20-%20Adriana%20Almada%2C%20Tereza%20de%20Arruda%20-%20Cortesia%20High%20Class%20e%20Tereza%20de%20Arruda.jpg?alt=media&token=115d9098-b940-46de-bb1e-a8803675d229',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 28),

            Text(
              t.limiares.conceptText,
              style: const TextStyle(
                fontSize: 15,
                height: 1.75,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            Text(
              t.limiares.statementTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              t.limiares.statementText,
              style: const TextStyle(
                fontSize: 15,
                height: 1.75,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            Container(height: 1, color: Colors.black26),
            const SizedBox(height: 20),

            Text(
              t.limiares.curatorsLabel.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.limiares.curatorsNames,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
