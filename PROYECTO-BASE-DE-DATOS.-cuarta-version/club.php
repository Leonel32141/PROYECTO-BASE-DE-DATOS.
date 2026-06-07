<?php include 'includes/conexion.php';
include 'includes/funciones.php'; 

// Obtener ID del club
$club_id = isset($_GET['id']) ? (int)$_GET['id'] : 1;

// Obtener información del club
$club_info = $conexion->query("SELECT * FROM clubes WHERE id_club = $club_id");
$club = $club_info->fetch_assoc();

if (!$club) {
    die("Club no encontrado");
}

// Obtener resultados del club
$resultados_result = $conexion->query("CALL obtener_resultados_por_club($club_id)");
$resultados = [];
if ($resultados_result) {
    while ($row = $resultados_result->fetch_assoc()) {
        $resultados[] = $row;
    }
    $conexion->next_result();
}

// Obtener jugadores del club
$jugadores_result = $conexion->query("SELECT id_jugador, nombre, apellido, edad, pais, dorsal, goles, asistencias FROM jugadores WHERE id_club = $club_id ORDER BY apellido");
$jugadores = [];
if ($jugadores_result) {
    while ($row = $jugadores_result->fetch_assoc()) {
        $jugadores[] = $row;
    }
}

// Obtener todos los clubes para el selector
$clubes_result = $conexion->query("SELECT id_club, nombre_club FROM clubes ORDER BY nombre_club");
$clubes = [];
if ($clubes_result) {
    while ($row = $clubes_result->fetch_assoc()) {
        $clubes[] = $row;
    }
}

// Obtener MVP del club
$mvp_result = $conexion->query("CALL jugador_estrella_de_un_club($club_id)");
$mvp_data = null;
if ($mvp_result) {
    $mvp_data = $mvp_result->fetch_assoc();
    $conexion->next_result();
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($club['nombre_club']) ?> - Tiki-Taka</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <!-- BOTONES DE AUTENTICACIÓN -->
    <div class="auth-buttons-header">
        <a href="auth/login.php" class="btn btn-auth">Iniciar Sesión</a>
        <a href="auth/register.php" class="btn btn-auth btn-secondary">Registrarse</a>
    </div>

    <div class="container">
        <div style="margin-bottom: 30px;">
            <a href="index.php" style="display: inline-block; padding: 10px 20px; background-color: #6c757d; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">← Volver al Inicio</a>
        </div>

        <h1>⚽ <?= htmlspecialchars($club['nombre_club']) ?></h1>
        
        <div style="text-align: center; color: #666; margin-bottom: 20px;">
            <p><strong>📍 <?= htmlspecialchars($club['locacion']) ?>, <?= htmlspecialchars($club['pais']) ?></strong></p>
            <p>🏟️ Estadio: <?= htmlspecialchars($club['estadio']) ?></p>
        </div>

        <!-- SELECTOR DE OTRO CLUB -->
        <div class="section">
            <div class="selector-container">
                <label for="club">Ver otro club:</label>
                <select id="club" name="club" onchange="cambiarClub()">
                    <?php foreach ($clubes as $c): ?>
                        <option value="<?= $c['id_club'] ?>" <?= $c['id_club'] == $club_id ? 'selected' : '' ?>>
                            <?= htmlspecialchars($c['nombre_club']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
        </div>

        <!-- MVP DEL CLUB -->
        <?php if ($mvp_data): ?>
            <div class="section">
                <h2 class="section-title">⭐ Jugador Estrella</h2>
                <div class="mvp-card">
                    <h3><?= htmlspecialchars($mvp_data['nombre'] . ' ' . $mvp_data['apellido']) ?></h3>
                    <div class="mvp-info">
                        <div>
                            <strong>Goles</strong>
                            <span><?= $mvp_data['goles'] ?></span>
                        </div>
                        <div>
                            <strong>Asistencias</strong>
                            <span><?= $mvp_data['asistencias'] ?></span>
                        </div>
                        <div>
                            <strong>Rendimiento Total</strong>
                            <span><?= $mvp_data['rendimiento_total'] ?></span>
                        </div>
                    </div>
                </div>
            </div>
        <?php endif; ?>

        <!-- RESULTADOS DEL CLUB -->
        <div class="section">
            <h2 class="section-title">📋 Resultados</h2>
            <?php if (!empty($resultados)): ?>
                <table>
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Instancia</th>
                            <th>Local</th>
                            <th>GL</th>
                            <th>GV</th>
                            <th>Visitante</th>
                            <th>Estadio</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($resultados as $partido): ?>
                            <tr>
                                <td><?= htmlspecialchars($partido['Fecha']) ?></td>
                                <td><?= htmlspecialchars($partido['Instancia']) ?></td>
                                <td><?= htmlspecialchars($partido['Local']) ?></td>
                                <td><strong><?= $partido['GL'] ?></strong></td>
                                <td><strong><?= $partido['GV'] ?></strong></td>
                                <td><?= htmlspecialchars($partido['Visitante']) ?></td>
                                <td><?= htmlspecialchars($partido['Estadio']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php else: ?>
                <p class="no-data">No hay resultados disponibles</p>
            <?php endif; ?>
        </div>

        <!-- PLANTEL DEL CLUB -->
        <div class="section">
            <h2 class="section-title">👥 Plantel</h2>
            <?php if (!empty($jugadores)): ?>
                <table>
                    <thead>
                        <tr>
                            <th>Dorsal</th>
                            <th>Nombre</th>
                            <th>Apellido</th>
                            <th>Edad</th>
                            <th>País</th>
                            <th>Goles</th>
                            <th>Asistencias</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($jugadores as $jugador): ?>
                            <tr>
                                <td><strong><?= $jugador['dorsal'] ?? '-' ?></strong></td>
                                <td><?= htmlspecialchars($jugador['nombre']) ?></td>
                                <td><?= htmlspecialchars($jugador['apellido']) ?></td>
                                <td><?= $jugador['edad'] ?></td>
                                <td><?= htmlspecialchars($jugador['pais']) ?></td>
                                <td><?= $jugador['goles'] ?></td>
                                <td><?= $jugador['asistencias'] ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php else: ?>
                <p class="no-data">No hay jugadores disponibles</p>
            <?php endif; ?>
        </div>
    </div>

    <script>
        function cambiarClub() {
            const clubId = document.getElementById('club').value;
            if (clubId) {
                window.location.href = '?id=' + clubId;
            }
        }
    </script>
</body>
</html>
