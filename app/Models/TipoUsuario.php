<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TipoUsuario extends Model
{
    use HasFactory;

    protected $table = 'tipo_usuario';
    protected $primaryKey = 'id_tipo_usuario';

    protected $fillable = [
        'tipo_usuario',
    ];

    // Relación: Un tipo de usuario puede tener muchos usuarios
    public function usuarios()
    {
        return $this->belongsToMany(
            User::class, 
            'usuario_rol',      // Tabla pivot
            'id_tipo_usuario',  // FK de este modelo en la pivot
            'id_usuario'        // FK del otro modelo en la pivot
        );
    }
}