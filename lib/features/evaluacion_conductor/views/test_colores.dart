import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewsmodels/reaccion_view_model.dart';

class TestColoresPage extends StatelessWidget {
  const TestColoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double margenLateral = 20.0; // Espacio a los lados
        const double margenSuperior = 160.0; // Espacio para el Panel de arriba
        const double margenInferior = 100.0;
        final viewModel = context.read<ReaccionViewModel>();
        viewModel.establecerTamanoPantalla(
          constraints.maxWidth - (margenLateral * 2),
          constraints.maxHeight - margenSuperior - margenInferior,
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
                      left: estimulo.x + margenLateral,
                      top: estimulo.y + margenSuperior,
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
                    Positioned(
                      // Usamos Positioned para asegurar que quede abajo o centrado sin molestar
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: vm.targetsTocados > 0
                            ? _buildBotonResultados(context, vm)
                            : _buildBotonIniciar(vm),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  //Panel de control superior
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Boton iniciar Test
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

  //Boton ver Resultados
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

  //Resultados Test
  void _mostrarResultados(BuildContext context, ReaccionViewModel vm) {
    final r = vm.obtenerResultadosFinales();

    // LEEMOS EL RESULTADO (Ahora sí existe, no dará error)
    final bool aprobado = r['aprobado'] ?? false;
    final String tiempo = r['trp'];
    final int umbral = r['umbral'] ?? 800;

    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a presionar el botón
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(
              aprobado ? Icons.check_circle : Icons.cancel,
              color: aprobado ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(aprobado ? 'TEST APROBADO' : 'TEST REPROBADO'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensaje de estado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: aprobado ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: aprobado ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Text(
                aprobado
                    ? 'Tus reflejos están dentro del rango seguro.'
                    : 'Tus reflejos son lentos. Por seguridad, descansa.',
                style: TextStyle(
                  color: aprobado ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detalles técnicos
            _filaDetalle('Tiempo Promedio:', '$tiempo ms'),
            _filaDetalle('Umbral Máximo:', '$umbral ms'), // Mostramos el límite
            _filaDetalle('Aciertos:', '${r['tocados']} de ${r['generados']}'),
            _filaDetalle('Errores:', '${r['errores']}'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: aprobado ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo

              // DEVUELVE EL BOOLEANO A LA PANTALLA ANTERIOR
              // Esto arregla que el HomePage sepa si pasó o no
              Navigator.of(context).pop(aprobado);
            },
            child: const Text('FINALIZAR'),
          ),
        ],
      ),
    );
  }

  // Helper para que se vea ordenado
  Widget _filaDetalle(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor),
        ],
      ),
    );
  }
}

//Circulos
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
