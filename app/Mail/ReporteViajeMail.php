<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ReporteViajeMail extends Mailable
{
    use Queueable, SerializesModels;

    public $datos;
    protected $pdfOutput;
    protected $nombreArchivo;

    /**
     * Recibimos los datos, el contenido binario del PDF y el nombre del archivo.
     */
    public function __construct($datos, $pdfOutput, $nombreArchivo)
    {
        $this->datos = $datos;
        $this->pdfOutput = $pdfOutput;
        $this->nombreArchivo = $nombreArchivo;
    }

    public function build()
    {
        return $this->subject('Nuevo Reporte de Viaje - ' . ($this->datos['conductor'] ?? 'Conductor'))
                    ->view('emails.nuevo_viaje') // Crearemos esta vista simple en el Paso 3
                    ->attachData($this->pdfOutput, $this->nombreArchivo, [
                        'mime' => 'application/pdf',
                    ]);
    }
}