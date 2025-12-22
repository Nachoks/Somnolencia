<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ViajeController;
use App\Http\Controllers\VehiculoController;

// Rutas públicas (sin autenticación)
Route::post('/login', [AuthController::class, 'login']);
Route::post('/viajes/registrar', [ViajeController::class, 'registrar']);


// Rutas protegidas (requieren token)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/vehiculos/patentes', [VehiculoController::class, 'obtenerPatentes']);
    
});