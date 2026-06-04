<?php
require_once __DIR__ . '/../includes/conexion.php';
require_once __DIR__ . '/../includes/funciones.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $password = $_POST['pass'] ?? '';
    $email = $_POST['email'] ?? '';

    

    if ($email === '' || $password === '') {
        $error = "Email y contraseña son obligatorios.";
    } else {
        // Consultar usuario
        $stmt = $conexion->prepare("SELECT id, nombre_usuario, email, pass FROM usuarios WHERE email = ? LIMIT 1");
        if ($stmt) {
            $stmt->bind_param('s', $email);
            $stmt->execute();
            $res = $stmt->get_result();
            
            if ($res && $res->num_rows > 0) {
                $usuario = $res->fetch_assoc();
                
                if (password_verify($password, $usuario['pass'])) {
                    $_SESSION['id_usuario'] = $usuario['id'];
                    $_SESSION['usuario'] = $usuario['nombre_usuario'];
                    header('Location: ../index.php');
                    exit;
                } else {
                    $error = "Contraseña incorrecta.";
                }
            } else {
                $error = "Usuario no encontrado.";
            }
            $stmt->close();
        } else {
            $error = "Error en la consulta: " . $conexion->error;
        }
    }
}
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Login</title><link rel="stylesheet" href="../css/styles.css"></head>

<body>
<main class="layout-container">

<h1 style="margin-left: 15px;">Ingresar</h1>
<header><a href="../index.php">Página principal</a></header>
<?php if(!empty($error)) echo '<p class="muted">'.esc($error).'</p>'; ?>
<form method="post" class="form-card">
    <label>Email<br><input name="email" type="email" placeholder="ejemplo@correo.com" autocomplete="email" required></label>
    <label>Contraseña<br><input name="pass" type="password" placeholder="Contraseña" autocomplete="current-password" required></label>
    <div style="margin-top:12px;">
        <button class="btn btn-primary" type="submit">Ingresar</button>
    </div>
</form>
<p><a href="register.php">Crear cuenta</a></p>
</main>
</body>
</html>