<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\Empresa;
use App\Models\Personal;
use App\Models\User;
use App\Models\TipoUsuario;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        //Crear Empresa
        $empresa = Empresa::create([
            'nombre_empresa' => 'Arenas & Arenas',
            'rol_empresa' => '76.123.456-7',
        ]);

        //Crear Tipos de Usuario (Roles)
        $rolAdmin = TipoUsuario::create(['tipo_usuario' => 'Administrador']);
        $rolConductor = TipoUsuario::create(['tipo_usuario' => 'Conductor']);

        //Crear Personal
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

        //Crear Usuarios
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

        // Asignar Roles
        // Juanito es Conductor
        $usuario1->roles()->attach($rolConductor->id_tipo_usuario);
        
        // Maria es Administradora
        $usuario2->roles()->attach($rolAdmin->id_tipo_usuario);

        $this->command->info('✅ Datos de prueba creados exitosamente');
        $this->command->info('📧 Usuario Conductor: juanito / 123456');
        $this->command->info('📧 Usuario Admin: maria / 123456');
    }
}