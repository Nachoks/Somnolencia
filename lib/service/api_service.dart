import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IMPORTANTE: Cambia esta URL según tu configuración
  static const String baseUrl = 'http://192.168.0.25:8090/api';

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String nombreUsuario,
    String password,
  ) async {
    try {
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
        // Login exitoso - Guardar token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('usuario', jsonEncode(data['usuario']));

        return {
          'success': true,
          'message': data['message'],
          'usuario': data['usuario'],
        };
      } else {
        // Error 401 (credenciales incorrectas) o 403 (no es conductor)
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

      // Limpiar datos locales
      await prefs.remove('token');
      await prefs.remove('usuario');
    } catch (e) {
      // Limpiar datos locales aunque falle la petición
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  // VERIFICAR SI HAY SESIÓN ACTIVA
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // OBTENER USUARIO GUARDADO LOCALMENTE
  static Future<Map<String, dynamic>?> getUsuarioLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioStr = prefs.getString('usuario');
    if (usuarioStr != null) {
      return jsonDecode(usuarioStr);
    }
    return null;
  }
}
