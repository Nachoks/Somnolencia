// test_colores_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/features/evaluacion_conductor/viewsmodels/reaccion_view_model.dart';
import '../models/estimulo.dart'; // Importa el Modelo

class TestColoresPage extends StatelessWidget {
  const TestColoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para que el ViewModel conozca el tamaño
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewModel = context.read<ReaccionViewModel>();
        // Le pasamos las dimensiones al ViewModel antes de usarlo
        viewModel.establecerTamanoPantalla(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Test de Reacción Selectiva')),
          body: Consumer<ReaccionViewModel>(
            builder: (context, vm, child) {
              return Stack(
                children: [
                  // 1. Área de Estímulos (Dibuja los círculos activos)
                  ...vm.estimulosActivos
                      .map(
                        (estimulo) => Positioned(
                          left: estimulo.x,
                          top: estimulo.y,
                          child: GestureDetector(
                            // Llama al método del ViewModel al tocar
                            onTap: () => vm.manejarToqueEstimulo(estimulo.id),
                            child: CirculoWidget(color: estimulo.color),
                          ),
                        ),
                      )
                      .toList(),

                  // 2. Panel de Control Superior
                  _construirPanelControl(vm),

                  // 3. Botón de Inicio (Solo visible si no está corriendo)
                  if (!vm.estaCorriendo)
                    Center(
                      child: vm.targetsTocados > 0
                          ? _construirBotonResultados(context, vm)
                          : _construirBotonIniciar(vm),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // --- Widgets Auxiliares de la Vista ---

  Widget _construirPanelControl(ReaccionViewModel vm) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.white.withOpacity(0.9),
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tiempo Restante: ${vm.tiempoRestante}s',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Aciertos: ${vm.targetsTocados} | Errores: ${vm.errores} | Targets: ${vm.targetsGenerados}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirBotonIniciar(ReaccionViewModel vm) {
    return ElevatedButton(
      onPressed: vm.iniciarTest,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.lightGreen,
      ),
      child: const Text(
        'Iniciar Test (15s)',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _construirBotonResultados(BuildContext context, ReaccionViewModel vm) {
    return ElevatedButton(
      onPressed: () => _mostrarResultadosFinales(context, vm),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.blue,
      ),
      child: const Text(
        'Ver Resultados del Último Test',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  void _mostrarResultadosFinales(BuildContext context, ReaccionViewModel vm) {
    final resultados = vm.obtenerResultadosFinales();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Evaluación Finalizada'),
        content: Text(
          '**1. Tiempo de Reacción Promedio (TRP)**:\n'
          '**${resultados['trp']} ms**\n\n'
          '**2. Tasa de Eficacia (TE)**:\n'
          '**${resultados['eficacia']}%** (${resultados['tocados']} / ${resultados['generados']} targets)\n\n'
          '**3. Errores Totales**:\n'
          '**${resultados['errores']}**',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}

// 4. 📄 lib/features/evaluacion_conductor/views/circulo_widget.dart (o integrado aquí)
class CirculoWidget extends StatelessWidget {
  final Color color;
  const CirculoWidget({required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
  }
}
