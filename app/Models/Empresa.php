<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Empresa extends Model
{
    use HasFactory;

    protected $table = 'empresa';      // Tu nombre de tabla singular
    protected $primaryKey = 'id_empresa'; // Tu PK personalizada

    protected $fillable = [
        'nombre_empresa',
        'rol_empresa', // Asumo que esto es el RUT o GIRO
    ];

    // Relación: Una empresa tiene mucho personal
    public function personal()
    {
        return $this->hasMany(Personal::class, 'id_empresa', 'id_empresa');
    }
}