<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends Controller
{
    // LOGIN
    public function login(Request $request)
    {
        // Validar
        $request->validate([
            'nombre_usuario' => 'required|string',
            'password' => 'required|string',
        ]);

        // Buscar Usuario
        $user = User::where('nombre_usuario', $request->nombre_usuario)->first();

        // Verificar Password
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Credenciales incorrectas'
            ], 401);
        }
        // Verificar Estado
        if (!$user->estado) {
            return response()->json([
                'message' => 'Su cuenta está deshabilitada. Contacte al administrador.'
            ], 403); // Retornamos 403 (Prohibido) en lugar de 401
        }

        // CARGAR RELACIONES (LA CLAVE DE TODO)
        // Esto le pega al objeto User los datos de personal, empresa y roles
        $user->load(['personal.empresa', 'roles']);

        // Crear Token
        $token = $user->createToken('movil')->plainTextToken;

        // RESPONDER
        // NOTA: No construimos el array 'usuario' a mano. 
        // Pasamos el objeto $user directo. Laravel serializará automáticamente:
        // user -> personal (con nombre_completo append) -> empresa
        return response()->json([
            'message' => 'Login exitoso',    
            'access_token' => $token,
            'token_type' => 'Bearer',
            'usuario' => $user, 
        ], 200);
    }

    // LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Sesión cerrada exitosamente'
        ], 200);
    }

    // ME (Perfil)
    public function me(Request $request)
    {
        $user = $request->user();
        
        // Aseguramos cargar toda la cadena de datos
        $user->load(['personal.empresa', 'roles']);

        return response()->json([
            'usuario' => $user // Enviamos el objeto completo estructura original
        ], 200);
    }

    // CAMBIAR CONTRASEÑA
    public function changePassword(Request $request)
    {
        // 1. Validar los datos que llegan
        $request->validate([
            'current_password' => 'required',
            'new_password' => 'required|string|min:6|confirmed', 
            // 'confirmed' busca automáticamente un campo 'new_password_confirmation'
        ]);

        // 2. Obtener el usuario autenticado
        $user = $request->user();

        // 3. Verificar que la contraseña actual sea correcta
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'La contraseña actual es incorrecta.'
            ], 400);
        }

        // 4. Actualizar la contraseña
        // Laravel se encarga de hashear automáticamente si está en el cast del modelo,
        // pero por seguridad explícita usamos Hash::make aquí también.
        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'message' => 'Contraseña actualizada correctamente.'
        ], 200);
    }
}