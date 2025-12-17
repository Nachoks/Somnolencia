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
    // Muestra un SnackBar de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Verificación completa! Volviendo...'),
        backgroundColor: Colors.green,
      ),
    );

    // Navegación para volver a la pantalla anterior (POP) y DEVOLVER 'true'
    Future.delayed(const Duration(milliseconds: 1000), () {
      // Devolvemos 'true' para indicar a HomePage que el checklist se completó.
      Navigator.pop(context, true);
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
      body: Column(
        children: [
          // --- BARRA DE PROGRESO ---
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
                      "Debes marcar todas las opciones para continuar.",
                      style: TextStyle(color: Colors.red[400], fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- LISTA DE CHECKBOXES ---
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_items[index].title),
                  value: _items[index].isChecked,
                  activeColor: Colors.green, // Color cuando está marcado
                  onChanged: (bool? value) {
                    setState(() {
                      _items[index].isChecked = value ?? false;
                    });
                  },
                );
              },
            ),
          ),

          // --- BOTÓN DE CONTINUAR ---
          Container(
            padding: const EdgeInsets.all(20),
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
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: allChecked ? _submitForm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF35F34),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey[300], // Color cuando está bloqueado
                  disabledForegroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: allChecked ? 4 : 0,
                ),
                child: Text(
                  allChecked ? 'CONFIRMAR Y VOLVER' : 'PENDIENTE',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
