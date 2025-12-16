import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewsmodels/reaccion_view_model.dart';

class TestColoresPage extends StatelessWidget {
  const TestColoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewModel = context.read<ReaccionViewModel>();
        viewModel.establecerTamanoPantalla(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Test de Reacción Selectiva'),
            backgroundColor: const Color(0xFFF35F34),
            foregroundColor: Colors.white,
          ),
          body: Consumer<ReaccionViewModel>(
            builder: (context, vm, child) {
              return Stack(
                children: [
                  // Área de estímulos
                  ...vm.estimulosActivos.map(
                    (estimulo) => Positioned(
                      left: estimulo.x,
                      top: estimulo.y,
                      child: GestureDetector(
                        onTap: () => vm.manejarToqueEstimulo(estimulo.id),
                        child: _CirculoWidget(color: estimulo.color),
                      ),
                    ),
                  ),

                  // Panel de control
                  _buildPanelControl(vm),

                  // Botón de inicio/resultados
                  if (!vm.estaCorriendo)
                    Center(
                      child: vm.targetsTocados > 0
                          ? _buildBotonResultados(context, vm)
                          : _buildBotonIniciar(vm),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPanelControl(ReaccionViewModel vm) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tiempo: ${vm.tiempoRestante}s',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Aciertos: ${vm.targetsTocados}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Errores: ${vm.errores}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Targets: ${vm.targetsGenerados}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca solo los círculos ROJOS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonIniciar(ReaccionViewModel vm) {
    return ElevatedButton(
      onPressed: vm.iniciarTest,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: const Color(0xFFF35F34),
      ),
      child: const Text(
        'Iniciar Test (15s)',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBotonResultados(BuildContext context, ReaccionViewModel vm) {
    return ElevatedButton(
      onPressed: () => _mostrarResultados(context, vm),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: Colors.blue,
      ),
      child: const Text(
        'Ver Resultados',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _mostrarResultados(BuildContext context, ReaccionViewModel vm) {
    final r = vm.obtenerResultadosFinales();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Evaluación Finalizada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiempo de Reacción Promedio:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${r['trp']} ms', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            const Text(
              'Tasa de Eficacia:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${r['eficacia']}% (${r['tocados']} / ${r['generados']} targets)',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Errores Totales:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${r['errores']}', style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _CirculoWidget extends StatelessWidget {
  final Color color;
  const _CirculoWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
