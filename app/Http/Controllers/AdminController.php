<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;

class AdminController extends Controller
{
    // Obtener lista completa de usuarios (con datos personales y roles)
    public function listarUsuarios()
    {
        // 1. Traemos todos los usuarios cargando sus relaciones
        // 'personal.empresa' trae los datos de la empresa vinculada al personal
        // 'roles' trae los roles asignados
        $users = User::with(['personal.empresa', 'roles'])->get();

        // 2. Ordenamos la colección
        // Priorizamos ordenar por el nombre real (personal), si no existe, por el usuario
        $usersOrdenados = $users->sortBy(function ($user) {
            return $user->personal ? $user->personal->nombre_personal : $user->nombre_usuario;
        })->values(); // 'values()' es importante para resetear los índices del array JSON

        // 3. Retornamos la respuesta
        return response()->json($usersOrdenados, 200);
    }
}