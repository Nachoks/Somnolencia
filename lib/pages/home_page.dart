import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Paquetes de ubicación
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Tus imports existentes
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
  // Variables para controlar la ubicación
  bool _cargandoUbicacion = false;
  String? _direccionGuardada;

  // FUNCIÓN: Lógica para obtener ubicación
  Future<void> _registrarInicioViaje() async {
    setState(() => _cargandoUbicacion = true);

    try {
      // 1. Verificar permisos
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) throw 'El GPS está desactivado.';

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) throw 'Permisos denegados.';
      }
      if (permiso == LocationPermission.deniedForever)
        throw 'Permisos denegados permanentemente.';

      // 2. Obtener Coordenadas
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Obtener Dirección (Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String direccionTexto = "Ubicación desconocida";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Formato: Calle 123, Ciudad
        direccionTexto =
            "${place.thoroughfare} ${place.subThoroughfare}, ${place.locality}";
      }

      // 4. Guardar/Mostrar resultado
      setState(() {
        _direccionGuardada = direccionTexto;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viaje iniciado en: $direccionTexto'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        // AQUÍ PODRÍAS GUARDAR EN BASE DE DATOS O NAVEGAR
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargandoUbicacion = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LogoAppbar(),
        title: const Text(
          'Arenas & Arenas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF35F34),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF35F34), Color.fromARGB(255, 185, 120, 104)],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
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
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: SingleChildScrollView(
              // Agregado por si la pantalla es chica
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Texto de bienvenida
                  Container(
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
                        const Icon(
                          Icons.dashboard_rounded,
                          size: 48,
                          color: Color(0xFFF35F34),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '¡Buen día!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF35F34),
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

                        // OPCIONAL: Mostrar la dirección si ya se obtuvo
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
                  ),

                  const SizedBox(height: 48),

                  // TEST SOMNOLENCIA
                  _buildMenuButton(
                    text: 'Test Somnolencia',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EncuestaSomnolencia(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // TEST FATIGA
                  _buildMenuButton(
                    text: 'Test Fatiga',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EncuestaFatiga(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // TEST DE REACCION
                  _buildMenuButton(
                    text: 'Test Reaccion',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => ReaccionViewModel(),
                            child: const TestColoresPage(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // CHECKLIST
                  _buildMenuButton(
                    text: 'Checklist de Ruta',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChecklistPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // --- BOTÓN INICIO VIAJE (CON GEOLOCALIZACIÓN) ---
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF35F34),
                          Color.fromARGB(255, 185, 120, 104),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF35F34).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      // Si está cargando, deshabilitamos el click (null)
                      onPressed: _cargandoUbicacion
                          ? null
                          : _registrarInicioViaje,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                ), // Cambié el icono
                                SizedBox(width: 8),
                                Text(
                                  'Registrar Inicio del Viaje',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper para no repetir tanto código en los botones normales
  Widget _buildMenuButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF35F34), Color.fromARGB(255, 185, 120, 104)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF35F34).withOpacity(0.4),
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
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
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
}
