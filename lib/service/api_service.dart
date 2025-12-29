import 'dart:convert';
import 'dart:async'; // Necesario para el Timeout
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. DEFINIMOS LAS DOS RUTAS POSIBLES
  static const String _urlLocal = 'http://192.168.0.25:8090/api';
  static const String _urlExterna = 'http://iaaspa.synology.me:8090/api';

  // 2. LA URL AHORA ES DINÁMICA (No es 'const')
  // Por defecto asumimos la externa (internet), si falla, probamos local.
  static String baseUrl = _urlExterna;

  // 3. FUNCIÓN INTELIGENTE DE CONEXIÓN
  // Esta función debe llamarse al iniciar la App
  static Future<void> inicializarConexion() async {
    print("📡 Probando conexión local con $_urlLocal...");
    try {
      // Intentamos contactar al servidor local.
      // Nota: No importa si da 404 o 401, lo que importa es que RESPONDA.
      await http
          .get(Uri.parse('$_urlLocal/ping'))
          .timeout(const Duration(seconds: 7));

      // Si llegamos aquí, es que el servidor respondió (estamos en la oficina)
      print("✅ CONEXIÓN LOCAL EXITOSA: Usando $_urlLocal");
      baseUrl = _urlLocal;
    } catch (e) {
      // Si da error de conexión o timeout, asumimos que estamos fuera
      print("🌍 CONEXIÓN LOCAL FALLIDA ($e). Usando Internet: $_urlExterna");
      baseUrl = _urlExterna;
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String nombreUsuario,
    String password,
  ) async {
    try {
      print("Intentando login en: $baseUrl/login"); // Debug para ver cual usa
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_usuario': nombreUsuario,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('usuario', jsonEncode(data['usuario']));

        return {
          'success': true,
          'message': data['message'],
          'usuario': data['usuario'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // OBTENER DATOS DEL USUARIO
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'usuario': data['usuario']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener datos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      await prefs.remove('token');
      await prefs.remove('usuario');
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  // VERIFICAR SESIÓN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // USUARIO LOCAL
  static Future<Map<String, dynamic>?> getUsuarioLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioStr = prefs.getString('usuario');
    if (usuarioStr != null) {
      return jsonDecode(usuarioStr);
    }
    return null;
  }

  // OBTENER PATENTES
  static Future<List<String>> obtenerPatentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/vehiculos/patentes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        print('Error al cargar patentes: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }
}
