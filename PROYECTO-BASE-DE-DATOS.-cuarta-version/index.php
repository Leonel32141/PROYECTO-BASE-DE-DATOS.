<?php include 'includes/conexion.php';
include 'includes/funciones.php'; 

$ranking_query = "SELECT 
    c.id_club,
    c.nombre_club AS Club,
    (r.partidos_ganados + r.partidos_empatados + r.partidos_perdidos) as PJ,
    r.partidos_ganados AS PG,
    r.partidos_empatados AS PE,
    r.partidos_perdidos AS PP,
    r.goles_a_favor AS GF,
    r.goles_encontra AS GC,
    r.diff_gol AS DG,
    (r.partidos_ganados * 3 + r.partidos_empatados) AS Puntos
FROM rankings r
INNER JOIN clubes c ON r.id_club = c.id_club
ORDER BY Puntos DESC, r.diff_gol DESC, r.goles_a_favor DESC";

$ranking_result = $conexion->query($ranking_query);
$ranking_data = [];
if ($ranking_result) {
    while ($row = $ranking_result->fetch_assoc()) {
        $ranking_data[] = $row;
    }
}

// Obtener competiciones
$competiciones_result = $conexion->query("SELECT id_competicion, nombre_competicion FROM competiciones");
$competiciones = [];
if ($competiciones_result) {
    while ($row = $competiciones_result->fetch_assoc()) {
        $competiciones[] = $row;
    }
}

$club_id = isset($_GET['club_id']) ? (int)$_GET['club_id'] : 1;
$mvp_result = $conexion->query("CALL jugador_estrella_de_un_club($club_id)");
$mvp_data = null;
if ($mvp_result) {
    $mvp_data = $mvp_result->fetch_assoc();
    $conexion->next_result();
}


$clubes_result = $conexion->query("SELECT id_club, nombre_club FROM clubes ORDER BY nombre_club");
$clubes = [];
if ($clubes_result) {
    while ($row = $clubes_result->fetch_assoc()) {
        $clubes[] = $row;
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proyecto Fútbol - Tiki-Taka</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <!-- BOTONES DE AUTENTICACIÓN -->
    <div class="auth-buttons-header">
        <a href="auth/login.php" class="btn btn-auth">Iniciar Sesión</a>
        <a href="auth/register.php" class="btn btn-auth btn-secondary">Registrarse</a>
    </div>

    <div class="container">
        <h1>⚽Tiki-Taka⚽</h1>
        <p class="header-subtitle">Sistema de Gestión de Fútbol Profesional</p>

        <div class="section">
            <h2 class="section-title">📊 Tabla de la liga</h2>
            <?php if (!empty($ranking_data)): ?>
                <table>
                    <thead>
                        <tr>
                            <th>Club</th>
                            <th>PJ</th>
                            <th>PG</th>
                            <th>PE</th>
                            <th>PP</th>
                            <th>GF</th>
                            <th>GC</th>
                            <th>DG</th>
                            <th>Puntos</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($ranking_data as $index => $row): ?>
                            <tr>
                                <td><strong><?= ($index + 1) ?></strong>. <a href="club.php?id=<?= $row['id_club'] ?>" style="color: #007bff; text-decoration: none; font-weight: bold; cursor: pointer;"><?= htmlspecialchars($row['Club']) ?></a></td>
                                <td><?= $row['PJ'] ?></td>
                                <td><?= $row['PG'] ?></td>
                                <td><?= $row['PE'] ?></td>
                                <td><?= $row['PP'] ?></td>
                                <td><?= $row['GF'] ?></td>
                                <td><?= $row['GC'] ?></td>
                                <td><?= $row['DG'] ?></td>
                                <td><strong><?= $row['Puntos'] ?></strong></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php else: ?>
                <p class="no-data">No hay datos de ranking disponibles</p>
            <?php endif; ?>
        </div>

        <div class="section">
            <h2 class="section-title">🏆 Competiciones</h2>
            <div class="selector-container">
                <label for="competicion">Seleccionar Competición:</label>
                <select id="competicion" name="competicion">
                    <option value="">-- Todas las competiciones --</option>
                    <?php foreach ($competiciones as $comp): ?>
                        <option value="<?= $comp['id_competicion'] ?>">
                            <?= htmlspecialchars($comp['nombre_competicion']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
                <button onclick="seleccionarCompeticion()">Ver Detalles</button>
            </div>
        </div>

        <div class="section">
            <h2 class="section-title">⭐ Jugador Estrella</h2>
            <div class="selector-container">
                <label for="club">Seleccionar Club:</label>
                <select id="club" name="club">
                    <?php foreach ($clubes as $club): ?>
                        <option value="<?= $club['id_club'] ?>" <?= $club['id_club'] == $club_id ? 'selected' : '' ?>>
                            <?= htmlspecialchars($club['nombre_club']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
                <button onclick="cargarMVP()">Cargar MVP</button>
            </div>

            <?php if ($mvp_data): ?>
                <div class="mvp-card">
                    <h3><?= htmlspecialchars($mvp_data['nombre'] . ' ' . $mvp_data['apellido']) ?></h3>
                    <p style="margin: 5px 0; font-size: 14px;"><?= htmlspecialchars($mvp_data['club']) ?></p>
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
            <?php else: ?>
                <p class="no-data">Selecciona un club para ver su jugador estrella</p>
            <?php endif; ?>
        </div>

        <div class="section">
            <h2 class="section-title">⚙️ Gestión Administrativa</h2>
            <div class="admin-buttons">
                <a href="registrar_partido.php" class="btn btn-admin btn-primary">
                    🏆 Registrar Partido
                </a>
                <a href="intercambio_jugadores.php" class="btn btn-admin btn-secondary">
                    🔄 Intercambio de Jugadores
                </a>
            </div>
        </div>
    </div>

    <script>
        function cargarMVP() {
            const clubId = document.getElementById('club').value;
            if (clubId) {
                window.location.href = '?club_id=' + clubId;
            }
        }

        function seleccionarCompeticion() {
            const competicionId = document.getElementById('competicion').value;
            if (competicionId) {
                window.location.href = 'competicion.php?id=' + competicionId;
            } else {
                alert('Por favor selecciona una competición');
            }
        }
    </script>
</body>
</html>