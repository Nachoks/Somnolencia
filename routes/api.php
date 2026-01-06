<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ViajeController;
use App\Http\Controllers\VehiculoController;
use App\Http\Controllers\AdminController;

// Rutas públicas
Route::post('/login', [AuthController::class, 'login']);
Route::post('/viajes/registrar', [ViajeController::class, 'registrar']);
Route::get('/ping', function () {
    return response()->json(['status' => 'ok']);
});

// Rutas protegidas (Token Requerido)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    
    Route::get('/vehiculos/patentes', [VehiculoController::class, 'obtenerPatentes']);

    // --- ZONA ADMIN ---
    Route::get('/admin/users', [AdminController::class, 'listarUsuarios']);
    Route::get('/admin/empresas', [AdminController::class, 'listarEmpresas']); // Para el dropdown
    Route::post('/admin/usuarios', [AdminController::class, 'crearUsuario']);  // Para guardar el formulario
    Route::put('/admin/usuarios/{id}/estado', [AdminController::class, 'cambiarEstadoUsuario']);
    Route::put('/admin/usuarios/{id}', [AdminController::class, 'actualizarUsuario']);
});