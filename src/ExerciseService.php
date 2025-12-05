<?php
// src/ExerciseService.php

require_once __DIR__ . '/Db.php';

class ExerciseService
{
    public static function getSkills(): array
    {
        $pdo = Db::getConnection();
        $stmt = $pdo->query("SELECT id, code, name, description FROM skill WHERE 1");
        return $stmt->fetchAll();
    }

    public static function getExerciseSets(?string $skillCode = null): array
    {
        $pdo = Db::getConnection();

        if ($skillCode) {
            $sql = "SELECT es.id, es.skill_id, s.code as skill_code, es.name, es.description, es.config_json
                    FROM exercise_set es
                    JOIN skill s ON es.skill_id = s.id
                    WHERE s.code = :code AND es.is_active = 1";
            $stmt = $pdo->prepare($sql);
            $stmt->execute(['code' => $skillCode]);
        } else {
            $sql = "SELECT es.id, es.skill_id, s.code as skill_code, es.name, es.description, es.config_json
                    FROM exercise_set es
                    JOIN skill s ON es.skill_id = s.id
                    WHERE es.is_active = 1";
            $stmt = $pdo->query($sql);
        }

        return $stmt->fetchAll();
    }

    /**
     * Holt dynamische Aufgaben für z.B. MUL_TABLE anhand exercise_set.config_json
     */
    public static function getExercises(string $skillCode, int $exerciseSetId, int $limit = 10): array
    {
        $pdo = Db::getConnection();

        // Set + Skill holen
        $sql = "SELECT es.id, es.config_json, s.code AS skill_code
                FROM exercise_set es
                JOIN skill s ON es.skill_id = s.id
                WHERE es.id = :id AND s.code = :code AND es.is_active = 1";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            'id'   => $exerciseSetId,
            'code' => $skillCode,
        ]);
        $set = $stmt->fetch();

        if (!$set) {
            throw new RuntimeException("Exercise set not found");
        }

        $config = [];
        if (!empty($set['config_json'])) {
            $config = json_decode($set['config_json'], true) ?: [];
        }

        // Jetzt je nach Skill-Code generieren
        if ($skillCode === 'MUL_TABLE') {
            return self::generateMulTableExercises($config, $limit);
        }

        // TODO: andere Skills (ADD, SUB ...) später
        throw new RuntimeException("Skill not yet implemented");
    }

    private static function generateMulTableExercises(array $config, int $limit): array
    {
        $min = $config['minFactor'] ?? 1;
        $max = $config['maxFactor'] ?? 10;
        $allowed = $config['allowed'] ?? null; // z.B. [7,8,9]

        $result = [];

        for ($i = 0; $i < $limit; $i++) {
            if (is_array($allowed) && !empty($allowed)) {
                $a = $allowed[array_rand($allowed)];
                $b = random_int($min, $max);
            } else {
                $a = random_int($min, $max);
                $b = random_int($min, $max);
            }

            $result[] = [
                'id'      => null, // keine feste exercise_id, dynamisch generiert
                'payload' => [
                    'a'  => $a,
                    'b'  => $b,
                    'op' => '*',
                ],
            ];
        }

        return $result;
    }

    public static function saveAttempt(array $data): array
    {
        $pdo = Db::getConnection();

        // Minimalvalidierung
        $childId        = (int)($data['childId'] ?? 0);
        $skillCode      = $data['skill'] ?? null;
        $exerciseSetId  = isset($data['exerciseSetId']) ? (int)$data['exerciseSetId'] : null;
        $exerciseId     = isset($data['exerciseId']) ? (int)$data['exerciseId'] : null;
        $payload        = $data['payload'] ?? null;
        $givenNumber    = isset($data['givenAnswer']) ? (float)$data['givenAnswer'] : null;
        $responseTimeMs = isset($data['responseTimeMs']) ? (int)$data['responseTimeMs'] : null;

        if (!$childId || !$skillCode || $givenNumber === null || !$payload) {
            throw new RuntimeException("Missing required fields");
        }

        // Skill-ID ermitteln
        $stmt = $pdo->prepare("SELECT id FROM skill WHERE code = :code");
        $stmt->execute(['code' => $skillCode]);
        $skill = $stmt->fetch();
        if (!$skill) {
            throw new RuntimeException("Skill not found");
        }
        $skillId = (int)$skill['id'];

        // Lösung berechnen (hier nur MUL_TABLE implementiert)
        $correctAnswer = null;
        $isCorrect = 0;

        if ($skillCode === 'MUL_TABLE') {
            $a = (int)$payload['a'];
            $b = (int)$payload['b'];
            $correctAnswer = $a * $b;
            $isCorrect = ((float)$correctAnswer === (float)$givenNumber) ? 1 : 0;
        } else {
            // TODO: weitere Skills
            throw new RuntimeException("Skill not yet implemented");
        }

        $payloadJson = json_encode($payload);

        $stmt = $pdo->prepare("
            INSERT INTO exercise_attempt
            (child_id, skill_id, exercise_set_id, exercise_id, payload_json,
             given_answer_number, correct, response_time_ms, created_at)
            VALUES
            (:child_id, :skill_id, :exercise_set_id, :exercise_id, :payload_json,
             :given_answer_number, :correct, :response_time_ms, NOW())
        ");

        $stmt->execute([
            'child_id'          => $childId,
            'skill_id'          => $skillId,
            'exercise_set_id'   => $exerciseSetId,
            'exercise_id'       => $exerciseId ?: null,
            'payload_json'      => $payloadJson,
            'given_answer_number'=> $givenNumber,
            'correct'           => $isCorrect,
            'response_time_ms'  => $responseTimeMs,
        ]);

        return [
            'correct'       => (bool)$isCorrect,
            'correctAnswer' => $correctAnswer,
        ];
    }

    public static function getChildStats(int $childId, string $skillCode): array
    {
        $pdo = Db::getConnection();

        // Skill-ID holen
        $stmt = $pdo->prepare("SELECT id FROM skill WHERE code = :code");
        $stmt->execute(['code' => $skillCode]);
        $skill = $stmt->fetch();
        if (!$skill) {
            throw new RuntimeException("Skill not found");
        }
        $skillId = (int)$skill['id'];

        // Gesamt-Stats
        $stmt = $pdo->prepare("
            SELECT COUNT(*) as total,
                   SUM(correct) as correct
            FROM exercise_attempt
            WHERE child_id = :child_id
              AND skill_id = :skill_id
        ");
        $stmt->execute([
            'child_id' => $childId,
            'skill_id' => $skillId,
        ]);
        $row = $stmt->fetch();

        $total   = (int)($row['total'] ?? 0);
        $correct = (int)($row['correct'] ?? 0);
        $accuracy = $total > 0 ? $correct / $total : 0.0;

        // Beispiel: Per-Factor-Statistik anhand payload_json->'$.b' (oder a)
        $perFactor = [];

        if ($skillCode === 'MUL_TABLE' && $total > 0) {
            $stmt = $pdo->prepare("
                SELECT
                    JSON_EXTRACT(payload_json, '$.b') AS factor,
                    COUNT(*) AS total,
                    SUM(correct) AS correct
                FROM exercise_attempt
                WHERE child_id = :child_id
                  AND skill_id = :skill_id
                GROUP BY factor
                ORDER BY CAST(factor AS UNSIGNED)
            ");
            $stmt->execute([
                'child_id' => $childId,
                'skill_id' => $skillId,
            ]);

            while ($fRow = $stmt->fetch()) {
                $factorVal = (int)$fRow['factor'];
                $t = (int)$fRow['total'];
                $c = (int)$fRow['correct'];
                $perFactor[$factorVal] = $t > 0 ? $c / $t : 0.0;
            }
        }

        return [
            'childId'        => $childId,
            'skill'         => $skillCode,
            'totalAttempts' => $total,
            'correctAttempts'=> $correct,
            'accuracy'      => $accuracy,
            'perFactor'     => $perFactor,
        ];
    }
}
