-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mysqlsvr87.world4you.com
-- Erstellungszeit: 05. Dez 2025 um 15:25
-- Server-Version: 8.0.44
-- PHP-Version: 8.3.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `8548559db17`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `child`
--

DROP TABLE IF EXISTS `child`;
CREATE TABLE `child` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `birthdate` date DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- TRUNCATE Tabelle vor dem Einfügen `child`
--

TRUNCATE TABLE `child`;
--
-- Daten für Tabelle `child`
--

INSERT INTO `child` (`id`, `user_id`, `name`, `birthdate`, `avatar`, `created_at`, `updated_at`) VALUES
(1, NULL, 'Katie', NULL, NULL, '2025-12-05 14:23:45', '2025-12-05 14:25:55');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `exercise`
--

DROP TABLE IF EXISTS `exercise`;
CREATE TABLE `exercise` (
  `id` bigint UNSIGNED NOT NULL,
  `skill_id` smallint UNSIGNED NOT NULL,
  `exercise_set_id` bigint UNSIGNED DEFAULT NULL,
  `question_text` text COLLATE utf8mb4_unicode_ci,
  `data_json` json DEFAULT NULL,
  `solution_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `solution_number` decimal(20,4) DEFAULT NULL,
  `difficulty` tinyint UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- TRUNCATE Tabelle vor dem Einfügen `exercise`
--

TRUNCATE TABLE `exercise`;
-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `exercise_attempt`
--

DROP TABLE IF EXISTS `exercise_attempt`;
CREATE TABLE `exercise_attempt` (
  `id` bigint UNSIGNED NOT NULL,
  `child_id` bigint UNSIGNED NOT NULL,
  `skill_id` smallint UNSIGNED NOT NULL,
  `exercise_set_id` bigint UNSIGNED DEFAULT NULL,
  `exercise_id` bigint UNSIGNED DEFAULT NULL,
  `payload_json` json DEFAULT NULL,
  `given_answer_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `given_answer_number` decimal(20,4) DEFAULT NULL,
  `correct` tinyint(1) NOT NULL DEFAULT '0',
  `response_time_ms` int UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- TRUNCATE Tabelle vor dem Einfügen `exercise_attempt`
--

TRUNCATE TABLE `exercise_attempt`;
--
-- Daten für Tabelle `exercise_attempt`
--


-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `exercise_set`
--

DROP TABLE IF EXISTS `exercise_set`;
CREATE TABLE `exercise_set` (
  `id` bigint UNSIGNED NOT NULL,
  `skill_id` smallint UNSIGNED NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `config_json` json DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- TRUNCATE Tabelle vor dem Einfügen `exercise_set`
--

TRUNCATE TABLE `exercise_set`;
--
-- Daten für Tabelle `exercise_set`
--

INSERT INTO `exercise_set` (`id`, `skill_id`, `name`, `description`, `config_json`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, '1x1 bis 5er Reihe', 'Multiplikation mit Zahlen 1–5', '{\"maxFactor\": 5, \"minFactor\": 1}', 1, '2025-12-05 11:24:36', '2025-12-05 11:24:36'),
(2, 1, '1x1 komplett', 'Alle Reihen von 1 bis 10', '{\"maxFactor\": 10, \"minFactor\": 1}', 1, '2025-12-05 11:24:46', '2025-12-05 11:24:46'),
(3, 1, 'Schwer – 7er bis 9er Reihe', 'Fokus auf die schwierigeren Reihen 7, 8 und 9', '{\"allowed\": [7, 8, 9]}', 1, '2025-12-05 11:24:58', '2025-12-05 11:24:58');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `skill`
--

DROP TABLE IF EXISTS `skill`;
CREATE TABLE `skill` (
  `id` smallint UNSIGNED NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- TRUNCATE Tabelle vor dem Einfügen `skill`
--

TRUNCATE TABLE `skill`;
--
-- Daten für Tabelle `skill`
--

INSERT INTO `skill` (`id`, `code`, `name`, `description`, `created_at`) VALUES
(1, 'MUL_TABLE', 'Einmaleins', 'Multiplikationstraining für Kinder', '2025-12-05 11:24:21'),

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint UNSIGNED NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- TRUNCATE Tabelle vor dem Einfügen `user`
--

TRUNCATE TABLE `user`;
--
-- Daten für Tabelle `user`
--

INSERT INTO `user` (`id`, `email`, `password_hash`, `display_name`, `created_at`, `updated_at`) VALUES
(1, 'test@example.com', 'dummyhash123', 'Mama', '2025-12-05 11:24:00', '2025-12-05 11:24:00');

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `child`
--
ALTER TABLE `child`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_child_user` (`user_id`);

--
-- Indizes für die Tabelle `exercise`
--
ALTER TABLE `exercise`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_exercise_skill` (`skill_id`),
  ADD KEY `idx_exercise_set` (`exercise_set_id`);

--
-- Indizes für die Tabelle `exercise_attempt`
--
ALTER TABLE `exercise_attempt`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_attempt_child_skill` (`child_id`,`skill_id`,`created_at`),
  ADD KEY `idx_attempt_skill` (`skill_id`),
  ADD KEY `idx_attempt_exercise_set` (`exercise_set_id`),
  ADD KEY `idx_attempt_exercise` (`exercise_id`);

--
-- Indizes für die Tabelle `exercise_set`
--
ALTER TABLE `exercise_set`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_exercise_set_skill` (`skill_id`);

--
-- Indizes für die Tabelle `skill`
--
ALTER TABLE `skill`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_skill_code` (`code`);

--
-- Indizes für die Tabelle `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_email` (`email`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `child`
--
ALTER TABLE `child`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT für Tabelle `exercise`
--
ALTER TABLE `exercise`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `exercise_attempt`
--
ALTER TABLE `exercise_attempt`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;

--
-- AUTO_INCREMENT für Tabelle `exercise_set`
--
ALTER TABLE `exercise_set`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT für Tabelle `skill`
--
ALTER TABLE `skill`
  MODIFY `id` smallint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT für Tabelle `user`
--
ALTER TABLE `user`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `child`
--
ALTER TABLE `child`
  ADD CONSTRAINT `fk_child_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints der Tabelle `exercise`
--
ALTER TABLE `exercise`
  ADD CONSTRAINT `fk_exercise_exercise_set` FOREIGN KEY (`exercise_set_id`) REFERENCES `exercise_set` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_exercise_skill` FOREIGN KEY (`skill_id`) REFERENCES `skill` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `exercise_attempt`
--
ALTER TABLE `exercise_attempt`
  ADD CONSTRAINT `fk_attempt_child` FOREIGN KEY (`child_id`) REFERENCES `child` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_attempt_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercise` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_attempt_exercise_set` FOREIGN KEY (`exercise_set_id`) REFERENCES `exercise_set` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_attempt_skill` FOREIGN KEY (`skill_id`) REFERENCES `skill` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints der Tabelle `exercise_set`
--
ALTER TABLE `exercise_set`
  ADD CONSTRAINT `fk_exercise_set_skill` FOREIGN KEY (`skill_id`) REFERENCES `skill` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
