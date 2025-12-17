<?php

namespace App\Models;

// Importante: Agrega esto para que funcione la API (tokens)
use Laravel\Sanctum\HasApiTokens; 
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable; // <-- Agregamos HasApiTokens

    //Definir tabla personalizada
    protected $table = 'usuarios';

    //Definir llave primaria personalizada
    protected $primaryKey = 'id_usuario';

    /**
     * Los atributos que se pueden asignar masivamente.
     * Aquí ponemos las columnas REALES de tu tabla usuarios.
     */
    protected $fillable = [
        'nombre_usuario', // Tu columna personalizada
        'password',       // Acordamos usar el estándar 'password'
        'id_personal',    // La llave foránea

    ];

    /**
     * Atributos que no se deben mostrar en la respuesta JSON.
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Configuraciones de tipos de datos.
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime', // Coméntalo si no usas verificación de email aún
            'password' => 'hashed', // Esto encripta la contraseña automáticamente
        ];
    }


    public function personal()
    {
        return $this->belongsTo(Personal::class, 'id_personal', 'id_personal');
    }

    /*
     * Relación: Un Usuario tiene muchos Roles (Tipos).
     * Uso: $user->roles
     */
    public function roles()
    {
        return $this->belongsToMany(
            TipoUsuario::class, 
            'usuario_rol',      // Tabla intermedia
            'id_usuario',       // FK de este modelo en la intermedia
            'id_tipo_usuario'   // FK del otro modelo en la intermedia
        );
    }
}