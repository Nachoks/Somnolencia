// reaccion_view_model.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Necesario para Colors y ChangeNotifier
import '../models/estimulo.dart'; // Importamos el Modelo

class ReaccionViewModel extends ChangeNotifier {
  // --- Variables de Control y Medición ---
  final Duration _duracionTest = const Duration(seconds: 15);
  Timer? _generadorTimer;
  Timer? _globalTimer;
  int _idEstimuloActual = 0;
  double _anchoMaximo = 0;
  double _altoMaximo = 0;

  // Datos observables (getters públicos)
  final List<Estimulo> _estimulosActivos = [];
  List<Estimulo> get estimulosActivos => _estimulosActivos;

  final List<int> _tiemposReaccionValidos = [];
  String _tiempoRestante = '15.0';
  String get tiempoRestante => _tiempoRestante;

  bool _estaCorriendo = false;
  bool get estaCorriendo => _estaCorriendo;

  int _targetsGenerados = 0;
  int get targetsGenerados => _targetsGenerados;

  int _targetsTocados = 0;
  int get targetsTocados => _targetsTocados;

  int _errores = 0;
  int get errores => _errores;

  // --- MÉTODOS PÚBLICOS ---

  void establecerTamanoPantalla(double width, double height) {
    _anchoMaximo = width;
    _altoMaximo = height;
  }

  void iniciarTest() {
    if (_estaCorriendo || _anchoMaximo == 0) return;

    // Reinicio
    _targetsGenerados = 0;
    _targetsTocados = 0;
    _errores = 0;
    _idEstimuloActual = 0;
    _tiemposReaccionValidos.clear();
    _estimulosActivos.clear();

    _estaCorriendo = true;
    notifyListeners();

    // 1. TEMPORIZADOR GLOBAL (Controla los 15 segundos)
    _globalTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final transcurrido = timer.tick * 100;
      final restante = _duracionTest.inMilliseconds - transcurrido;
      if (restante <= 0) {
        _detenerTest();
      } else {
        _tiempoRestante = (restante / 1000).toStringAsFixed(1);
        notifyListeners();
      }
    });

    // 2. TEMPORIZADOR DE GENERACIÓN (Crea un nuevo círculo)
    _generadorTimer = Timer.periodic(const Duration(milliseconds: 700), (
      timer,
    ) {
      if (!_estaCorriendo) return;

      _idEstimuloActual++;
      final nuevoEstimulo = Estimulo(
        _idEstimuloActual,
        _anchoMaximo,
        _altoMaximo,
      );

      if (nuevoEstimulo.esTarget) {
        _targetsGenerados++;
      }

      _estimulosActivos.add(nuevoEstimulo);
      notifyListeners();

      _programarEliminacion(nuevoEstimulo.id);
    });
  }

  void _programarEliminacion(int id) {
    // Si no se toca, desaparece después de 1500ms
    Timer(const Duration(milliseconds: 1500), () {
      if (_estaCorriendo) {
        final indice = _estimulosActivos.indexWhere((s) => s.id == id);

        if (indice != -1) {
          final estimuloRemovido = _estimulosActivos[indice];
          if (estimuloRemovido.esTarget) {
            _errores++; // Error: No reaccionó a tiempo
          }
          _estimulosActivos.removeAt(indice);
          notifyListeners();
        }
      }
    });
  }

  void manejarToqueEstimulo(int id) {
    if (!_estaCorriendo) return;

    final indice = _estimulosActivos.indexWhere((s) => s.id == id);
    if (indice == -1) return; // Ya fue tocado o removido

    final estimulo = _estimulosActivos[indice];
    final ahora = DateTime.now();
    final tiempoReaccion = ahora
        .difference(estimulo.tiempoInicio)
        .inMilliseconds;

    // Eliminar estímulo
    _estimulosActivos.removeAt(indice);

    if (estimulo.esTarget) {
      _targetsTocados++;
      _tiemposReaccionValidos.add(tiempoReaccion);
    } else {
      _errores++; // Error de Discriminación
    }
    notifyListeners();
  }

  void _detenerTest() {
    _estaCorriendo = false;
    _generadorTimer?.cancel();
    _globalTimer?.cancel();

    // Contar como errores los targets que quedaron activos sin tocar
    _errores += _estimulosActivos.where((s) => s.esTarget).length;
    _estimulosActivos.clear();

    notifyListeners();
  }

  // --- CÁLCULO DE RESULTADOS FINALES ---

  Map<String, dynamic> obtenerResultadosFinales() {
    double tiempoPromedio = 0.0;
    if (_tiemposReaccionValidos.isNotEmpty) {
      final tiempoTotal = _tiemposReaccionValidos.reduce((a, b) => a + b);
      tiempoPromedio = tiempoTotal / _tiemposReaccionValidos.length;
    }

    final double eficacia = (_targetsTocados / max(_targetsGenerados, 1)) * 100;

    return {
      'trp': tiempoPromedio.toStringAsFixed(0),
      'eficacia': eficacia.toStringAsFixed(1),
      'errores': _errores,
      'tocados': _targetsTocados,
      'generados': _targetsGenerados,
    };
  }

  @override
  void dispose() {
    _generadorTimer?.cancel();
    _globalTimer?.cancel();
    super.dispose();
  }
}
