-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3307
-- Tiempo de generación: 09-05-2026 a las 22:25:09
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `proyectofutbol`
--
CREATE DATABASE IF NOT EXISTS `proyectofutbol` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `proyectofutbol`;
DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `jugador_estrella_de_un_club` (IN `club_id` INT)   BEGIN
    SELECT  nombre_club as club, nombre, apellido, goles, asistencias, (goles + asistencias) AS rendimiento_total
    FROM  jugadores j
    inner join clubes c
    on c.id_club = j.id_club 
    WHERE j.id_club = club_id
    ORDER BY rendimiento_total DESC
    LIMIT 1;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrar_historial` ()   BEGIN
    SELECT
        p.fecha_hora AS 'Fecha',
        p.instancia_partido AS 'Instancia',
        c1.nombre_club AS 'Equipo Local',
        p.Gol_local AS 'GL',
        p.Gol_visitante AS 'GV',
        c2.nombre_club AS 'Equipo Visitante',
        p.estadio AS 'Estadio'
    FROM partidos p
    INNER JOIN clubes c1 ON p.id_clubLocal = c1.id_club
    INNER JOIN clubes c2 ON p.id_clubVisitante = c2.id_club
    ORDER BY p.fecha_hora DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrar_ranking_clubes` ()   BEGIN
    SELECT 
        c.nombre_club AS Club,
(r.partidos_ganados + r.partidos_empatados +  r.partidos_perdidos) as PJ,
        r.partidos_ganados AS PG,
        r.partidos_empatados AS PE,
        r.partidos_perdidos AS PP,
        r.goles_a_favor AS GF,
        r.goles_encontra AS GC,
        r.diff_gol AS DG,
        (r.partidos_ganados * 3 + r.partidos_empatados) AS Puntos
    FROM rankings r
    INNER JOIN clubes c ON r.id_club = c.id_club
    ORDER BY Puntos DESC, r.diff_gol DESC, r.goles_a_favor DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_informacion_jugadores` ()   BEGIN
   
SELECT nombre, apellido,nombre_club,posicion FROM jugadores
INNER JOIN posiciones
ON posiciones.id_jugador = jugadores.id_jugador
INNER JOIN clubes
ON clubes.id_club = jugadores.id_club;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_resultados_por_club` (IN `club_id` INT)   BEGIN
    SELECT p.fecha_hora AS Fecha,p.instancia_partido AS Instancia,c1.nombre_club AS Local,p.Gol_local AS 'GL',p.Gol_visitante AS 'GV',c2.nombre_club AS Visitante, p.estadio AS Estadio
    FROM partidos p
    INNER JOIN clubes c1 ON p.id_clubLocal = c1.id_club
    INNER JOIN clubes c2 ON p.id_clubVisitante = c2.id_club
    WHERE p.id_clubLocal = club_id OR p.id_clubVisitante = club_id
    ORDER BY p.fecha_hora DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_resultados_por_competicion` (IN `p_id_competicion` INT)   BEGIN
    SELECT 
        p.fecha_hora AS 'Fecha',
        comp.nombre_competicion AS 'Torneo',
        p.instancia_partido AS 'Instancia',
        c1.nombre_club AS 'Local',
        p.Gol_local AS 'GL',
        p.Gol_visitante AS 'GV',
        c2.nombre_club AS 'Visitante',
        p.estadio AS 'Estadio'
    FROM partidos p
    INNER JOIN competiciones comp ON p.id_competicion = comp.id_competicion
    INNER JOIN clubes c1 ON p.id_clubLocal = c1.id_club
    INNER JOIN clubes c2 ON p.id_clubVisitante = c2.id_club
    WHERE p.id_competicion = p_id_competicion
    ORDER BY p.fecha_hora DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `realizar_intercambio_jugadores` (IN `p_id_jugador1` INT, IN `p_id_jugador2` INT, IN `p_id_nuevo_club_jugador1` INT, IN `p_id_nuevo_club_jugador2` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE jugadores 
    SET id_club = p_id_nuevo_club_jugador1 
    WHERE id_jugador = p_id_jugador1; 

    UPDATE jugadores 
    SET id_club = p_id_nuevo_club_jugador2
    WHERE id_jugador = p_id_jugador2;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_partido_y_resultado` (IN `p_id_L` INT, IN `p_id_V` INT, IN `p_golesL` INT, IN `p_golesV` INT, IN `p_id_comp` INT, IN `p_instancia` VARCHAR(50), IN `p_estadio` VARCHAR(100))   BEGIN
  
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO partidos (
        id_clubLocal, id_clubVisitante, Gol_local, Gol_visitante, 
        id_competicion, instancia_partido, estadio, fecha_hora
    ) VALUES (
        p_id_L, p_id_V, p_golesL, p_golesV, 
        p_id_comp, p_instancia, p_estadio, NOW()
    );

    UPDATE rankings 
    SET 
        goles_a_favor = goles_a_favor + p_golesL,
        goles_encontra = goles_encontra + p_golesV,
        diff_gol = (goles_a_favor + p_golesL) - (goles_encontra + p_golesV),
        partidos_ganados = partidos_ganados + CASE WHEN p_golesL > p_golesV THEN 1 ELSE 0 END,
        partidos_empatados = partidos_empatados + CASE WHEN p_golesL = p_golesV THEN 1 ELSE 0 END,
        partidos_perdidos = partidos_perdidos + CASE WHEN p_golesL < p_golesV THEN 1 ELSE 0 END
    WHERE id_club = p_id_L;

    UPDATE rankings 
    SET 
        goles_a_favor = goles_a_favor + p_golesV,
        goles_encontra = goles_encontra + p_golesL,
        diff_gol = (goles_a_favor + p_golesV) - (goles_encontra + p_golesL),
        partidos_ganados = partidos_ganados + CASE WHEN p_golesV > p_golesL THEN 1 ELSE 0 END,
        partidos_empatados = partidos_empatados + CASE WHEN p_golesV = p_golesL THEN 1 ELSE 0 END,
        partidos_perdidos = partidos_perdidos + CASE WHEN p_golesV < p_golesL THEN 1 ELSE 0 END
    WHERE id_club = p_id_V;

    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clubes`
--

CREATE TABLE `clubes` (
  `id_club` int(11) UNSIGNED NOT NULL,
  `nombre_club` varchar(40) NOT NULL,
  `pais` varchar(30) NOT NULL,
  `locacion` varchar(40) NOT NULL,
  `estadio` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clubes`
