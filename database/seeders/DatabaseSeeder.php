<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\Empresa;
use App\Models\Personal;
use App\Models\User;
use App\Models\TipoUsuario;
use App\Models\Vehiculo;

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

        // 3. Crear Personal y Usuarios (TODOS LOS CONDUCTORES)
        $conductores = [
            ['usuario' => 'amartinez', 'nombre' => 'Ariel', 'apellido' => 'Martinez', 'rut' => '12.345.678-9'],
            ['usuario' => 'carenas', 'nombre' => 'Camilo', 'apellido' => 'Arenas', 'rut' => '13.456.789-0'],
            ['usuario' => 'carenasc', 'nombre' => 'Camilo', 'apellido' => 'Arenas', 'rut' => '14.567.890-1'],
            ['usuario' => 'cmitchell', 'nombre' => 'Cristopher', 'apellido' => 'Mitchell', 'rut' => '15.678.901-2'],
            ['usuario' => 'fperez', 'nombre' => 'Felipe', 'apellido' => 'Perez', 'rut' => '16.789.012-3'],
            ['usuario' => 'glillo', 'nombre' => 'Gabriela', 'apellido' => 'Lillo', 'rut' => '17.890.123-4'],
            ['usuario' => 'ierazo', 'nombre' => 'Italo', 'apellido' => 'Erazo', 'rut' => '18.901.234-5'],
            ['usuario' => 'kpenayillo', 'nombre' => 'Kevin', 'apellido' => 'Pena', 'rut' => '19.012.345-6'],
            ['usuario' => 'mdiaz', 'nombre' => 'Mauricio', 'apellido' => 'Diaz', 'rut' => '20.123.456-7'],
            ['usuario' => 'mvielma', 'nombre' => 'Martin', 'apellido' => 'Vielma', 'rut' => '21.234.567-8'],
            ['usuario' => 'pzamora', 'nombre' => 'Patricio', 'apellido' => 'Zamora', 'rut' => '22.345.678-9'],
            ['usuario' => 'rzamora', 'nombre' => 'Ruben', 'apellido' => 'Zamora', 'rut' => '23.456.789-0'],
            ['usuario' => 'scortes', 'nombre' => 'Sebastian', 'apellido' => 'Cortes', 'rut' => '24.567.890-1'],
        ];

        foreach ($conductores as $conductor) {
            // Crear personal
            $personal = Personal::create([
                'nombre_personal' => $conductor['nombre'],
                'apellido_personal' => $conductor['apellido'],
                'rut' => $conductor['rut'],
                'id_empresa' => $empresa->id_empresa,
            ]);

            // Crear usuario
            $usuario = User::create([
                'nombre_usuario' => $conductor['usuario'],
                'password' => Hash::make('123456'), // Contraseña por defecto
                'id_personal' => $personal->id_personal,
            ]);

            // Asignar rol de Conductor
            $usuario->roles()->attach($rolConductor->id_tipo_usuario);
        }

        // 4. Crear Usuario Administrador
        $personalAdmin = Personal::create([
            'nombre_personal' => 'Maria',
            'apellido_personal' => 'Gonzalez',
            'rut' => '10.111.222-3',
            'id_empresa' => $empresa->id_empresa,
        ]);

        $usuarioAdmin = User::create([
            'nombre_usuario' => 'maria',
            'password' => Hash::make('123456'),
            'id_personal' => $personalAdmin->id_personal,
        ]);

        $usuarioAdmin->roles()->attach($rolAdmin->id_tipo_usuario);

        // 5. Crear Vehículos
        $vehiculos = [
            ['patente' => 'HHYT-22', 'disponibilidad' => 'Disponible'],
            ['patente' => 'JKLL-55', 'disponibilidad' => 'Disponible'],
            ['patente' => 'BBCL-10', 'disponibilidad' => 'Disponible'],
            ['patente' => 'ZZYT-99', 'disponibilidad' => 'Disponible'],
            ['patente' => 'AABB-33', 'disponibilidad' => 'Disponible'],
            ['patente' => 'CCDD-44', 'disponibilidad' => 'Disponible'],
        ];

        foreach ($vehiculos as $vehiculo) {
            Vehiculo::create([
                'patente' => $vehiculo['patente'],
                'disponibilidad' => $vehiculo['disponibilidad'],
                'id_empresa' => $empresa->id_empresa,
            ]);
        }

        // Mensajes informativos
        $this->command->info('✅ Datos de prueba creados exitosamente');
        $this->command->info('🏢 Empresa: ' . $empresa->nombre_empresa);
        $this->command->info('👥 ' . count($conductores) . ' Conductores creados');
        $this->command->info('👤 1 Administrador creado');
        $this->command->info('🚗 ' . count($vehiculos) . ' Vehículos agregados');
        $this->command->info('');
        $this->command->info('🔑 Credenciales de acceso:');
        $this->command->info('   Admin: maria / 123456');
        $this->command->info('   Conductores: [usuario] / 123456');
        $this->command->info('   Ejemplos: amartinez/123456, carenas/123456, fperez/123456');
    }
}