<?php include 'includes/conexion.php';
include 'includes/funciones.php'; 

// Obtener ID de competición
$competicion_id = isset($_GET['id']) ? (int)$_GET['id'] : 1;

// Obtener información de la competición
$comp_info = $conexion->query("SELECT * FROM competiciones WHERE id_competicion = $competicion_id");
$competicion = $comp_info->fetch_assoc();

// Obtener resultados por competición
$resultados_result = $conexion->query("CALL obtener_resultados_por_competicion($competicion_id)");
$resultados = [];
if ($resultados_result) {
    while ($row = $resultados_result->fetch_assoc()) {
        $resultados[] = $row;
    }
    $conexion->next_result();
}

// Obtener todas las competiciones para el selector
$competiciones_result = $conexion->query("SELECT id_competicion, nombre_competicion FROM competiciones");
$competiciones = [];
if ($competiciones_result) {
    while ($row = $competiciones_result->fetch_assoc()) {
        $competiciones[] = $row;
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($competicion['nombre_competicion'] ?? 'Competición') ?> - Tiki-Taka</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <div class="container">
        <div style="margin-bottom: 30px; text-align: right;">
            <a href="index.php" style="display: inline-block; padding: 10px 20px; background-color: #6c757d; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">← Volver al Inicio</a>
        </div>

        <h1>🏆 <?= htmlspecialchars($competicion['nombre_competicion'] ?? 'Competición') ?></h1>
        
        <div class="section">
            <div class="selector-container">
                <label for="competicion">Seleccionar otra Competición:</label>
                <select id="competicion" name="competicion" onchange="cambiarCompeticion()">
                    <?php foreach ($competiciones as $comp): ?>
                        <option value="<?= $comp['id_competicion'] ?>" <?= $comp['id_competicion'] == $competicion_id ? 'selected' : '' ?>>
                            <?= htmlspecialchars($comp['nombre_competicion']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
        </div>

        <div class="section">
            <h2 class="section-title">📋 Partidos</h2>
            <?php if (!empty($resultados)): ?>
                <table>
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Torneo</th>
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
                                <td><?= htmlspecialchars($partido['Torneo']) ?></td>
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
                <p class="no-data">No hay partidos disponibles para esta competición</p>
            <?php endif; ?>
        </div>
    </div>

    <script>
        function cambiarCompeticion() {
            const competicionId = document.getElementById('competicion').value;
            if (competicionId) {
                window.location.href = '?id=' + competicionId;
            }
        }
    </script>
</body>
</html>
