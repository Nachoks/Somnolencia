// estimulo.dart

import 'dart:ui'; // Para Color
import 'dart:math';

import 'package:flutter/material.dart';

class Estimulo {
  final int id;
  final double x;
  final double y;
  final DateTime tiempoInicio; // Renombrado a español
  final Color color;
  final bool esTarget; // Si es 'Target' (Verde), es válido para tocar.

  Estimulo(int currentId, double maxWidth, double maxHeight)
    : id = currentId,
      tiempoInicio = DateTime.now(),
      // Posición aleatoria, ajustada para que el círculo no se salga
      x = Random().nextDouble() * (maxWidth - 50),
      y = Random().nextDouble() * (maxHeight - 50),
      // Lógica de Discriminación: 70% de probabilidad de ser Target (Verde)
      esTarget = Random().nextDouble() > 0.3,
      color = Random().nextDouble() > 0.3 ? Colors.green : Colors.red;
}
