<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vehiculo extends Model
{
    use HasFactory;

    protected $table = 'vehiculo'; // Nombre de tu tabla

    protected $fillable = [
        'patente',
        'disponibilidad',
        'id_empresa', // Necesario para poder asignar el vehículo a una empresa
    ];

    // Relación inversa: Un vehículo pertenece a una empresa
    public function empresa()
    {
        // belongsTo(Modelo, 'llave_foranea_local', 'llave_primaria_otra_tabla')
        return $this->belongsTo(Empresa::class, 'id_empresa', 'id_empresa');
    }
}