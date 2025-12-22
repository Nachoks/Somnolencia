<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\Empresa;
use App\Models\Personal;
use App\Models\User;
use App\Models\TipoUsuario;
use App\Models\Vehiculo; // <--- ¡Importante! Importar el modelo Vehiculo

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Crear Empresa
        $empresa = Empresa::create([
            'nombre_empresa' => 'Arenas & Arenas',
            'rol_empresa' => '76.123.456-7',
        ]);

        // 2. Crear Tipos de Usuario (Roles)
        $rolAdmin = TipoUsuario::create(['tipo_usuario' => 'Administrador']);
        $rolConductor = TipoUsuario::create(['tipo_usuario' => 'Conductor']);

        // 3. Crear Personal
        $personal1 = Personal::create([
            'nombre_personal' => 'Juanito',
            'apellido_personal' => 'Perez',
            'rut' => '20.123.456-7',
            'id_empresa' => $empresa->id_empresa,
        ]);

        $personal2 = Personal::create([
            'nombre_personal' => 'Maria',
            'apellido_personal' => 'Gonzalez',
            'rut' => '19.987.654-3',
            'id_empresa' => $empresa->id_empresa,
        ]);

        // 4. Crear Usuarios
        $usuario1 = User::create([
            'nombre_usuario' => 'juanito',
            'password' => Hash::make('123456'),
            'id_personal' => $personal1->id_personal,
        ]);

        $usuario2 = User::create([
            'nombre_usuario' => 'maria',
            'password' => Hash::make('123456'),
            'id_personal' => $personal2->id_personal,
        ]);

        // 5. Asignar Roles
        $usuario1->roles()->attach($rolConductor->id_tipo_usuario);
        $usuario2->roles()->attach($rolAdmin->id_tipo_usuario);

        // 6. Crear Vehículos (NUEVO)
        // Usamos $empresa->id_empresa para vincularlos a la empresa creada arriba
        
        Vehiculo::create([
            'patente' => 'HHYT-22',
            'disponibilidad' => 'Disponible',
            'id_empresa' => $empresa->id_empresa,
        ]);

        Vehiculo::create([
            'patente' => 'JKLL-55',
            'disponibilidad' => 'En Ruta',
            'id_empresa' => $empresa->id_empresa,
        ]);

        Vehiculo::create([
            'patente' => 'BBCL-10',
            'disponibilidad' => 'Mantenimiento',
            'id_empresa' => $empresa->id_empresa,
        ]);

        Vehiculo::create([
            'patente' => 'ZZYT-99',
            'disponibilidad' => 'Disponible',
            'id_empresa' => $empresa->id_empresa,
        ]);

        $this->command->info('✅ Datos de prueba creados exitosamente');
        $this->command->info('🚗 4 Vehículos agregados a la empresa ' . $empresa->nombre_empresa);
        $this->command->info('📧 Usuario Conductor: juanito / 123456');
        $this->command->info('📧 Usuario Admin: maria / 123456');
    }
}