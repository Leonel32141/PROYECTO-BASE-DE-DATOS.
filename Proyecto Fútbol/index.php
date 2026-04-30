<?php include 'includes/conexion.php';
include 'includes/funciones.php'; 
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proyecto Fútbol</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <div class="layout-container">
        <h1>Tiki-Taka</h1>
        <p>Accede a tu cuenta o regístrate para continuar.</p>
        <div style="text-align: center; margin-top: 20px;">
            <a href="auth/login.php" class="btn btn-primary" style="margin-right: 10px; margin-bottom: 10px;">Iniciar Sesión</a>
            <a href="auth/register.php" class="btn btn-primary">Registrarse</a>
        </div>
    </div>
</body>
</html>