--

INSERT INTO `clubes` (`id_club`, `nombre_club`, `pais`, `locacion`, `estadio`) VALUES
(1, 'River Plate', 'Argentina', 'Buenos Aires', 'El Monumental'),
(2, 'Boca Juniors', 'Argentina', 'Buenos Aires', 'La Bombonera'),
(3, 'Independiente', 'Argentina', 'Avellaneda', 'Libertadores de America'),
(4, 'Racing Club', 'Argentina', 'Avellaneda', 'Cilindro Avellaneda'),
(5, 'San Lorenzo', 'Argentina', 'Buenos Aires', 'Nuevo Gasometro'),
(6, 'Estudiantes LP', 'Argentina', 'La Plata', 'Estadio UNO'),
(7, 'Velez Sarsfield', 'Argentina', 'Buenos Aires', 'Jose Amalfitani'),
(8, 'Huracan', 'Argentina', 'Buenos Aires', 'Tomas A. Duco'),
(9, 'Argentinos Jrs', 'Argentina', 'Buenos Aires', 'Diego A. Maradona'),
(10, 'Lanus', 'Argentina', 'Lanus', 'La Fortaleza'),
(11, 'Banfield', 'Argentina', 'Banfield', 'Florencio Sola'),
(12, 'Deportivo Riestra', 'Argentina', 'Buenos Aires', 'Guillermo Laza'),
(13, 'Deportivo Moron', 'Argentina', 'Moron', 'Nuevo F. Urbano'),
(14, 'Colon', 'Argentina', 'Santa Fe', 'Brigadier Lopez'),
(15, 'Nueva Chicago', 'Argentina', 'Buenos Aires', 'Rep. de Mataderos'),
(16, 'Godoy Cruz', 'Argentina', 'Mendoza', 'Malvinas Argentinas'),
(17, 'Almirante Brown', 'Argentina', 'San Justo', 'Fragata Sarmiento'),
(18, 'Chacarita Jrs', 'Argentina', 'San Martin', 'Chacarita Juniors'),
(19, 'Ferro Carril Oeste', 'Argentina', 'Buenos Aires', 'Ricardo Etcheverri'),
(20, 'Atlanta', 'Argentina', 'Buenos Aires', 'Don Leon Kolbowski');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `competiciones`
--

