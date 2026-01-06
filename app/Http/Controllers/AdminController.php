<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB; // Necesario para transacciones
use Illuminate\Support\Facades\Hash; // Opcional si usas el cast 'hashed' en el modelo, pero buena práctica importarlo
use App\Models\User;
use App\Models\Personal;
use App\Models\Empresa;
use App\Models\TipoUsuario;

class AdminController extends Controller
{
    // --- LISTAR USUARIOS  ---
    public function listarUsuarios()
    {
        $users = User::with(['personal.empresa', 'roles'])->get();

        $usersOrdenados = $users->sortBy(function ($user) {
            return $user->personal ? $user->personal->nombre_personal : $user->nombre_usuario;
        })->values();

        return response()->json($usersOrdenados, 200);
    }

    // --- LISTAR EMPRESAS  ---
    public function listarEmpresas()
    {
        // Seleccionamos solo lo necesario para el dropdown
        $empresas = Empresa::select('id_empresa', 'nombre_empresa')->get();
        return response()->json($empresas, 200);
    }

    public function cambiarEstadoUsuario($id){
        try {
            $user = User::findOrFail($id);
        
            // Invertimos el valor de 'estado'
            $user->estado = !$user->estado; 
            $user->save();

            $texto = $user->estado ? 'Habilitado' : 'Deshabilitado';

            return response()->json([
                'message' => "Usuario $texto correctamente",
                'user' => $user
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Error', 'error' => $e->getMessage()], 500);
        }
    }

    // --- CREAR USUARIO  ---
    public function crearUsuario(Request $request)
    {
        // Validación de datos entrantes desde Flutter
        $request->validate([
            'personal.nombre'     => 'required|string',
            'personal.apellido'   => 'required|string',
            'personal.rut'        => 'required|string|unique:personal,rut',
            'personal.id_empresa' => 'required|integer|exists:empresa,id_empresa',
            'usuario.username'    => 'required|string|unique:usuarios,nombre_usuario',
            'usuario.password'    => 'required|string|min:6',
            'roles'               => 'required|array|min:1', // Debe venir al menos un rol
        ]);

        try {
            // INICIO TRANSACCIÓN
            $result = DB::transaction(function () use ($request) {
                
                // Crear Personal
                $nuevoPersonal = Personal::create([
                    'nombre_personal'   => $request->input('personal.nombre'),
                    'apellido_personal' => $request->input('personal.apellido'),
                    'rut'               => $request->input('personal.rut'),
                    'correo' => $request->personal['correo'] ?? null,
                    'id_empresa'        => $request->input('personal.id_empresa'),
                ]);

                // Crear Usuario vinculado
                // NOTA: Como en tu modelo User.php tienes 'password' => 'hashed',
                // Laravel encriptará automáticamente al crear. No hace falta Hash::make() aquí si el cast funciona.
                $nuevoUsuario = User::create([
                    'nombre_usuario' => $request->input('usuario.username'),
                    'password'       => $request->input('usuario.password'), 
                    'id_personal'    => $nuevoPersonal->id_personal,
                ]);

                // Asignar Roles
                // Buscamos los IDs de los roles basados en los nombres que envía Flutter 
                $rolesNombres = $request->input('roles');
                $rolesIds = TipoUsuario::whereIn('tipo_usuario', $rolesNombres) 
                                       ->pluck('id_tipo_usuario');
                
                // Vinculamos en la tabla pivote usuario_rol
                $nuevoUsuario->roles()->attach($rolesIds);

                return $nuevoUsuario;
            });

            return response()->json([
                'success' => true, 
                'message' => 'Usuario creado exitosamente',
                'data' => $result
            ], 201);

        } catch (\Exception $e) {
            // Si falla, deshace todo (Personal no se crea si falla Usuario)
            return response()->json([
                'success' => false, 
                'message' => 'Error al guardar: ' . $e->getMessage()
            ], 500);
        }
    }

    // --- EDITAR USUARIO ---
    public function actualizarUsuario(Request $request, $id)
    {
        $usuario = User::with('personal')->find($id);

        if (!$usuario) {
            return response()->json(['success' => false, 'message' => 'Usuario no encontrado'], 404);
        }

        $personal = $usuario->personal;

        // 1. Validaciones (Agregamos 'roles')
        $request->validate([
            'nombre'   => 'required|string',
            'apellido' => 'required|string',
            'rut'      => 'required|string|unique:personal,rut,' . $personal->id_personal . ',id_personal',
            'correo'   => 'required|email', 
            'password' => 'nullable|string|min:6',
            'roles'    => 'nullable|array', // ✅ Permitimos recibir roles
        ]);

        try {
            DB::transaction(function () use ($request, $usuario, $personal) {
                
                // 2. Actualizar Datos Personales
                $personal->update([
                    'nombre_personal'   => $request->input('nombre'),
                    'apellido_personal' => $request->input('apellido'),
                    'rut'               => $request->input('rut'),
                    'correo'            => $request->input('correo'),
                ]);

                // 3. Actualizar Password (si viene)
                if ($request->filled('password')) {
                    $usuario->password = $request->input('password');
                    $usuario->save();
                }

                // 4. ✅ ACTUALIZAR ROLES
                // Si el request trae 'roles', los actualizamos.
                if ($request->has('roles')) {
                    $rolesNombres = $request->input('roles');
                    
                    // Buscamos los IDs correspondientes a esos nombres
                    $rolesIds = TipoUsuario::whereIn('tipo_usuario', $rolesNombres)
                                           ->pluck('id_tipo_usuario');

                    // 'sync' borra los roles viejos y pone los nuevos. ¡Mágico!
                    $usuario->roles()->sync($rolesIds);
                }
            });

            return response()->json([
                'success' => true, 
                'message' => 'Usuario y roles actualizados correctamente'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error al actualizar: ' . $e->getMessage()
            ], 500);
        }
    }

}