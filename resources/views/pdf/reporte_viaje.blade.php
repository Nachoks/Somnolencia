<!DOCTYPE html>
<html>
<head>
    <title>Reporte de Viaje</title>
    <style>
        body { font-family: sans-serif; font-size: 14px; }
        
        /* --- ESTILO FALTANTE PARA EL LOGO --- */
        .logo {
            position: absolute; /* Lo saca del flujo normal */
            top: 0;             /* Pegado arriba */
            right: 0;           /* Pegado a la derecha (cambia a 'left: 0' para izquierda) */
            width: 120px;       /* Ajusta el tamaño según necesites */
            height: auto;
        }
        /* ------------------------------------ */

        .header { text-align: center; margin-bottom: 20px; margin-top: 20px; }
        .section { margin-bottom: 15px; border-bottom: 1px solid #ccc; padding-bottom: 10px; }
        .approved { color: green; font-weight: bold; }
        .rejected { color: red; font-weight: bold; }
        .checklist-item { margin-bottom: 4px; border-bottom: 1px dotted #eee; }
        .status-badge { float: right; font-size: 12px; }
    </style>
</head>
<body>
    
    <img src="{{ public_path('images/logo.png') }}" class="logo" alt="Logo">

    <div class="header">
        <h1>Reporte de Inicio de Viaje</h1>
        <p>Inversiones Arenas & Arenas</p>
    </div>

    <div class="section">
        <h3>Información General</h3>
        <p><strong>Conductor:</strong> {{ $datos['conductor'] }}</p>
        <p><strong>RUT:</strong> {{ $datos['rut'] }}</p>
        <p><strong>Vehículo:</strong> {{ ucfirst($datos['tipo_vehiculo']) }}</p>
        <p><strong>Patente:</strong> {{ $datos['patente'] ?? 'N/A' }}</p>
        <p><strong>Descripción:</strong> {{ $datos['descripcion'] }}</p>
        <p><strong>Fecha:</strong> {{ $datos['fecha'] }}</p>
        <p><strong>Hora:</strong>{{ $datos['hora'] }}</p>

    </div>

    <div class="section">
        <h3>Ubicación de Inicio</h3>
        <p><strong>Dirección:</strong> {{ $datos['ubicacion']['direccion'] }}</p>
        <p><small>Coordenadas: {{ $datos['ubicacion']['latitud'] }}, {{ $datos['ubicacion']['longitud'] }}</small></p>

        @if(isset($datos['mapa_base64']) && $datos['mapa_base64'])
            <div style="margin-top: 15px; text-align: center;">
                <img src="{{ $datos['mapa_base64'] }}" style="width: 100%; max-width: 600px; border: 1px solid #ccc; border-radius: 4px;">
            </div>
        @else
            <div style="margin-top: 10px; padding: 10px; background-color: #f8f9fa; border: 1px dashed #ccc; text-align: center;">
                <p style="color: grey; font-style: italic; margin: 0;">(Vista previa del mapa no disponible)</p>
                
                @if(isset($datos['mapa_error']))
                    <p style="color: red; font-size: 11px; font-weight: bold; margin-top: 5px;">
                        ⚠️ DETALLE TÉCNICO: {{ $datos['mapa_error'] }}
                    </p>
                @endif
            </div>
        @endif
    </div>

    <div class="section">
        <h3>Estado de Tests</h3>
        <ul>
            <li>Somnolencia: <span class="{{ $datos['tests']['somnolencia'] ? 'approved' : 'rejected' }}">{{ $datos['tests']['somnolencia'] ? 'APROBADO' : 'RECHAZADO' }}</span></li>
            <li>Fatiga: <span class="{{ $datos['tests']['fatiga'] ? 'approved' : 'rejected' }}">{{ $datos['tests']['fatiga'] ? 'APROBADO' : 'RECHAZADO' }}</span></li>
            <li>Reacción: <span class="{{ $datos['tests']['reaccion'] ? 'approved' : 'rejected' }}">{{ $datos['tests']['reaccion'] ? 'APROBADO' : 'RECHAZADO' }}</span></li>
            <li>Checklist: <span class="{{ $datos['tests']['checklist'] ? 'approved' : 'rejected' }}">{{ $datos['tests']['checklist'] ? 'APROBADO' : 'CON OBSERVACIONES' }}</span></li>
        </ul>
    </div>

    @if(isset($datos['tests']['checklist_detalle']) && is_array($datos['tests']['checklist_detalle']))
        <div class="section">
            <h3>Detalle de Inspección (Checklist)</h3>
            @foreach($datos['tests']['checklist_detalle'] as $item)
                <div class="checklist-item">
                    <span>{{ $item['item'] }}</span>
                    @if($item['marcado'])
                        <span class="status-badge approved">OK</span>
                    @else
                        <span class="status-badge rejected">PENDIENTE</span>
                    @endif
                </div>
            @endforeach
        </div>
    @endif
</body>
</html>