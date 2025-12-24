 import 'package:flutter/material.dart';

// ATUALIZAÇÃO DO MÉTODO _NAVITEM PARA RECEBER O ONTAP
Widget navItem(IconData icon, String label, bool active, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    ),
  );
}
