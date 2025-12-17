import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Imports de tus archivos
import 'package:somnolence_app/features/evaluacion_conductor/views/test_colores.dart';
import 'package:somnolence_app/features/evaluacion_conductor/viewsmodels/reaccion_view_model.dart';
import 'package:somnolence_app/pages/checklist.dart';
import 'package:somnolence_app/pages/encuesta_fatiga.dart';
import 'package:somnolence_app/pages/encuesta_somnolencia.dart';
import 'package:somnolence_app/widgets/logo_appbar.dart';

// 1. Definimos el Enum para el tipo de auto
enum TipoAuto { empresa, arrendado }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- CONSTANTES DE ESTILO ---
  final Color _primaryColor = const Color(0xFFF35F34);
  final Color _secondaryColor = const Color.fromARGB(255, 185, 120, 104);

  // --- ESTADO ---
  bool _cargandoUbicacion = false;
  String? _direccionGuardada;

  // Estado de los Tests
  bool? _somnolenciaAprobada;
  bool? _fatigaAprobada;
  bool? _reaccionAprobada;
  bool? _checklistAprobado;

  // 2. NUEVO ESTADO: Selección de Vehículo y Descripción
  TipoAuto? _tipoAutoSeleccionado;
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  // --- GETTERS (Lógica computada) ---

  bool get _todosTestsRealizados =>
      _somnolenciaAprobada != null &&
      _fatigaAprobada != null &&
      _reaccionAprobada != null &&
      _checklistAprobado != null;

  // 3. NUEVA VALIDACIÓN: ¿Está todo listo para viajar?
  // Requiere: Tests hechos Y vehículo seleccionado
  bool get _puedeIniciarViaje =>
      _todosTestsRealizados && _tipoAutoSeleccionado != null;

  int get _testsRealizadosCount {
    int count = 0;
    if (_somnolenciaAprobada != null) count++;
    if (_fatigaAprobada != null) count++;
    if (_reaccionAprobada != null) count++;
    if (_checklistAprobado != null) count++;
    return count;
  }

  // --- LÓGICA DE NEGOCIO (GPS y Registro) ---
  // --- LÓGICA DE NEGOCIO (GPS y Registro) ---
  Future<void> _registrarInicioViaje() async {
    // 1. Validaciones: Tests aprobados
    bool hayReprobados = [
      _somnolenciaAprobada,
      _fatigaAprobada,
      _reaccionAprobada,
      _checklistAprobado,
    ].contains(false);

    if (hayReprobados) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '⚠️ Advertencia: Hay tests con resultado negativo.',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    }

    // 2. Validación: Vehículo seleccionado
    if (_tipoAutoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Debes seleccionar un tipo de vehículo'),
        ),
      );
      return;
    }

    setState(() => _cargandoUbicacion = true);

    try {
      // -----------------------------------------------------------
      // PASO 1: CAPTURAR LA HORA EXACTA (Fecha y Hora)
      // -----------------------------------------------------------
      final DateTime ahora = DateTime.now();

      // Formato simple para mostrar al usuario (Ej: 14:30)
      String horaFormateada =
          "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";

      // -----------------------------------------------------------
      // PASO 2: OBTENER UBICACIÓN GPS
      // -----------------------------------------------------------
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) throw 'El GPS está desactivado.';

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) throw 'Permisos denegados.';
      }
      if (permiso == LocationPermission.deniedForever) {
        throw 'Permisos denegados permanentemente.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String direccionTexto = "Ubicación desconocida";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        direccionTexto =
            "${place.thoroughfare} ${place.subThoroughfare}, ${place.locality}";
      }

      if (!mounted) return;
      setState(() {
        _direccionGuardada = direccionTexto;
      });

      // -----------------------------------------------------------
      // PASO 3: CONSOLIDAR DATOS (Aquí tienes todo listo para enviar)
      // -----------------------------------------------------------
      final datosFinales = {
        'fecha_hora': ahora.toIso8601String(), // Formato ISO para base de datos
        'vehiculo': _tipoAutoSeleccionado!.name,
        'descripcion': _descripcionController.text,
        'ubicacion': {
          'lat': position.latitude,
          'lng': position.longitude,
          'direccion': direccionTexto,
        },
      };

      print("✅ ENVIANDO DATOS: $datosFinales");

      // -----------------------------------------------------------
      // PASO 4: FEEDBACK VISUAL CON LA HORA
      // -----------------------------------------------------------
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Mostramos la hora en el mensaje
          content: Text(
            '✅ Viaje iniciado a las $horaFormateada en: $direccionTexto',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _cargandoUbicacion = false);
      }
    }
  }

  // --- BUILD PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 24),
                  _buildProgressSection(),
                  const SizedBox(height: 24),
                  _buildTestsList(),
                  const SizedBox(height: 32),
                  _buildMainActionButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: const LogoAppbar(),
      title: const Text(
        'Arenas & Arenas',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () {},
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _secondaryColor],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Info Usuario
          Icon(Icons.account_circle, size: 48, color: _primaryColor),
          const SizedBox(height: 10),
          const Text(
            'Juanito Perez',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Text(
            '20.123.456-7',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Divider(height: 30),

          // 4. AQUÍ ESTABA EL TEXTO ANTERIOR, AHORA ESTÁ EL FORMULARIO
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Seleccione tipo de vehículo:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Opciones de Vehículo (Row para que queden lado a lado o Column si prefieres)
          Row(
            children: [
              Expanded(
                child: _buildVehicleOptionCard(
                  label: 'Empresa',
                  icon: Icons.business_rounded,
                  value: TipoAuto.empresa,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVehicleOptionCard(
                  label: 'Arrendado',
                  icon: Icons.car_rental,
                  value: TipoAuto.arrendado,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Campo descripción
          TextField(
            controller: _descripcionController,
            maxLines: 2,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Descripción / Patente (Opcional)',
              hintText: 'Ej: Camioneta roja...',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          if (_direccionGuardada != null) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                "📍 Inicio: $_direccionGuardada",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 5. WIDGET AUXILIAR PARA LAS TARJETAS DE SELECCIÓN DE AUTO
  Widget _buildVehicleOptionCard({
    required String label,
    required IconData icon,
    required TipoAuto value,
  }) {
    final bool isSelected = _tipoAutoSeleccionado == value;
    final color = isSelected ? _primaryColor : Colors.grey.shade400;
    final bgColor = isSelected ? _primaryColor.withOpacity(0.1) : Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoAutoSeleccionado = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _primaryColor : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de Tests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '$_testsRealizadosCount/4',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _todosTestsRealizados ? Colors.green : _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _testsRealizadosCount / 4,
            backgroundColor: Colors.grey.shade200,
            color: _todosTestsRealizados ? Colors.green : _primaryColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTestsList() {
    return Column(
      children: [
        // Test Somnolencia
        _buildTestButton(
          text: 'Test Somnolencia',
          status: _somnolenciaAprobada,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EncuestaSomnolencia(),
              ),
            );
            if (result is bool) {
              setState(() => _somnolenciaAprobada = result);
            }
          },
        ),
        const SizedBox(height: 16),
        // Test Fatiga
        _buildTestButton(
          text: 'Test Fatiga',
          status: _fatigaAprobada,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EncuestaFatiga()),
            );
            if (result is bool) {
              setState(() => _fatigaAprobada = result);
            }
          },
        ),
        const SizedBox(height: 16),
        // Test Reacción
        _buildTestButton(
          text: 'Test Reaccion',
          status: _reaccionAprobada,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (_) => ReaccionViewModel(),
                  child: const TestColoresPage(),
                ),
              ),
            );
            if (result is bool) {
              setState(() => _reaccionAprobada = result);
            }
          },
        ),
        const SizedBox(height: 16),
        // Checklist
        _buildTestButton(
          text: 'Checklist de Ruta',
          status: _checklistAprobado,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChecklistPage()),
            );
            if (result is bool) {
              setState(() => _checklistAprobado = result);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTestButton({
    required String text,
    required bool? status,
    required VoidCallback onPressed,
  }) {
    Color bgColor;
    Color shadowColor;
    IconData icon;
    String finalText = text;

    if (status == null) {
      bgColor = _primaryColor;
      shadowColor = _primaryColor;
      icon = Icons.arrow_forward_rounded;
    } else if (status == true) {
      bgColor = Colors.green;
      shadowColor = Colors.green;
      icon = Icons.check_circle;
      finalText = '$text ✓';
    } else {
      bgColor = Colors.red;
      shadowColor = Colors.red;
      icon = Icons.cancel;
      finalText = '$text ✕';
    }

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: status == null
            ? LinearGradient(colors: [_primaryColor, _secondaryColor])
            : null,
        color: status != null ? bgColor : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              finalText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. ACTUALIZACIÓN DEL BOTÓN PRINCIPAL
  Widget _buildMainActionButton() {
    // AHORA DEPENDE DE: Tests Completos Y Selección de Vehículo
    bool habilitado = _puedeIniciarViaje;

    return Opacity(
      opacity: habilitado ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: habilitado
                ? [_primaryColor, _secondaryColor]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: habilitado
              ? [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: habilitado && !_cargandoUbicacion
              ? _registrarInicioViaje
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: _cargandoUbicacion
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      habilitado ? Icons.location_on : Icons.lock_outline,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      habilitado
                          ? 'Registrar Inicio del Viaje'
                          : (_tipoAutoSeleccionado == null
                                ? 'Seleccione vehículo'
                                : 'Completa los tests primero'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
