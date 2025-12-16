import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Imports de tus archivos (Asegúrate de que las rutas sean correctas)
import 'package:somnolence_app/features/evaluacion_conductor/views/test_colores.dart';
import 'package:somnolence_app/features/evaluacion_conductor/viewsmodels/reaccion_view_model.dart';
import 'package:somnolence_app/pages/checklist.dart';
import 'package:somnolence_app/pages/encuesta_fatiga.dart';
import 'package:somnolence_app/pages/encuesta_somnolencia.dart';
import 'package:somnolence_app/widgets/logo_appbar.dart';

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

  // Estados de los tests
  bool _somnolenciaCompletada = false;
  bool _fatigaCompletada = false;
  bool _reaccionCompletada = false;
  bool _checklistCompletado = false;

  // --- GETTERS (Lógica computada) ---
  bool get _todosTestsCompletados =>
      _somnolenciaCompletada &&
      _fatigaCompletada &&
      _reaccionCompletada &&
      _checklistCompletado;

  int get _testsCompletados {
    int count = 0;
    if (_somnolenciaCompletada) count++;
    if (_fatigaCompletada) count++;
    if (_reaccionCompletada) count++;
    if (_checklistCompletado) count++;
    return count;
  }

  // --- LÓGICA DE NEGOCIO (GPS) ---
  Future<void> _registrarInicioViaje() async {
    setState(() => _cargandoUbicacion = true);

    try {
      // 1. Verificar servicio
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) throw 'El GPS está desactivado.';

      // 2. Verificar permisos
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) throw 'Permisos denegados.';
      }
      if (permiso == LocationPermission.deniedForever) {
        throw 'Permisos denegados permanentemente.';
      }

      // 3. Obtener ubicación
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Obtener dirección legible (Geocoding)
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

      // 5. Actualizar estado y notificar
      if (!mounted) return;
      setState(() {
        _direccionGuardada = direccionTexto;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Viaje iniciado en: $direccionTexto'),
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

  //AppBar
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
          onPressed: () {
            // Lógica de logout
          },
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

  // Header con info del conductor
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
          Icon(Icons.dashboard_rounded, size: 48, color: _primaryColor),
          const SizedBox(height: 16),
          Text(
            '¡Buen día!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Juanito Perez',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '20.123.456-7',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aqui se realizaran los test necesarios antes de partir en ruta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          if (_direccionGuardada != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                "📍 Inicio: $_direccionGuardada",
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Sección de progreso de tests
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
                '$_testsCompletados/4',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _todosTestsCompletados ? Colors.green : _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _testsCompletados / 4,
            backgroundColor: Colors.grey.shade200,
            color: _todosTestsCompletados ? Colors.green : _primaryColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          if (!_todosTestsCompletados) ...[
            const SizedBox(height: 8),
            Text(
              'Completa todos los tests para iniciar el viaje',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  // Lista de tests
  Widget _buildTestsList() {
    return Column(
      children: [
        _buildTestButton(
          text: 'Test Somnolencia',
          isCompleted: _somnolenciaCompletada,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EncuestaSomnolencia(),
              ),
            );
            if (result == true) setState(() => _somnolenciaCompletada = true);
          },
        ),
        const SizedBox(height: 16),
        _buildTestButton(
          text: 'Test Fatiga',
          isCompleted: _fatigaCompletada,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EncuestaFatiga()),
            );
            if (result == true) setState(() => _fatigaCompletada = true);
          },
        ),
        const SizedBox(height: 16),
        _buildTestButton(
          text: 'Test Reaccion',
          isCompleted: _reaccionCompletada,
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
            if (result == true) setState(() => _reaccionCompletada = true);
          },
        ),
        const SizedBox(height: 16),
        _buildTestButton(
          text: 'Checklist de Ruta',
          isCompleted: _checklistCompletado,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChecklistPage()),
            );
            if (result == true) setState(() => _checklistCompletado = true);
          },
        ),
      ],
    );
  }

  // Botón individual de test
  Widget _buildTestButton({
    required String text,
    required bool isCompleted,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [Colors.green, Colors.green.shade700]
              : [_primaryColor, _secondaryColor],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? Colors.green : _primaryColor).withOpacity(
              0.4,
            ),
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
            Icon(
              isCompleted ? Icons.check_circle : Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isCompleted ? '$text ✓' : text,
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

  // Botón principal de acción
  Widget _buildMainActionButton() {
    return Opacity(
      opacity: _todosTestsCompletados ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _todosTestsCompletados
                ? [_primaryColor, _secondaryColor]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: _todosTestsCompletados
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
          onPressed: _todosTestsCompletados && !_cargandoUbicacion
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
                      _todosTestsCompletados
                          ? Icons.location_on
                          : Icons.lock_outline,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _todosTestsCompletados
                          ? 'Registrar Inicio del Viaje'
                          : 'Completa los tests primero',
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
