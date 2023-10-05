<?php
// Reenviar las solicitudes de Vercel a index.php normalmente
require __DIR__ . '/../public/index.php';

// Obtener el puerto proporcionado por Railway o usar el valor por defecto 8000
$port = getenv('PORT') ?: 8000;

// Escuchar en el puerto y el host 0.0.0.0
$app->run('0.0.0.0', $port);