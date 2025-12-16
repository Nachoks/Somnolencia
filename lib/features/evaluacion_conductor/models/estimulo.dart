import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';

class Estimulo {
  final int id;
  final double x;
  final double y;
  final DateTime tiempoInicio;
  final Color color;
  final bool esTarget;

  // Constructor privado
  Estimulo._({
    required this.id,
    required this.tiempoInicio,
    required this.esTarget,
    required this.color,
    required this.x,
    required this.y,
  });

  // Método estático para crear estímulos (este es el que usa el ViewModel)
  static Estimulo crear(
    int currentId,
    double maxWidth,
    double maxHeight,
    List<Estimulo> estimulosExistentes,
  ) {
    final random = Random().nextDouble();
    final esObjetivo = random > 0.3; // 70% de probabilidad de ser target

    double newX, newY;
    int intentos = 0;
    const maxIntentos = 50;
    const distanciaMinima = 100.0; // Distancia mínima entre círculos

    // Intenta encontrar una posición que no se superponga
    do {
      newX = Random().nextDouble() * (maxWidth - 80);
      newY = 120 + Random().nextDouble() * (maxHeight - 300);
      intentos++;

      // Si no encuentra posición después de 50 intentos, acepta cualquier posición
      if (intentos >= maxIntentos) break;
    } while (_haySuperposicion(
      newX,
      newY,
      estimulosExistentes,
      distanciaMinima,
    ));

    return Estimulo._(
      id: currentId,
      tiempoInicio: DateTime.now(),
      esTarget: esObjetivo,
      color: esObjetivo ? Colors.red : Colors.blue,
      x: newX,
      y: newY,
    );
  }

  // Verifica si la nueva posición se superpone con círculos existentes
  static bool _haySuperposicion(
    double x,
    double y,
    List<Estimulo> existentes,
    double distanciaMinima,
  ) {
    for (var estimulo in existentes) {
      final dx = x - estimulo.x;
      final dy = y - estimulo.y;
      final distancia = sqrt(dx * dx + dy * dy);

      if (distancia < distanciaMinima) {
        return true; // Hay superposición
      }
    }
    return false; // No hay superposición
  }
}
