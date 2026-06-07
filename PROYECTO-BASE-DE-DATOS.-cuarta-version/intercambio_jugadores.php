<?php
include 'includes/conexion.php';
include 'includes/funciones.php';

$mensaje = '';
$error = '';

// Obtener clubes
$clubes_result = $conexion->query("SELECT id_club, nombre_club FROM clubes ORDER BY nombre_club");
$clubes = [];
if ($clubes_result) {
    while ($row = $clubes_result->fetch_assoc()) {
        $clubes[] = $row;
    }
}

$jugadores = [];
$jugadores_club1 = [];
$jugadores_club2 = [];

// Obtener jugadores si se selecciona un club
if ($_GET['club1'] ?? false) {
    $club_id = (int)$_GET['club1'];
    $result = $conexion->query("SELECT id_jugador, nombre, apellido, dorsal FROM jugadores WHERE id_club = $club_id ORDER BY apellido");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $jugadores_club1[] = $row;
        }
    }
}

if ($_GET['club2'] ?? false) {
    $club_id = (int)$_GET['club2'];
    $result = $conexion->query("SELECT id_jugador, nombre, apellido, dorsal FROM jugadores WHERE id_club = $club_id ORDER BY apellido");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $jugadores_club2[] = $row;
        }
    }
}

// Procesar intercambio
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id_jugador1 = (int)$_POST['id_jugador1'] ?? 0;
    $id_jugador2 = (int)$_POST['id_jugador2'] ?? 0;
    $id_nuevo_club_jugador1 = (int)$_POST['club2'] ?? 0;
    $id_nuevo_club_jugador2 = (int)$_POST['club1'] ?? 0;

    // Validaciones
    if ($id_jugador1 === 0 || $id_jugador2 === 0) {
        $error = "Debes seleccionar ambos jugadores.";
    } elseif ($id_nuevo_club_jugador1 === 0 || $id_nuevo_club_jugador2 === 0) {
        $error = "Debes seleccionar ambos clubes.";
    } else {
        // Obtener información de jugadores
        $j1_result = $conexion->query("SELECT nombre, apellido FROM jugadores WHERE id_jugador = $id_jugador1");
        $j1 = $j1_result->fetch_assoc();
        
        $j2_result = $conexion->query("SELECT nombre, apellido FROM jugadores WHERE id_jugador = $id_jugador2");
        $j2 = $j2_result->fetch_assoc();

        // Llamar al stored procedure
        $stmt = $conexion->prepare("CALL realizar_intercambio_jugadores(?, ?, ?, ?)");
        if ($stmt) {
            $stmt->bind_param('iiii', $id_jugador1, $id_jugador2, $id_nuevo_club_jugador1, $id_nuevo_club_jugador2);
            
            if ($stmt->execute()) {
                $mensaje = "✅ Intercambio realizado: " . htmlspecialchars($j1['nombre'] . ' ' . $j1['apellido']) . " ↔ " . htmlspecialchars($j2['nombre'] . ' ' . $j2['apellido']);
                $jugadores_club1 = [];
                $jugadores_club2 = [];
            } else {
                $error = "Error al registrar: " . $conexion->error;
            }
            $stmt->close();
        } else {
            $error = "Error en la consulta: " . $conexion->error;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Intercambio de Jugadores - Tiki-Taka</title>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .form-container {
            max-width: 700px;
            margin: 30px auto;
            background: linear-gradient(135deg, rgba(20, 20, 30, 0.7), rgba(30, 30, 50, 0.7));
            backdrop-filter: blur(10px);
            padding: 40px;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            color: #ffffff;
            font-weight: 700;
            margin-bottom: 8px;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.05em;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid rgba(31, 255, 76, 0.3);
            border-radius: 8px;
            background-color: rgba(20, 20, 30, 0.8);
            color: #ffffff;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #1fff4c;
            box-shadow: 0 0 15px rgba(31, 255, 76, 0.3);
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .exchange-section {
            background: rgba(102, 126, 234, 0.15);
            padding: 20px;
            border-radius: 10px;
            border: 1px solid rgba(102, 126, 234, 0.3);
            margin-bottom: 20px;
        }
        
        .exchange-title {
            color: #667eea;
            font-weight: 700;
            margin-bottom: 15px;
            text-transform: uppercase;
            font-size: 13px;
            letter-spacing: 0.05em;
        }
        
        .mensaje {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 600;
        }
        
        .mensaje.success {
            background: rgba(31, 255, 76, 0.2);
            color: #1fff4c;
            border: 1px solid rgba(31, 255, 76, 0.5);
        }
        
        .mensaje.error {
            background: rgba(255, 68, 68, 0.2);
            color: #ff4444;
            border: 1px solid rgba(255, 68, 68, 0.5);
        }
        
        .btn-submit {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            border: none;
            border-radius: 8px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
        }
        
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 28px rgba(102, 126, 234, 0.5);
        }
        
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            padding: 10px 20px;
            background-color: #6c757d;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-weight: 700;
        }
        
        .back-link:hover {
            background-color: #5a6268;
        }
        
        .load-btn {
            background: linear-gradient(135deg, #1fff4c 0%, #00ff88 100%);
            color: #000;
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 11px;
            margin-top: 10px;
        }
        
        .load-btn:hover {
            transform: translateY(-1px);
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="index.php" class="back-link">← Volver al Inicio</a>
        
        <h1>🔄 Intercambio de Jugadores</h1>
        
        <div class="form-container">
            <?php if (!empty($mensaje)): ?>
                <div class="mensaje success"><?= htmlspecialchars($mensaje) ?></div>
            <?php endif; ?>
            
            <?php if (!empty($error)): ?>
                <div class="mensaje error"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>
            
            <form method="POST">
                <!-- Club 1 -->
                <div class="exchange-section">
                    <div class="exchange-title">👥 Club 1 (Jugador A)</div>
                    
                    <div class="form-group">
                        <label for="club1">Seleccionar Club</label>
                        <select id="club1" name="club1" onchange="document.location.href='?club1='+this.value+'&club2=<?php echo $_GET['club2'] ?? 0; ?>'">
                            <option value="">Seleccionar...</option>
                            <?php foreach ($clubes as $club): ?>
                                <option value="<?= $club['id_club'] ?>" <?= ($_GET['club1'] ?? 0) == $club['id_club'] ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($club['nombre_club']) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <?php if (!empty($jugadores_club1)): ?>
                        <div class="form-group">
                            <label for="id_jugador1">Seleccionar Jugador</label>
                            <select id="id_jugador1" name="id_jugador1" required>
                                <option value="">Seleccionar...</option>
                                <?php foreach ($jugadores_club1 as $j): ?>
                                    <option value="<?= $j['id_jugador'] ?>">
                                        #<?= $j['dorsal'] ?? '-' ?> - <?= htmlspecialchars($j['nombre'] . ' ' . $j['apellido']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    <?php endif; ?>
                </div>
                
                <!-- Club 2 -->
                <div class="exchange-section">
                    <div class="exchange-title">👥 Club 2 (Jugador B)</div>
                    
                    <div class="form-group">
                        <label for="club2">Seleccionar Club</label>
                        <select id="club2" name="club2" onchange="document.location.href='?club1=<?php echo $_GET['club1'] ?? 0; ?>&club2='+this.value">
                            <option value="">Seleccionar...</option>
                            <?php foreach ($clubes as $club): ?>
                                <option value="<?= $club['id_club'] ?>" <?= ($_GET['club2'] ?? 0) == $club['id_club'] ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($club['nombre_club']) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <?php if (!empty($jugadores_club2)): ?>
                        <div class="form-group">
                            <label for="id_jugador2">Seleccionar Jugador</label>
                            <select id="id_jugador2" name="id_jugador2" required>
                                <option value="">Seleccionar...</option>
                                <?php foreach ($jugadores_club2 as $j): ?>
                                    <option value="<?= $j['id_jugador'] ?>">
                                        #<?= $j['dorsal'] ?? '-' ?> - <?= htmlspecialchars($j['nombre'] . ' ' . $j['apellido']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    <?php endif; ?>
                </div>
                
                <?php if (!empty($jugadores_club1) && !empty($jugadores_club2)): ?>
                    <button type="submit" class="btn-submit">Realizar Intercambio</button>
                <?php endif; ?>
            </form>
        </div>
    </div>
</body>
</html>
