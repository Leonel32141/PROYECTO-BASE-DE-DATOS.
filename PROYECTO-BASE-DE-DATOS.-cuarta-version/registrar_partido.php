<?php
include 'includes/conexion.php';
include 'includes/funciones.php';

$mensaje = '';
$error = '';

// Obtener competiciones, clubes
$competiciones_result = $conexion->query("SELECT id_competicion, nombre_competicion FROM competiciones");
$competiciones = [];
if ($competiciones_result) {
    while ($row = $competiciones_result->fetch_assoc()) {
        $competiciones[] = $row;
    }
}

$clubes_result = $conexion->query("SELECT id_club, nombre_club FROM clubes ORDER BY nombre_club");
$clubes = [];
if ($clubes_result) {
    while ($row = $clubes_result->fetch_assoc()) {
        $clubes[] = $row;
    }
}

// Procesar formulario
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id_L = (int)$_POST['id_club_local'] ?? 0;
    $id_V = (int)$_POST['id_club_visitante'] ?? 0;
    $golesL = (int)$_POST['goles_local'] ?? 0;
    $golesV = (int)$_POST['goles_visitante'] ?? 0;
    $id_comp = (int)$_POST['id_competicion'] ?? 0;
    $instancia = trim($_POST['instancia'] ?? '');
    $estadio = trim($_POST['estadio'] ?? '');

    // Validaciones
    if ($id_L === 0 || $id_V === 0) {
        $error = "Debes seleccionar ambos clubes.";
    } elseif ($id_L === $id_V) {
        $error = "Los clubes deben ser diferentes.";
    } elseif ($id_comp === 0) {
        $error = "Debes seleccionar una competición.";
    } elseif ($golesL < 0 || $golesV < 0) {
        $error = "Los goles no pueden ser negativos.";
    } elseif (empty($instancia)) {
        $error = "La instancia es obligatoria.";
    } elseif (empty($estadio)) {
        $error = "El estadio es obligatorio.";
    } else {
        // Llamar al stored procedure
        $stmt = $conexion->prepare("CALL registrar_partido_y_resultado(?, ?, ?, ?, ?, ?, ?)");
        if ($stmt) {
            $stmt->bind_param('iiiiiss', $id_L, $id_V, $golesL, $golesV, $id_comp, $instancia, $estadio);
            
            if ($stmt->execute()) {
                $mensaje = "✅ Partido registrado correctamente y rankings actualizados.";
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
    <title>Registrar Partido - Tiki-Taka</title>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .form-container {
            max-width: 600px;
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
            background: linear-gradient(135deg, #1fff4c 0%, #00ff88 100%);
            color: #000;
            border: none;
            border-radius: 8px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 8px 20px rgba(31, 255, 76, 0.3);
        }
        
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 28px rgba(31, 255, 76, 0.5);
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
    </style>
</head>
<body>
    <div class="container">
        <a href="index.php" class="back-link">← Volver al Inicio</a>
        
        <h1>🏆 Registrar Partido</h1>
        
        <div class="form-container">
            <?php if (!empty($mensaje)): ?>
                <div class="mensaje success"><?= htmlspecialchars($mensaje) ?></div>
            <?php endif; ?>
            
            <?php if (!empty($error)): ?>
                <div class="mensaje error"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>
            
            <form method="POST">
                <div class="form-row">
                    <div class="form-group">
                        <label for="id_club_local">Club Local *</label>
                        <select id="id_club_local" name="id_club_local" required>
                            <option value="">Seleccionar...</option>
                            <?php foreach ($clubes as $club): ?>
                                <option value="<?= $club['id_club'] ?>">
                                    <?= htmlspecialchars($club['nombre_club']) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="id_club_visitante">Club Visitante *</label>
                        <select id="id_club_visitante" name="id_club_visitante" required>
                            <option value="">Seleccionar...</option>
                            <?php foreach ($clubes as $club): ?>
                                <option value="<?= $club['id_club'] ?>">
                                    <?= htmlspecialchars($club['nombre_club']) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="goles_local">Goles Local *</label>
                        <input type="number" id="goles_local" name="goles_local" min="0" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="goles_visitante">Goles Visitante *</label>
                        <input type="number" id="goles_visitante" name="goles_visitante" min="0" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="id_competicion">Competición *</label>
                    <select id="id_competicion" name="id_competicion" required>
                        <option value="">Seleccionar...</option>
                        <?php foreach ($competiciones as $comp): ?>
                            <option value="<?= $comp['id_competicion'] ?>">
                                <?= htmlspecialchars($comp['nombre_competicion']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="instancia">Instancia *</label>
                    <input type="text" id="instancia" name="instancia" placeholder="Ej: Fase de Grupos, Octavos, Final" required>
                </div>
                
                <div class="form-group">
                    <label for="estadio">Estadio *</label>
                    <input type="text" id="estadio" name="estadio" placeholder="Nombre del estadio" required>
                </div>
                
                <button type="submit" class="btn-submit">Registrar Partido</button>
            </form>
        </div>
    </div>
</body>
</html>
