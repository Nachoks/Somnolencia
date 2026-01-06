<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Vehiculo;

class VehiculoController extends Controller
{
    public function obtenerPatentes(Request $request)
    {
        //Obtener el usuario autenticado
        $user = $request->user();

        //Verificar que tenga personal y empresa asociada
        if (!$user->personal || !$user->personal->id_empresa) {
            return response()->json(['message' => 'Usuario sin empresa asignada'], 404);
        }

        // Obtener el ID de la empresa
        $idEmpresa = $user->personal->id_empresa;

        // Buscar SOLO las patentes de esa empresa
        $patentes = Vehiculo::where('id_empresa', $idEmpresa)
                            ->pluck('patente');

        return response()->json($patentes);
    }
}