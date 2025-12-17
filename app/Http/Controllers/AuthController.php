<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends Controller
{
    // LOGIN: Recibe credenciales y devuelve Token
    public function login(Request $request)
    {
        // 1. Validar que envíen los datos necesarios
        $request->validate([
            'nombre_usuario' => 'required|string',
            'password' => 'required|string',
        ]);

        // 2. Buscar al usuario por su nombre de usuario
        $user = User::where('nombre_usuario', $request->nombre_usuario)->first();

        // 3. Verificar contraseña
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Credenciales incorrectas'
            ], 401);
        }

        // 4. Cargar las relaciones (personal, empresa, roles)
        $user->load(['personal.empresa', 'roles']);

        // 5. Verificar que el usuario tenga el rol de "Conductor"
        $esConductor = $user->roles->contains(function ($rol) {
            return strtolower($rol->tipo_usuario) === 'conductor';
        });

        if (!$esConductor) {
            return response()->json([
                'message' => 'Acceso denegado. Solo conductores pueden acceder.'
            ], 403);
        }

        // 6. Si todo está bien, crear el Token
        $token = $user->createToken('movil')->plainTextToken;

        // 7. Responder con el Token y datos completos del usuario
        return response()->json([
            'message' => 'Login exitoso',   
            'access_token' => $token,
            'token_type' => 'Bearer',
            'usuario' => [
                'id' => $user->id_usuario,
                'nombre_usuario' => $user->nombre_usuario,
                'nombre_completo' => $user->personal->nombre_personal . ' ' . $user->personal->apellido_personal,
                'nombre' => $user->personal->nombre_personal,
                'apellido' => $user->personal->apellido_personal,
                'rut' => $user->personal->rut,
                'empresa' => [
                    'id' => $user->personal->empresa->id_empresa,
                    'nombre' => $user->personal->empresa->nombre_empresa,
                    'rol' => $user->personal->empresa->rol_empresa,
                ],
                'roles' => $user->roles->pluck('tipo_usuario'),
            ]
        ], 200);
    }

    // LOGOUT: Borrar tokens
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Sesión cerrada exitosamente'
        ], 200);
    }

    // OBTENER DATOS DEL USUARIO AUTENTICADO
    public function me(Request $request)
    {
        $user = $request->user();
        $user->load(['personal.empresa', 'roles']);

        return response()->json([
            'usuario' => [
                'id' => $user->id_usuario,
                'nombre_usuario' => $user->nombre_usuario,
                'nombre_completo' => $user->personal->nombre_personal . ' ' . $user->personal->apellido_personal,
                'nombre' => $user->personal->nombre_personal,
                'apellido' => $user->personal->apellido_personal,
                'rut' => $user->personal->rut,
                'empresa' => [
                    'id' => $user->personal->empresa->id_empresa,
                    'nombre' => $user->personal->empresa->nombre_empresa,
                    'rol' => $user->personal->empresa->rol_empresa,
                ],
                'roles' => $user->roles->pluck('tipo_usuario'),
            ]
        ], 200);
    }
}