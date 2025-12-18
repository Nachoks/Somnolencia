<!DOCTYPE html>
<html>
<head>
    <title>Reporte de Viaje</title>
    <style>
        body { font-family: sans-serif; }
        .header { text-align: center; margin-bottom: 20px; }
        .section { margin-bottom: 15px; border-bottom: 1px solid #ccc; padding-bottom: 10px; }
        .approved { color: green; font-weight: bold; }
        .rejected { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Reporte de Inicio de Viaje</h1>
        <p>Inversiones Arenas & Arenas</p>
    </div>

    <div class="section">
        <h3>Información General</h3>
        <p><strong>Conductor:</strong> {{ $datos['conductor'] }}</p>
        <p><strong>RUT:</strong> {{ $datos['rut'] }}</p>
        <p><strong>Vehículo:</strong> {{ ucfirst($datos['tipo_vehiculo']) }}</p>
        <p><strong>Descripción:</strong> {{ $datos['descripcion'] ?? 'Sin observaciones' }}</p>
        <p><strong>Fecha y Hora:</strong> {{ $datos['fecha_hora'] }}</p>
    </div>

    <div class="section">
        <h3>Ubicación de Inicio</h3>
        <p><strong>Dirección:</strong> {{ $datos['ubicacion']['direccion'] }}</p>
        <p><small>Coordenadas: {{ $datos['ubicacion']['latitud'] }}, {{ $datos['ubicacion']['longitud'] }}</small></p>
    </div>

    <div class="section">
        <h3>Estado de Tests</h3>
        <ul>
            <li>Somnolencia: <span class="{{ $datos['tests']['somnolencia'] ? 'approved' : 'rejected' }}">{{ $datos['tests']['somnolencia'] ? 'APROBADO' : 'RECHAZADO' }}</span></li>
            <li>Fatiga: <span class="{{ $datos['tests']['fatiga'] ? 'approved' : 'rejected' }}">{{ $datos['tests']['fatiga'] ? 'APROBADO' : 'RECHAZADO' }}</span></li>
            <li>Reacción: <span class="{{ $datos['tests']['reaccion'] ? 'approved' : 'rejected' }}">{{ $datos['tests']['reaccion'] ? 'APROBADO' : 'RECHAZADO' }}</span></li>
            <li>Checklist: <span class="{{ $datos['tests']['checklist'] ? 'approved' : 'rejected' }}">{{ $datos['tests']['checklist'] ? 'APROBADO' : 'RECHAZADO' }}</span></li>
        </ul>
    </div>
</body>
</html>