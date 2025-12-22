<!DOCTYPE html>
<html>
<head>
    <title>Nuevo Viaje Registrado</title>
</head>
<body>
    <h2>Se ha registrado un nuevo inicio de viaje.</h2>
    <p><strong>Conductor:</strong> {{ $datos['conductor'] }}</p>
    <p><strong>Fecha:</strong> {{ $datos['fecha'] }}</p>
    <p><strong>Hora:</strong> {{ $datos['hora'] }}</p>

    <p>Se adjunta el reporte detallado en formato PDF.</p>
</body>
</html>