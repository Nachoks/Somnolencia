<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf; // Importamos la fachada del PDF
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use App\Mail\ReporteViajeMail;

class ViajeController extends Controller
{
    public function registrar(Request $request)
    {
        
        // 1. Validar datos mínimos (opcional pero recomendado)
        $request->validate([
            'conductor' => 'required',
            'tipo_vehiculo' => 'required',
            'tests' => 'required|array'
        ]);

        $datos = $request->all();
        
        // Generar nombre único para el archivo
        $fecha = date('Ymd_His');
        $nombreConductor = str_replace(' ', '_', $datos['conductor']);
        $nombreArchivo = "reporte_viaje_{$nombreConductor}_{$fecha}.pdf";

        try {
            // 2. Generar el PDF en memoria usando la vista creada
            $pdf = Pdf::loadView('pdf.reporte_viaje', ['datos' => $datos]);
            $contenidoPdf = $pdf->output();

            // GUARDAR COPIA EN EL SERVIDOR
            Storage::disk('disco_reportes')->put($nombreArchivo, $contenidoPdf);

            // ENVIAR EL CORREO (Aqui va el email del supervisor)
            $listaCorreos = explode(',', env('MAILS_SUPERVISORES'));
            Mail::to($listaCorreos)->send(
                new ReporteViajeMail($datos, $contenidoPdf, $nombreArchivo)
            );

            return response()->json([
                'success' => true,
                'message' => 'Viaje registrado, PDF guardado y notificado por correo.'
            ], 200);

        } catch (\Exception $e) {
            // Loguear el error para que puedas revisarlo en storage/logs/laravel.log
            \Log::error("Error registrando viaje: " . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Ocurrió un error en el servidor: ' . $e->getMessage()
            ], 500);
        }
    }
}