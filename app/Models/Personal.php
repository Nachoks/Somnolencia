<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Personal extends Model
{
    use HasFactory;

    protected $table = 'personal';
    protected $primaryKey = 'id_personal';

    protected $fillable = [
        'nombre_personal',
        'apellido_personal',
        'rut',
        'id_empresa'
    ];

    // Relación: Pertenece a una Empresa
    public function empresa()
    {
        return $this->belongsTo(Empresa::class, 'id_empresa', 'id_empresa');
    }

    // Relación: Tiene un Usuario asociado (Login)
    public function usuario()
    {
        return $this->hasOne(User::class, 'id_personal', 'id_personal');
    }
}