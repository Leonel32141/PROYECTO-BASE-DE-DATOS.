-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3307
-- Tiempo de generación: 26-04-2026 a las 00:30:40
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12
CREATE DATABASE IF NOT EXISTS proyectofutbol;
USE proyectofutbol;

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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clubes`
--

CREATE TABLE `clubes` (
  `id_club` int(11) UNSIGNED NOT NULL,
  `nombre_club` varchar(40) NOT NULL,
  `pais` varchar(30) NOT NULL,
  `locacion` varchar(20) NOT NULL,
  `estadio` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clubes_competiciones`
--

CREATE TABLE `clubes_competiciones` (
  `id_club_competicion` int(10) UNSIGNED NOT NULL,
  `id_competicion` int(10) UNSIGNED NOT NULL,
  `id_club` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historiales`
--

CREATE TABLE `historiales` (
  `id_historial` int(10) UNSIGNED NOT NULL,
  `id_partido` int(10) UNSIGNED NOT NULL,
  `id_competicion` int(10) UNSIGNED DEFAULT NULL,
  `id_clubLocal` int(10) UNSIGNED NOT NULL,
  `id_clubVisitante` int(10) UNSIGNED NOT NULL,
  `estadio` varchar(20) NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `gol_local` int(11) NOT NULL,
  `gol_visitante` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



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
  `goles` int(11) UNSIGNED NOT NULL,
  `asistencias` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partidos`
--

CREATE TABLE `partidos` (
  `id_partido` int(10) UNSIGNED NOT NULL,
  `id_competicion` int(10) UNSIGNED NOT NULL,
  `id_clubLocal` int(10) UNSIGNED NOT NULL,
  `id_clubVisitante` int(10) UNSIGNED NOT NULL,
  `estadio` varchar(20) NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `Gol_visitante` int(11) NOT NULL,
  `Gol_local` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `posiciones`
--

CREATE TABLE `posiciones` (
  `id_posicion` int(10) UNSIGNED NOT NULL,
  `id_jugador` int(10) UNSIGNED NOT NULL,
  `posicion` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `diff_gol` int(10) UNSIGNED NOT NULL,
  `partidos_ganados` int(10) UNSIGNED NOT NULL,
  `partidos_empatados` int(10) UNSIGNED NOT NULL,
  `partidos_perdidos` int(10) UNSIGNED NOT NULL,
  `id_competicion` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
-- Indices de la tabla `clubes_competiciones`
--
ALTER TABLE `clubes_competiciones`
  ADD PRIMARY KEY (`id_club_competicion`),
  ADD UNIQUE KEY `unique_club_competicion` (`id_competicion`,`id_club`),
  ADD KEY `idx_competiciones` (`id_competicion`),
  ADD KEY `idx_club` (`id_club`);

--
-- Indices de la tabla `historiales`
--
ALTER TABLE `historiales`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `historialesFK1` (`id_partido`),
  ADD KEY `historialesFK2` (`id_competicion`),
  ADD KEY `historialesFK3` (`id_clubLocal`),
  ADD KEY `historialesFK4` (`id_clubVisitante`);

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
  ADD KEY `FKrankings` (`id_club`),
  ADD KEY `rankings` (`id_competicion`);

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
  MODIFY `id_club` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `competiciones`
--
ALTER TABLE `competiciones`
  MODIFY `id_competicion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `clubes_competiciones`
--
ALTER TABLE `clubes_competiciones`
  MODIFY `id_club_competicion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `historiales`
--
ALTER TABLE `historiales`
  MODIFY `id_historial` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `jugadores`
--
ALTER TABLE `jugadores`
  MODIFY `id_jugador` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `partidos`
--
ALTER TABLE `partidos`
  MODIFY `id_partido` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `posiciones`
--
ALTER TABLE `posiciones`
  MODIFY `id_posicion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rankings`
--
ALTER TABLE `rankings`
  MODIFY `id_ranking` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `clubes_competiciones`
--
ALTER TABLE `clubes_competiciones`
  ADD CONSTRAINT `clubes_competiciones_fk_competicion` FOREIGN KEY (`id_competicion`) REFERENCES `competiciones` (`id_competicion`),
  ADD CONSTRAINT `clubes_competiciones_fk_club` FOREIGN KEY (`id_club`) REFERENCES `clubes` (`id_club`);

--
-- Filtros para la tabla `historiales`
--
ALTER TABLE `historiales`
  ADD CONSTRAINT `historialesFK1` FOREIGN KEY (`id_partido`) REFERENCES `partidos` (`id_partido`),
  ADD CONSTRAINT `historialesFK2` FOREIGN KEY (`id_competicion`) REFERENCES `competiciones` (`id_competicion`),
  ADD CONSTRAINT `historialesFK3` FOREIGN KEY (`id_clubLocal`) REFERENCES `clubes` (`id_club`),
  ADD CONSTRAINT `historialesFK4` FOREIGN KEY (`id_clubVisitante`) REFERENCES `clubes` (`id_club`);

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
  ADD CONSTRAINT `FKrankings` FOREIGN KEY (`id_club`) REFERENCES `clubes` (`id_club`),
  ADD CONSTRAINT `rankings` FOREIGN KEY (`id_competicion`) REFERENCES `competiciones` (`id_competicion`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
