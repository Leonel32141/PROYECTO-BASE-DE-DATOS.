<?php
require_once __DIR__ . '/../includes/conexion.php';
require_once __DIR__ . '/../includes/funciones.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = strtolower(trim($_POST['email'] ?? ''));
    $password = trim($_POST['contraseña'] ?? '');

    if ($email === '' || $password === '') {
        $error = "Email y contraseña son obligatorios.";
    } else {
        $stmt = $conexion->prepare("SELECT id, nombre_usuario, contraseña FROM usuarios WHERE email = ? LIMIT 1");
        if ($stmt) {
            $stmt->bind_param('s', $email);
            $stmt->execute();
            $res = $stmt->get_result();
            if ($res && $res->num_rows) {
                $u = $res->fetch_assoc();
                if (empty($u['contraseña']) || !is_string($u['contraseña'])) {
                    $error = "Credenciales inválidas.";
                } else {
                    $ok = password_verify($password, $u['contraseña']);

                    if ($ok) {
                        $_SESSION['id_usuario'] = $u['id'];
                        $_SESSION['usuario'] = $u['nombre_usuario'];
                        header('Location: ../index.php');
                        exit;
                    } else {
                        $error = "Credenciales inválidas.";
                    }
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
    <label>Contraseña<br><input name="contraseña" type="password" placeholder="Contraseña" autocomplete="current-password" required></label>
    <div style="margin-top:12px;">
        <button class="btn btn-primary" type="submit" href="/index.php">Ingresar</button>
    </div>
</form>
<p><a href="register.php">Crear cuenta</a></p>
</main>
</body>
</html>