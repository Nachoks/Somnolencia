<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Nota: Uso 'vehiculo' en singular para mantener tu convención de nombres
        Schema::create('vehiculo', function (Blueprint $table) {
            $table->id(); // Clave primaria 'id'
            $table->string('patente', 10); // Patente del vehículo
            $table->string('disponibilidad')->nullable(); // Puede ser nulo
            
            // Llave foránea para conectar con la Empresa
            // Definimos que es unsignedBigInteger para coincidir con id() de empresa
            $table->unsignedBigInteger('id_empresa'); 
            
            // Creamos la restricción (Foreign Key)
            $table->foreign('id_empresa')
                  ->references('id_empresa') // Apunta a la PK id_empresa
                  ->on('empresa')            // De la tabla empresa
                  ->onDelete('cascade');     // Si se borra la empresa, se borran sus autos

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vehiculo');
    }
};