import 'package:flutter/material.dart';

// 1. Modelo simple para los ítems del checklist
class CheckItem {
  String title;
  bool isChecked;

  CheckItem({required this.title, this.isChecked = false});
}

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  // 2. Lista de verificaciones
  final List<CheckItem> _items = [
    CheckItem(title: 'Licencia de connduccion vigente'),
    CheckItem(title: 'Cedula de identidad'),
    CheckItem(title: 'Permiso de Circulacion vigente'),
    CheckItem(title: 'Certificado de Revisión Técnica'),
    CheckItem(title: 'Buen estado de neumaticos'),
    CheckItem(title: 'Luces funcionando correctamente'),
    CheckItem(title: 'Sistema de visibilidad (limpiaparabrisas, espejos)'),
    CheckItem(title: 'Extintor y botiquin de primeros auxilios'),
    CheckItem(title: 'Chaleco reflectande y/o triangulos de seguridad'),
    CheckItem(title: 'Gato y llave de ruedas'),
  ];

  // 3. Getter para verificar si TODO está marcado
  bool get allChecked => _items.every((item) => item.isChecked);

  // Calcular el progreso (0.0 a 1.0)
  double get progress =>
      _items.where((item) => item.isChecked).length / _items.length;

  void _submitForm() {
    // Recopilamos el detalle para enviarlo
    List<Map<String, dynamic>> detalleChecklist = _items.map((item) {
      return {'item': item.title, 'marcado': item.isChecked};
    }).toList();

    // Muestra un SnackBar diferente según si está completo o incompleto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          allChecked
              ? '¡Verificación completa!'
              : 'Guardando con observaciones...',
        ),
        backgroundColor: allChecked ? Colors.green : Colors.orange,
      ),
    );

    // Navegación para volver a la pantalla anterior (POP) y DEVOLVER 'true'
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context, {
        'aprobado': allChecked, // Será true solo si marcó todo
        'detalles': detalleChecklist, // Lista con qué marcó y qué no
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Pre-Ruta'),
        backgroundColor: const Color(0xFFF35F34),
        foregroundColor: Colors.white,
      ),
      // Agregamos un fondo blanco general
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- BARRA DE PROGRESO (Sin cambios) ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Estado de verificación",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: allChecked ? Colors.green : Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: allChecked ? Colors.green : Colors.blueAccent,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                if (!allChecked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Nota: Los ítems no marcados se registrarán como pendientes.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- LISTA DE CHECKBOXES (Sin cambios) ---
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_items[index].title),
                  value: _items[index].isChecked,
                  activeColor: Colors.green,
                  onChanged: (bool? value) {
                    setState(() {
                      _items[index].isChecked = value ?? false;
                    });
                  },
                );
              },
            ),
          ),

          // --- BOTÓN DE CONTINUAR (AQUÍ ESTÁ EL CAMBIO) ---
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            // 1. Envolvemos el contenido del botón en SafeArea
            // Ponemos 'top: false' para que solo proteja la parte de abajo
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allChecked
                          ? const Color(0xFFF35F34)
                          : Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      allChecked
                          ? 'CONFIRMAR Y VOLVER'
                          : 'CONFIRMAR CON OBSERVACIONES',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
