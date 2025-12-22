<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Empresa extends Model
{
    use HasFactory;

    protected $table = 'empresa';
    protected $primaryKey = 'id_empresa';

    protected $fillable = [
        'nombre_empresa',
        'rol_empresa',
    ];

    public function personal()
    {
        return $this->hasMany(Personal::class, 'id_empresa', 'id_empresa');
    }

    // --- AGREGAR ESTO ---
    // Relación: Una empresa tiene muchos vehículos
    public function vehiculos()
    {
        // hasMany(ModeloHijo, 'llave_foranea_en_hijo', 'llave_primaria_local')
        return $this->hasMany(Vehiculo::class, 'id_empresa', 'id_empresa');
    }
}