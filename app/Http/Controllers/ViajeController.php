<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf; // Importamos la fachada del PDF
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Http; // Importante para descargar el mapa
use App\Mail\ReporteViajeMail;
use App\Models\User;

class ViajeController extends Controller
{
    public function registrar(Request $request)
    {
        // 1. Validar datos mínimos
        $request->validate([
            'conductor' => 'required',
            'tipo_vehiculo' => 'required',
            'tests' => 'required|array'
        ]);

        $datos = $request->all();

        // --- NUEVO: BUSCAR NOMBRE COMPLETO ---
        // Buscamos el usuario por su 'nombre_usuario' (que es lo que envía el app)
        $usuario = User::where('nombre_usuario', $datos['conductor'])->first();
        
        // Si encontramos al usuario y tiene ficha de personal asociada
        if ($usuario && $usuario->personal) {
            // Reemplazamos el username por el nombre completo real
            // Esto actualizará automáticamente el PDF y el Correo
            $datos['conductor'] = $usuario->personal->nombre_completo;
        }
        // -------------------------------------
        
        // Generar nombre único para el archivo (usando ahora el nombre real si existe)
        $fecha = date('Ymd_His');
        $nombreConductor = str_replace(' ', '_', $datos['conductor']);
        $nombreArchivo = "{$fecha}_reporte_viaje_{$nombreConductor}.pdf";

        // --- INICIO: GENERAR MAPA DETALLADO (Yandex) ---
        try {
            // 1. Validar y limpiar coordenadas
            $lat = (float) ($datos['ubicacion']['latitud'] ?? 0);
            $lon = (float) ($datos['ubicacion']['longitud'] ?? 0);

            if ($lat == 0 && $lon == 0) {
                throw new \Exception("Coordenadas inválidas (0,0)");
            }

            // 2. Construir URL de Yandex con MÁXIMO DETALLE
            // Documentación de cambios para "Alta Definición":
            // ll   = Centro (Longitud,Latitud)
            // z=17 = Zoom máximo disponible (nivel casa/calle)
            // l=map = Tipo mapa calles (usa 'sat,skl' si prefieres satélite híbrido)
            // lang=es_ES = Forzamos etiquetas en español
            // size=650,450 = Pedimos la imagen más grande posible para reducirla luego (Efecto HD)
            // pt   = Marcador rojo (pm2rdm)
            
            $urlMapa = "https://static-maps.yandex.ru/1.x/?ll={$lon},{$lat}&z=17&l=map&pt={$lon},{$lat},pm2rdm&lang=es_ES&size=650,450";

            // 3. Descargar imagen
            // 'withoutVerifying' evita errores SSL en local/Windows
            $response = Http::withoutVerifying()->timeout(10)->get($urlMapa);

            if ($response->successful()) {
                $imagenMapaContenido = $response->body();
                // Convertimos a Base64
                $datos['mapa_base64'] = 'data:image/png;base64,' . base64_encode($imagenMapaContenido);
                $datos['mapa_error'] = null;
            } else {
                $datos['mapa_base64'] = null;
                $datos['mapa_error'] = "Error API Mapa: " . $response->status();
                \Log::error("Error Yandex Maps: " . $response->body());
            }

        } catch (\Exception $e) {
            $datos['mapa_base64'] = null;
            $datos['mapa_error'] = "Excepción Mapa: " . $e->getMessage();
            \Log::error("Excepción generando mapa: " . $e->getMessage());
        }
        // --- FIN: GENERAR MAPA ---

        try {
            // 3. Generar el PDF
            $pdf = Pdf::loadView('pdf.reporte_viaje', ['datos' => $datos]);
            $contenidoPdf = $pdf->output();

            // 4. Guardar copia en el disco
            Storage::disk('disco_reportes')->put($nombreArchivo, $contenidoPdf);

            // 5. Enviar Correo
            if (env('MAILS_SUPERVISORES')) {
                $listaCorreos = explode(',', env('MAILS_SUPERVISORES'));
                Mail::to($listaCorreos)->send(
                    new ReporteViajeMail($datos, $contenidoPdf, $nombreArchivo)
                );
            }

            return response()->json([
                'success' => true,
                'message' => 'Viaje registrado correctamente.'
            ], 200);

        } catch (\Exception $e) {
            \Log::error("Error registrando viaje: " . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error en el servidor: ' . $e->getMessage()
            ], 500);
        }
    }
}