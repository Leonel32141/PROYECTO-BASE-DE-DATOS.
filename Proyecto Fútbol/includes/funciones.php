<?php


if (session_status() === PHP_SESSION_NONE) {
    session_start();
}


function verificarSesion() {
    if (!isset($_SESSION['id_usuario'])) {
        header("Location: ../auth/login.php");
        exit;
    }
}
if (!function_exists('esc')) {

    function esc($s) {
        return htmlspecialchars($s ?? '', ENT_QUOTES, 'UTF-8');
    }
}
?>