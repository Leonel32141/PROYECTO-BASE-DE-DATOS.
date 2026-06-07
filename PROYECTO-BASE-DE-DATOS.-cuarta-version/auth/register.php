<?php
require_once __DIR__ . '/../includes/conexion.php';
require_once __DIR__ . '/../includes/funciones.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nombre = trim($_POST['nombre_usuario'] ?? '');
    $apellido = trim($_POST['apellido'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password_raw = $_POST['pass'] ?? '';
    $pass_hash =  password_hash($password_raw, PASSWORD_DEFAULT);
    if ($nombre === '' || $apellido === '' || $email === '' || $pass_hash === '') {
        $error = 'Todos los campos son obligatorios.';
    } else {
        // Usar stored procedure para registrar usuario
        $stmt = $conexion->prepare("CALL registrar_usuario(?, ?, ?, ?)");
        if ($stmt) {
            $stmt->bind_param('ssss', $nombre, $apellido, $email, $pass_hash);
            if ($stmt->execute()) {
                $stmt->close();
                header('Location: login.php');
                exit;
            } else {
                if ($conexion->errno === 1062) {
                    $error = 'El email ya está registrado.';
                } else {
                    $error = 'Error al registrar: ' . $conexion->error;
                }
                $stmt->close();
            }
        } else {
            $error = 'Error en la consulta: ' . $conexion->error;
        }
    }
}
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Registro</title><link rel="stylesheet" href="../css/styles.css"></head>

<body>

<main class="layout-container">
<h1 style = "margin-left: 15px;">Registro</h1>
    <header><a href="../index.php">Página principal</a></header>
<?php if(!empty($error)) echo '<p class="muted">'.esc($error).'</p>'; ?>
<form method="post" class="form-card">
    <label>Nombre<br><input name="nombre_usuario" type="text" placeholder="Tu nombre" autocomplete="name" required></label>
    <label>Apellido<br><input name="apellido" type="text" placeholder="Tu apellido" autocomplete="family-name" required></label>
    <label>Email<br><input name="email" type="email" placeholder="ejemplo@correo.com" autocomplete="email" required></label>
    <label>Contraseña<br><input name="pass" type="password" placeholder="Contraseña" autocomplete="current-password" required></label>

    <div style="margin-top:12px;">
        <button class="btn btn-primary" type="submit">Ingresar</button>
    </div>
</form>
<p><a href="login.php">¿Ya tenés cuenta? Iniciar sesión</a></p>
</main>
</body>
</html>