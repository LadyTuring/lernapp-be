<?php
// public/index.php

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // für React/Android; später einschränken
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

require_once __DIR__ . '/../src/ExerciseService.php';

function jsonResponse($data, int $statusCode = 200): void
{
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$path   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Falls du dein API-Verzeichnis z.B. unter /api/ hast, ggf. Prefix abschneiden
// Beispiel: /api/exercises -> ['','api','exercises']
$segments = array_values(array_filter(explode('/', $path)));

try {
    // einfaches Routing: wir erwarten Pfade wie /api/skills, /api/exercises etc.
    $endpoint = $segments[count($segments) - 1] ?? '';

    if ($method === 'GET' && $endpoint === 'skills') {
        $skills = ExerciseService::getSkills();
        jsonResponse($skills);

    } elseif ($method === 'GET' && $endpoint === 'exercise-sets') {
        $skillCode = $_GET['skill'] ?? null;
        $sets = ExerciseService::getExerciseSets($skillCode);
        jsonResponse($sets);

    } elseif ($method === 'GET' && $endpoint === 'exercises') {
        $skillCode = $_GET['skill'] ?? null;
        $setId     = isset($_GET['exerciseSetId']) ? (int)$_GET['exerciseSetId'] : 0;
        $limit     = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;

        if (!$skillCode || !$setId) {
            throw new RuntimeException("skill and exerciseSetId are required");
        }

        $exercises = ExerciseService::getExercises($skillCode, $setId, $limit);
        jsonResponse([
            'skill'         => $skillCode,
            'exerciseSetId' => $setId,
            'exercises'     => $exercises,
        ]);

    } elseif ($method === 'POST' && $endpoint === 'exercise-attempts') {
        $raw = file_get_contents('php://input');
        $data = json_decode($raw, true);
        if (!is_array($data)) {
            throw new RuntimeException("Invalid JSON body");
        }

        $result = ExerciseService::saveAttempt($data);
        jsonResponse($result, 201);

    } elseif ($method === 'GET' && $endpoint === 'stats') {
        // z.B.: /api/stats?childId=1&skill=MUL_TABLE
        $childId   = isset($_GET['childId']) ? (int)$_GET['childId'] : 0;
        $skillCode = $_GET['skill'] ?? null;

        if (!$childId || !$skillCode) {
            throw new RuntimeException("childId and skill are required");
        }

        $stats = ExerciseService::getChildStats($childId, $skillCode);
        jsonResponse($stats);

    } else {
        jsonResponse(['error' => 'Not found'], 404);
    }

} catch (Throwable $e) {
    jsonResponse([
        'error'   => $e->getMessage(),
        // 'trace' => $e->getTraceAsString(), // nur zum Debuggen
    ], 400);
}
