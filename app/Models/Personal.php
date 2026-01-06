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
    
    // Esto le dice a Laravel: "Cuando conviertas a JSON, incluye este campo extra"
    protected $appends = ['nombre_completo'];

    // Aquí defines cómo se crea ese campo extra
    public function getNombreCompletoAttribute()
    {
        // Concatenamos tus columnas reales
        return "{$this->nombre_personal} {$this->apellido_personal}";
    }

    public function empresa()
    {
        return $this->belongsTo(Empresa::class, 'id_empresa', 'id_empresa');
    }

    public function usuario()
    {
        return $this->hasOne(User::class, 'id_personal', 'id_personal');
    }
}