CREATE TABLE `competiciones` (
  `id_competicion` int(10) UNSIGNED NOT NULL,
  `nombre_competicion` varchar(30) NOT NULL,
  `formato` varchar(30) NOT NULL,
  `instancia` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `competiciones`
--

INSERT INTO `competiciones` (`id_competicion`, `nombre_competicion`, `formato`, `instancia`) VALUES
(1, 'Liga Profesional', 'liga', 'Temporada 2026/27'),
(2, 'Copa Argentina', 'torneo', 'Edicion 2026');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jugadores`
--

CREATE TABLE `jugadores` (
  `id_jugador` int(11) UNSIGNED NOT NULL,
  `id_club` int(11) UNSIGNED NOT NULL,
  `nombre` varchar(20) NOT NULL,
  `apellido` varchar(20) NOT NULL,
  `edad` int(3) UNSIGNED NOT NULL,
  `pais` varchar(20) NOT NULL,
  `dorsal` int(11) DEFAULT NULL,
  `goles` int(11) UNSIGNED NOT NULL,
  `asistencias` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `jugadores`
--

INSERT INTO `jugadores` (`id_jugador`, `id_club`, `nombre`, `apellido`, `edad`, `pais`, `dorsal`, `goles`, `asistencias`) VALUES
(1, 1, 'Franco', 'Armani', 39, 'Argentina', 1, 0, 0),
(2, 1, 'Gonzalo', 'Montiel', 29, 'Argentina', 29, 7, 4),
(3, 1, 'Aníbal', 'Moreno', 26, 'Argentina', 6, 2, 3),
(4, 1, 'Juan Fernando', 'Quintero', 33, 'Colombia', 10, 13, 10),
(5, 1, 'Sebastián', 'Driussi', 30, 'Argentina', 9, 17, 4),
(6, 2, 'Agustín', 'Marchesín', 38, 'Argentina', 1, 0, 0),
(7, 2, 'Leandro', 'Paredes', 31, 'Argentina', 5, 7, 7),
(8, 2, 'Santiago', 'Ascacíbar', 29, 'Argentina', 25, 4, 2),
(9, 2, 'Tomas', 'Aranda', 18, 'Argentina', 36, 10, 9),
(10, 2, 'Adam', 'Bareiro', 29, 'Paraguay', 28, 15, 1),
(11, 3, 'Rodrigo', 'Rey', 35, 'Argentina', 33, 0, 0),
(12, 3, 'Kevin', 'Lomónaco', 24, 'Argentina', 26, 0, 1),
(13, 3, 'Matías', 'Abaldo', 22, 'Uruguay', 19, 0, 8),
(14, 3, 'Santiago', 'Montiel', 23, 'Argentina', 7, 3, 5),
(15, 3, 'Gabriel', 'Ávalos', 35, 'Paraguay', 9, 14, 2),
(16, 4, 'Facundo', 'Cambeses', 29, 'Argentina', 25, 0, 0),
(17, 4, 'Gabriel', 'Rojas', 28, 'Argentina', 27, 1, 11),
(18, 4, 'Santiago', 'Sosa', 26, 'Argentina', 13, 3, 7),
(19, 4, 'Duván', 'Vergara', 29, 'Colombia', 7, 8, 3),
(20, 4, 'Adrián', 'Martínez', 33, 'Argentina', 9, 10, 0),
(21, 5, 'Orlando', 'Gill', 25, 'Paraguay', 12, 0, 0),
(22, 5, 'Jhohan', 'Romaña', 27, 'Colombia', 4, 2, 0),
(23, 5, 'Nicolás', 'Tripichio', 30, 'Argentina', 24, 1, 9),
(24, 5, 'Alexis', 'Cuello', 26, 'Argentina', 9, 7, 3),
(25, 5, 'Rodrigo', 'Auzmendi', 25, 'Argentina', 29, 8, 1),
(26, 6, 'Fernando', 'Muslera', 39, 'Uruguay', 1, 0, 0),
(27, 6, 'Leandro', 'González Pirez', 34, 'Argentina', 14, 0, 0),
(28, 6, 'Adolfo', 'Gaich', 27, 'Argentina', 29, 1, 5),
(29, 6, 'Guido', 'Carrillo', 34, 'Argentina', 9, 8, 1),
(30, 6, 'Edwin', 'Cetré', 28, 'Colombia', 18, 5, 7),
(31, 7, 'Alvaro', 'Montero', 31, 'Colombia', 12, 0, 0),
(32, 7, 'Manuel', 'Lanzini', 33, 'Argentina', 22, 1, 9),
(33, 7, 'Braian', 'Romero', 34, 'Argentina', 9, 14, 0),
(34, 7, 'Imanol', 'Machuca', 26, 'Argentina', 7, 5, 5),
(35, 7, 'Lucas', 'Robertone', 29, 'Argentina', 8, 1, 6),
(36, 8, 'Hernán', 'Galíndez', 39, 'Ecuador', 1, 0, 0),
(37, 8, 'Leonardo', 'Gil', 34, 'Argentina', 5, 1, 2),
(38, 8, 'Lucas', 'Blondel', 29, 'Suiza', 4, 1, 7),
(39, 8, 'Juan', 'Bisanz', 24, 'Argentina', 10, 2, 2),
(40, 8, 'Jordi', 'Caicedo', 28, 'Ecuador', 9, 9, 1),
(41, 9, 'Sergio', 'Romero', 39, 'Argentina', 1, 0, 0),
(42, 9, 'Enzo', 'Pérez', 40, 'Argentina', 33, 0, 0),
(43, 9, 'Alan', 'Lescano', 24, 'Argentina', 10, 4, 4),
(44, 9, 'Ryoga', 'Kida', 20, 'Japón', 34, 1, 0),
(45, 9, 'Hernán', 'López Muñoz', 25, 'Argentina', 23, 7, 8),
(46, 10, 'Nahuel', 'Losada', 32, 'Argentina', 26, 0, 0),
(47, 10, 'Carlos', 'Izquierdoz', 37, 'Argentina', 2, 1, 0),
(48, 10, 'Marcelino', 'Moreno', 31, 'Argentina', 10, 6, 12),
(49, 10, 'José María', 'Canale', 29, 'Paraguay', 3, 3, 1),
(50, 10, 'Dylan', 'Aquino', 19, 'Argentina', 11, 12, 8),
(51, 11, 'Facundo', 'Sanguinetti', 25, 'Argentina', 1, 0, 0),
(52, 11, 'Aaron', 'Quirós', 24, 'Argentina', 3, 2, 1),
(53, 11, 'Gerónimo', 'Rivera', 22, 'Argentina', 20, 6, 5),
(54, 11, 'Matías', 'González', 24, 'Argentina', 10, 4, 7),
(55, 11, 'Bruno', 'Sepúlveda', 33, 'Argentina', 9, 9, 2),
(56, 12, 'Ignacio', 'Arce', 34, 'Argentina', 1, 0, 0),
(57, 12, 'Pedro', 'Ramírez', 26, 'Argentina', 4, 1, 3),
(58, 12, 'Milton', 'Céliz', 33, 'Argentina', 7, 5, 4),
(59, 12, 'Brian', 'Sánchez', 32, 'Argentina', 10, 3, 5),
(60, 12, 'Jonathan', 'Herrera', 34, 'Argentina', 9, 9, 1),
(61, 13, 'Juan', 'Rojas', 28, 'Argentina', 1, 0, 0),
(62, 13, 'Agustín', 'Gómez', 30, 'Argentina', 2, 1, 0),
(63, 13, 'Gastón', 'González', 38, 'Argentina', 10, 2, 4),
(64, 13, 'Santiago', 'Sala', 24, 'Argentina', 7, 5, 3),
(65, 13, 'Matías', 'Romero', 30, 'Argentina', 9, 7, 1),
(66, 14, 'Manuel', 'Vicentini', 35, 'Argentina', 1, 0, 0),
(67, 14, 'Facundo', 'Castet', 27, 'Argentina', 3, 1, 4),
(68, 14, 'Sebastián', 'Prediger', 39, 'Argentina', 5, 0, 2),
(69, 14, 'Christian', 'Bernardi', 36, 'Argentina', 10, 4, 6),
(70, 14, 'Genaro', 'Rossi', 23, 'Argentina', 9, 7, 1),
(71, 15, 'Facundo', 'Ferrero', 30, 'Argentina', 1, 0, 0),
(72, 15, 'Stefano', 'Callegari', 29, 'Argentina', 2, 2, 0),
(73, 15, 'Maximiliano', 'Amarfil', 24, 'Argentina', 5, 1, 3),
(74, 15, 'Evelio', 'Cardozo', 25, 'Argentina', 10, 4, 7),
(75, 15, 'Ivan', 'Maggi', 26, 'Argentina', 9, 9, 2),
(76, 16, 'Franco', 'Petroli', 27, 'Argentina', 1, 0, 0),
(77, 16, 'Pier', 'Barrios', 35, 'Argentina', 2, 2, 1),
(78, 16, 'Bruno', 'Leyes', 24, 'Argentina', 5, 1, 4),
(79, 16, 'Gonzalo', 'Abrego', 26, 'Argentina', 32, 5, 6),
(80, 16, 'Salomón', 'Rodríguez', 26, 'Uruguay', 19, 10, 2),
(81, 17, 'Ramiro', 'Martínez', 34, 'Argentina', 1, 1, 0),
(82, 17, 'Ulises', 'Abreliano', 28, 'Argentina', 4, 1, 3),
(83, 17, 'Santiago', 'Vera', 27, 'Argentina', 10, 5, 5),
(84, 17, 'Leandro', 'Iglesias', 25, 'Argentina', 8, 4, 4),
(85, 17, 'Samuel', 'Portillo', 31, 'Paraguay', 9, 6, 1),
(86, 18, 'Federico', 'Losas', 24, 'Argentina', 1, 0, 0),
(87, 18, 'Sebastián', 'Álvarez', 28, 'Argentina', 2, 1, 0),
(88, 18, 'Nicolás', 'Watson', 27, 'Argentina', 5, 2, 2),
(89, 18, 'Claudio', 'Pombo', 32, 'Argentina', 10, 4, 6),
(90, 18, 'Rodrigo', 'Salinas', 39, 'Argentina', 9, 7, 1),
(91, 19, 'Mariano', 'Monllor', 37, 'Argentina', 1, 0, 0),
(92, 19, 'Nahuel', 'Arena', 27, 'Argentina', 2, 4, 1),
(93, 19, 'Nicolás', 'Gómez', 30, 'Argentina', 5, 1, 4),
(94, 19, 'Ricardo', 'Blanco', 35, 'Argentina', 10, 6, 9),
(95, 19, 'Mateo', 'Levato', 30, 'Argentina', 9, 8, 2),
(96, 20, 'Bruno', 'Galván', 31, 'Argentina', 1, 0, 0),
(97, 20, 'Dylan', 'Gissi', 35, 'Suiza', 2, 1, 0),
(98, 20, 'Alejo', 'Dramisino', 25, 'Argentina', 8, 2, 5),
(99, 20, 'Federico', 'Bisanz', 24, 'Argentina', 10, 7, 7),
(100, 20, 'Erik', 'Bodencer', 26, 'Argentina', 9, 7, 2);

--
-- Disparadores `jugadores`
--
DELIMITER $$
CREATE TRIGGER `validar_limites_transferencia` BEFORE UPDATE ON `jugadores` FOR EACH ROW BEGIN
    DECLARE cantidad_nueva INT;
    DECLARE cantidad_vieja INT;

    SELECT COUNT(*) INTO cantidad_nueva 
    FROM jugadores 
    WHERE id_club = NEW.id_club;

    SELECT COUNT(*) INTO cantidad_vieja 
    FROM jugadores 
    WHERE id_club = OLD.id_club;
    
    IF cantidad_nueva >= 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El club de destino ya alcanzó el máximo de 6 jugadores';
    END IF;

    IF cantidad_vieja <= 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El club de origen no puede quedarse con menos de 4 jugadores';
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partidos`
--

CREATE TABLE `partidos` (
  `id_partido` int(10) UNSIGNED NOT NULL,
  `id_competicion` int(10) UNSIGNED NOT NULL,
  `instancia_partido` varchar(30) DEFAULT NULL,
  `id_clubLocal` int(10) UNSIGNED NOT NULL,
  `id_clubVisitante` int(10) UNSIGNED NOT NULL,
  `estadio` varchar(20) NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `Gol_visitante` int(11) NOT NULL,
  `Gol_local` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `partidos`
--

INSERT INTO `partidos` (`id_partido`, `id_competicion`, `instancia_partido`, `id_clubLocal`, `id_clubVisitante`, `estadio`, `fecha_hora`, `Gol_visitante`, `Gol_local`) VALUES
(1, 1, 'Fecha 1', 1, 10, 'Monumental', '2026-05-09 21:00:00', 1, 3),
(2, 1, 'Fecha 1', 2, 9, 'La Bombonera', '2026-05-09 21:00:00', 0, 2),
(3, 1, 'Fecha 1', 3, 8, 'Libertadores Am.', '2026-05-10 18:00:00', 1, 1),
(4, 1, 'Fecha 1', 4, 7, 'Cilindro Avellan.', '2026-05-10 19:00:00', 2, 0),
(5, 1, 'Fecha 1', 5, 6, 'Nuevo Gasometro', '2026-05-10 15:00:00', 0, 1),
(6, 1, 'Fecha 2', 5, 8, 'Nuevo Gasometro', '2026-05-16 17:00:00', 1, 2),
(7, 1, 'Fecha 2', 10, 6, 'Ciudad de Lanus', '2026-05-16 15:00:00', 0, 0),
(8, 1, 'Fecha 2', 7, 1, 'Jose Amalfitani', '2026-05-17 21:00:00', 2, 1),
(9, 1, 'Fecha 2', 9, 3, 'Diego A. Maradona', '2026-05-17 18:00:00', 1, 1),
(10, 1, 'Fecha 2', 2, 4, 'La Bombonera', '2026-05-17 21:00:00', 0, 2),
(11, 1, 'Fecha 3', 1, 9, 'Monumental', '2026-05-23 21:00:00', 0, 2),
(12, 1, 'Fecha 3', 3, 7, 'Libertadores Am.', '2026-05-23 18:00:00', 1, 0),
(13, 1, 'Fecha 3', 4, 6, 'Cilindro Avellan.', '2026-05-24 19:00:00', 1, 2),
(14, 1, 'Fecha 3', 8, 10, 'Tomas A. Duco', '2026-05-24 15:00:00', 2, 1),
(15, 1, 'Fecha 3', 2, 5, 'La Bombonera', '2026-05-24 21:00:00', 1, 1),
(16, 1, 'Fecha 4', 3, 4, 'Libertadores Am.', '2026-05-30 17:00:00', 1, 1),
(17, 1, 'Fecha 4', 1, 5, 'Monumental', '2026-05-30 21:00:00', 0, 3),
(18, 1, 'Fecha 4', 2, 6, 'La Bombonera', '2026-05-31 21:00:00', 1, 2),
(19, 1, 'Fecha 4', 8, 9, 'Tomas A. Duco', '2026-05-31 15:00:00', 2, 0),
(20, 1, 'Fecha 4', 10, 7, 'Ciudad de Lanus', '2026-05-31 18:00:00', 2, 2),
(21, 2, '16avos', 1, 20, 'Estadio Kempes', '2026-06-03 21:00:00', 0, 4),
(22, 2, '16avos', 2, 19, 'Gigante Arroyito', '2026-06-03 21:00:00', 1, 3),
(23, 2, '16avos', 3, 18, 'Juan C. Zerillo', '2026-06-04 18:00:00', 2, 2),
(24, 2, '16avos', 4, 17, 'Alfredo Beranger', '2026-06-04 15:00:00', 0, 2),
(25, 1, 'Fecha 5', 6, 1, 'Estadio UNO', '2026-06-06 20:00:00', 2, 0),
(26, 1, 'Fecha 5', 7, 2, 'Jose Amalfitani', '2026-06-06 21:30:00', 1, 1),
(27, 1, 'Fecha 5', 9, 4, 'Diego A. Maradona', '2026-06-07 15:00:00', 3, 2),
(28, 1, 'Fecha 5', 10, 5, 'Ciudad de Lanus', '2026-06-07 18:00:00', 0, 0),
(29, 1, 'Fecha 5', 8, 3, 'Tomas A. Duco', '2026-06-07 19:00:00', 1, 1),
(30, 1, 'Fecha 6', 1, 4, 'Monumental', '2026-06-13 21:00:00', 1, 2),
(31, 1, 'Fecha 6', 3, 2, 'Libertadores Am.', '2026-06-13 18:00:00', 2, 1),
(32, 1, 'Fecha 6', 5, 9, 'Nuevo Gasometro', '2026-06-14 15:00:00', 0, 0),
(33, 1, 'Fecha 6', 7, 8, 'Jose Amalfitani', '2026-06-14 19:00:00', 1, 1),
(34, 1, 'Fecha 6', 6, 10, 'Estadio UNO', '2026-06-14 17:00:00', 1, 2),
(35, 1, 'Fecha 7', 1, 2, 'Monumental', '2026-06-20 17:00:00', 2, 2),
(36, 1, 'Fecha 7', 3, 5, 'Libertadores Am.', '2026-06-20 21:00:00', 1, 0),
(37, 1, 'Fecha 7', 4, 6, 'Cilindro Avellan.', '2026-06-21 19:00:00', 0, 2),
(38, 1, 'Fecha 7', 8, 7, 'Tomas A. Duco', '2026-06-21 15:00:00', 1, 1),
(39, 1, 'Fecha 7', 10, 9, 'Ciudad de Lanus', '2026-06-21 21:30:00', 0, 1),
(40, 1, 'Fecha 8', 1, 8, 'Monumental', '2026-06-27 21:00:00', 0, 3),
(41, 1, 'Fecha 8', 4, 5, 'Cilindro Avellan.', '2026-06-27 19:00:00', 1, 0),
(42, 1, 'Fecha 8', 2, 10, 'La Bombonera', '2026-06-28 21:00:00', 0, 4),
(43, 1, 'Fecha 8', 6, 3, 'Estadio UNO', '2026-06-28 15:00:00', 2, 1),
(44, 1, 'Fecha 8', 7, 9, 'Jose Amalfitani', '2026-06-28 18:00:00', 1, 1),
(45, 2, '8avos', 1, 3, 'Bicentenario SJ', '2026-07-01 21:10:00', 1, 3),
(46, 2, '8avos', 2, 4, 'Padre Martearena', '2026-07-01 21:10:00', 0, 2),
(47, 1, 'Fecha 9', 1, 3, 'Monumental', '2026-07-04 21:00:00', 2, 1),
(48, 1, 'Fecha 9', 2, 8, 'La Bombonera', '2026-07-04 21:00:00', 1, 1),
(49, 1, 'Fecha 9', 4, 10, 'Cilindro Avellan.', '2026-07-05 19:00:00', 1, 0),
(50, 1, 'Fecha 9', 5, 7, 'Nuevo Gasometro', '2026-07-05 15:00:00', 1, 1),
(51, 1, 'Fecha 9', 6, 9, 'Estadio UNO', '2026-07-05 17:00:00', 2, 1),
(52, 1, 'Fecha 10', 8, 5, 'Tomas A. Duco', '2026-07-11 17:00:00', 1, 0),
(53, 1, 'Fecha 10', 10, 1, 'Ciudad de Lanus', '2026-07-11 15:00:00', 2, 1),
(54, 1, 'Fecha 10', 9, 2, 'Diego A. Maradona', '2026-07-12 18:00:00', 3, 2),
(55, 1, 'Fecha 10', 7, 4, 'Jose Amalfitani', '2026-07-12 21:00:00', 1, 1),
(56, 1, 'Fecha 10', 6, 3, 'Estadio UNO', '2026-07-12 14:00:00', 0, 2),
(57, 1, 'Fecha 11', 1, 7, 'Monumental', '2026-07-18 21:00:00', 1, 3),
(58, 1, 'Fecha 11', 3, 9, 'Libertadores Am.', '2026-07-18 18:00:00', 0, 1),
(59, 1, 'Fecha 11', 4, 2, 'Cilindro Avellan.', '2026-07-19 19:00:00', 2, 1),
(60, 1, 'Fecha 11', 8, 6, 'Tomas A. Duco', '2026-07-19 15:00:00', 0, 1),
(61, 1, 'Fecha 11', 5, 10, 'Nuevo Gasometro', '2026-07-19 21:00:00', 1, 2),
(62, 1, 'Fecha 12', 4, 3, 'Cilindro Avellan.', '2026-07-25 17:00:00', 0, 2),
(63, 1, 'Fecha 12', 9, 1, 'Diego A. Maradona', '2026-07-25 21:00:00', 1, 0),
(64, 1, 'Fecha 12', 7, 3, 'Jose Amalfitani', '2026-07-26 18:00:00', 1, 2),
(65, 1, 'Fecha 12', 10, 8, 'Ciudad de Lanus', '2026-07-26 15:00:00', 1, 1),
(66, 1, 'Fecha 12', 5, 2, 'Nuevo Gasometro', '2026-07-26 21:00:00', 1, 1),
(67, 2, '4tos', 10, 4, 'Padre Martearena', '2026-07-29 20:00:00', 2, 1),
(68, 2, '4tos', 15, 18, 'Gigante Arroyito', '2026-07-29 15:00:00', 0, 1),
(69, 1, 'Fecha 13', 4, 1, 'Cilindro Avellan.', '2026-08-01 21:00:00', 1, 1),
(70, 1, 'Fecha 13', 2, 3, 'La Bombonera', '2026-08-01 21:00:00', 1, 2),
(71, 1, 'Fecha 13', 9, 5, 'Diego A. Maradona', '2026-08-02 15:00:00', 0, 0),
(72, 1, 'Fecha 13', 8, 7, 'Tomas A. Duco', '2026-08-02 18:00:00', 1, 1),
(73, 1, 'Fecha 13', 6, 10, 'Estadio UNO', '2026-08-02 19:00:00', 1, 2),
(74, 1, 'Fecha 14', 5, 1, 'Nuevo Gasometro', '2026-08-08 21:00:00', 1, 1),
(75, 1, 'Fecha 14', 6, 2, 'Estadio UNO', '2026-08-08 19:00:00', 1, 0),
(76, 1, 'Fecha 14', 9, 8, 'Diego A. Maradona', '2026-08-09 15:00:00', 0, 2),
(77, 1, 'Fecha 14', 7, 10, 'Jose Amalfitani', '2026-08-09 18:00:00', 1, 1),
(78, 1, 'Fecha 14', 4, 3, 'Cilindro Avellan.', '2026-08-09 17:00:00', 0, 1),
(79, 1, 'Fecha 15', 2, 1, 'La Bombonera', '2026-08-15 17:00:00', 1, 2),
(80, 1, 'Fecha 15', 5, 3, 'Nuevo Gasometro', '2026-08-15 21:00:00', 0, 1),
(81, 1, 'Fecha 15', 6, 4, 'Estadio UNO', '2026-08-16 19:00:00', 1, 2),
(82, 1, 'Fecha 15', 7, 8, 'Jose Amalfitani', '2026-08-16 15:00:00', 0, 1),
(83, 1, 'Fecha 15', 9, 10, 'Diego A. Maradona', '2026-08-16 21:30:00', 2, 0),
(84, 1, 'Fecha 16', 8, 1, 'Tomas A. Duco', '2026-08-22 21:00:00', 2, 1),
(85, 1, 'Fecha 16', 5, 4, 'Nuevo Gasometro', '2026-08-22 18:00:00', 0, 1),
(86, 1, 'Fecha 16', 10, 2, 'Ciudad de Lanus', '2026-08-23 21:00:00', 2, 3),
(87, 1, 'Fecha 16', 3, 6, 'Libertadores Am.', '2026-08-23 15:00:00', 1, 1),
(88, 1, 'Fecha 16', 9, 7, 'Diego A. Maradona', '2026-08-23 18:00:00', 1, 1),
(89, 2, '32avos', 11, 1, 'Estadio San Luis', '2026-05-01 19:00:00', 2, 0),
(90, 2, '32avos', 12, 2, 'Ciudad de Caseros', '2026-05-01 21:15:00', 3, 1),
(91, 2, '32avos', 13, 3, 'Centenario Quilmes', '2026-05-02 15:00:00', 1, 0),
(92, 2, '32avos', 14, 4, 'Estadio San Nicolas', '2026-05-02 18:00:00', 2, 1),
(93, 2, '32avos', 16, 5, 'Bicentenario SJ', '2026-05-03 20:00:00', 2, 0),
(94, 2, '32avos', 15, 6, 'Rep. Mataderos', '2026-05-03 21:00:00', 1, 0),
(95, 2, '32avos', 17, 7, 'Fragata Sarmiento', '2026-05-04 19:00:00', 2, 1),
(96, 2, '32avos', 18, 8, 'Chacarita Jrs', '2026-05-04 21:30:00', 1, 2),
(97, 2, '32avos', 19, 9, 'R. Etcheverri', '2026-05-05 20:00:00', 1, 3),
(98, 2, '32avos', 20, 10, 'Don Leon Kolbowski', '2026-05-05 22:15:00', 0, 1),
(99, 1, 'Fecha 17', 1, 2, 'Monumental', '2026-05-09 17:24:03', 1, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `posiciones`
--

CREATE TABLE `posiciones` (
  `id_posicion` int(10) UNSIGNED NOT NULL,
  `id_jugador` int(10) UNSIGNED NOT NULL,
  `posicion` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `posiciones`
--

INSERT INTO `posiciones` (`id_posicion`, `id_jugador`, `posicion`) VALUES
(1, 1, 'Arquero'),
(2, 2, 'Lateral derecho'),
(3, 3, 'Pivote'),
(4, 4, 'Enganche'),
(5, 5, 'Delantero centro'),
(6, 6, 'Arquero'),
(7, 7, 'Pivote'),
(8, 8, 'Mediocentro'),
(9, 9, 'Enganche'),
(10, 10, 'Delantero centro'),
(11, 11, 'Arquero'),
(12, 12, 'Defensa central'),
(13, 13, 'Extremo izquierdo'),
(14, 14, 'Extremo derecho'),
(15, 15, 'Delantero centro'),
(16, 16, 'Arquero'),
(17, 17, 'Lateral izquierdo'),
(18, 18, 'Pivote'),
(19, 19, 'Extremo izquierdo'),
(20, 20, 'Delantero centro'),
(21, 21, 'Arquero'),
(22, 22, 'Defensa central'),
(23, 23, 'Mediocentro'),
(24, 24, 'Delantero centro'),
(25, 25, 'Delantero centro'),
(26, 26, 'Arquero'),
(27, 27, 'Defensa central'),
(28, 28, 'Delantero centro'),
(29, 29, 'Delantero centro'),
(30, 30, 'Extremo izquierdo'),
(31, 31, 'Arquero'),
(32, 32, 'Enganche'),
(33, 33, 'Delantero centro'),
(34, 34, 'Mediocentro'),
(35, 35, 'Mediocentro'),
(36, 36, 'Arquero'),
(37, 37, 'Mediocentro'),
(38, 38, 'Lateral derecho'),
(39, 39, 'Enganche'),
(40, 40, 'Delantero centro'),
(41, 41, 'Arquero'),
(42, 42, 'Pivote'),
(43, 43, 'Enganche'),
(44, 44, 'Enganche'),
(45, 45, 'Enganche'),
(46, 46, 'Arquero'),
(47, 47, 'Defensa central'),
(48, 48, 'Enganche'),
(49, 49, 'Defensa central'),
(50, 50, 'Delantero centro'),
(51, 51, 'Arquero'),
(52, 52, 'Defensa central'),
(53, 53, 'Extremo izquierdo'),
(54, 54, 'Enganche'),
(55, 55, 'Delantero centro'),
(56, 56, 'Arquero'),
(57, 57, 'Lateral derecho'),
(58, 58, 'Enganche'),
(59, 59, 'Extremo izquierdo'),
(60, 60, 'Delantero centro'),
(61, 61, 'Arquero'),
(62, 62, 'Defensa central'),
(63, 63, 'Mediocentro'),
(64, 64, 'Enganche'),
(65, 65, 'Delantero centro'),
(66, 66, 'Arquero'),
(67, 67, 'Lateral izquierdo'),
(68, 68, 'Pivote'),
(69, 69, 'Enganche'),
(70, 70, 'Delantero centro'),
(71, 71, 'Arquero'),
(72, 72, 'Defensa central'),
(73, 73, 'Pivote'),
(74, 74, 'Enganche'),
(75, 75, 'Delantero centro'),
(76, 76, 'Arquero'),
(77, 77, 'Defensa central'),
(78, 78, 'Pivote'),
(79, 79, 'Mediocentro'),
(80, 80, 'Delantero centro'),
(81, 81, 'Arquero'),
(82, 82, 'Lateral derecho'),
(83, 83, 'Enganche'),
(84, 84, 'Mediocentro'),
(85, 85, 'Delantero centro'),
(86, 86, 'Arquero'),
(87, 87, 'Defensa central'),
(88, 88, 'Pivote'),
(89, 89, 'Enganche'),
(90, 90, 'Delantero centro'),
(91, 91, 'Arquero'),
(92, 92, 'Defensa central'),
(93, 93, 'Pivote'),
(94, 94, 'Enganche'),
(95, 95, 'Delantero centro'),
(96, 96, 'Arquero'),
(97, 97, 'Defensa central'),
(98, 98, 'Mediocentro'),
(99, 99, 'Enganche'),
(100, 100, 'Delantero centro');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rankings`
--

CREATE TABLE `rankings` (
  `id_ranking` int(10) UNSIGNED NOT NULL,
  `id_club` int(10) UNSIGNED NOT NULL,
  `posicion_ranking` int(10) UNSIGNED NOT NULL,
  `goles_a_favor` int(10) UNSIGNED NOT NULL,
  `goles_encontra` int(10) UNSIGNED NOT NULL,
  `diff_gol` int(11) NOT NULL,
  `partidos_ganados` int(10) UNSIGNED NOT NULL,
  `partidos_empatados` int(10) UNSIGNED NOT NULL,
  `partidos_perdidos` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rankings`
--

INSERT INTO `rankings` (`id_ranking`, `id_club`, `posicion_ranking`, `goles_a_favor`, `goles_encontra`, `diff_gol`, `partidos_ganados`, `partidos_empatados`, `partidos_perdidos`) VALUES
(1, 1, 1, 43, 16, 29, 16, 3, 1),
(2, 2, 2, 37, 22, 13, 13, 5, 2),
(3, 5, 3, 18, 11, 7, 9, 6, 2),
(4, 4, 4, 22, 22, 0, 8, 3, 9),
(5, 7, 5, 19, 17, 2, 5, 10, 1),
(6, 10, 6, 19, 25, -6, 5, 5, 7),
(7, 3, 7, 17, 26, -9, 4, 6, 10),
(8, 6, 8, 14, 19, -5, 4, 2, 9),
(9, 9, 9, 13, 20, -7, 3, 5, 8),
(10, 8, 10, 12, 19, -7, 2, 7, 7),
(11, 18, 11, 3, 2, 1, 1, 1, 0),
(12, 19, 12, 1, 3, -2, 0, 0, 1),
(13, 20, 13, 0, 4, -4, 0, 0, 1),
(14, 17, 14, 0, 2, -2, 0, 0, 1),
(15, 15, 15, 0, 1, -1, 0, 0, 1),
(16, 11, 16, 0, 2, -2, 0, 0, 1),
(17, 12, 17, 1, 3, -2, 0, 0, 1),
(18, 13, 18, 0, 1, -1, 0, 0, 1),
(19, 14, 19, 1, 2, -1, 0, 0, 1),
(20, 16, 20, 0, 2, -2, 0, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre_usuario` varchar(20) NOT NULL,
  `apellido` varchar(20) NOT NULL,
  `contraseña` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `clubes`
--
ALTER TABLE `clubes`
  ADD PRIMARY KEY (`id_club`);

--
-- Indices de la tabla `competiciones`
--
ALTER TABLE `competiciones`
  ADD PRIMARY KEY (`id_competicion`);

--
-- Indices de la tabla `jugadores`
--
ALTER TABLE `jugadores`
  ADD PRIMARY KEY (`id_jugador`),
  ADD KEY `id_club` (`id_club`);

--
-- Indices de la tabla `partidos`
--
ALTER TABLE `partidos`
  ADD PRIMARY KEY (`id_partido`),
  ADD KEY `partidosA` (`id_clubLocal`),
  ADD KEY `partidosB` (`id_clubVisitante`),
  ADD KEY `partidosC` (`id_competicion`);

--
-- Indices de la tabla `posiciones`
--
ALTER TABLE `posiciones`
  ADD PRIMARY KEY (`id_posicion`),
  ADD KEY `posiciones` (`id_jugador`);

--
-- Indices de la tabla `rankings`
--
ALTER TABLE `rankings`
  ADD PRIMARY KEY (`id_ranking`),
  ADD KEY `FKrankings` (`id_club`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `clubes`
--
ALTER TABLE `clubes`
  MODIFY `id_club` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `competiciones`
--
ALTER TABLE `competiciones`
  MODIFY `id_competicion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `jugadores`
--
ALTER TABLE `jugadores`
  MODIFY `id_jugador` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT de la tabla `partidos`
--
ALTER TABLE `partidos`
  MODIFY `id_partido` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;

--
-- AUTO_INCREMENT de la tabla `posiciones`
--
ALTER TABLE `posiciones`
  MODIFY `id_posicion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT de la tabla `rankings`
--
ALTER TABLE `rankings`
  MODIFY `id_ranking` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `jugadores`
--
ALTER TABLE `jugadores`
  ADD CONSTRAINT `jugadores_ibfk_1` FOREIGN KEY (`id_club`) REFERENCES `clubes` (`id_club`);

--
-- Filtros para la tabla `partidos`
--
ALTER TABLE `partidos`
  ADD CONSTRAINT `partidosA` FOREIGN KEY (`id_clubLocal`) REFERENCES `clubes` (`id_club`),
  ADD CONSTRAINT `partidosB` FOREIGN KEY (`id_clubVisitante`) REFERENCES `clubes` (`id_club`),
  ADD CONSTRAINT `partidos_fk_competicion` FOREIGN KEY (`id_competicion`) REFERENCES `competiciones` (`id_competicion`);

--
-- Filtros para la tabla `posiciones`
--
ALTER TABLE `posiciones`
  ADD CONSTRAINT `posiciones` FOREIGN KEY (`id_jugador`) REFERENCES `jugadores` (`id_jugador`);

--
-- Filtros para la tabla `rankings`
--
ALTER TABLE `rankings`
  ADD CONSTRAINT `FKrankings` FOREIGN KEY (`id_club`) REFERENCES `clubes` (`id_club`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
