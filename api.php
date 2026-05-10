<?php
error_reporting(0);
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

$dbFile = __DIR__ . '/database.json';

if (!file_exists($dbFile)) {
    $default = [
        'keys' => [],
        'offsets' => [
            "get_main" => "0x4A8478C", "get_transform" => "0x854060C", "get_transformNode" => "0x5C52CFC",
            "WorldToViewpoint" => "0x84E6AC8", "get_position" => "0x8552BAC", "Team" => "0x4A38D90",
            "Local" => "0x28FC854", "get_HP" => "0x58691B8", "get_maxHP" => "0x4A8489C",
            "get_IsDieing" => "0x4A02EA8", "get_IsVisible" => "0x4A20AF4", "GetLocalPlayer" => "0x4C5A64C",
            "CurrentMatch" => "0x4E355B0", "Camera_main" => "0x84E7148", "GetRotation" => "0x5081084",
            "get_isLocalTeam" => "0x55A0560", "get_IsSighting" => "0x4A0FF18", "get_IsFiring" => "0x56D1580",
            "WorldToScreenPoint" => "0x84E6AC8", "GetHeadPositions" => "0x4AA1A28",
            "Component_GetTransform" => "0x854060C", "GetForward" => "0x85534CC",
            "Player_GetHeadCollider" => "0x4A1A9D4", "Transform_GetPosition" => "0x8552C10",
            "GetAnimator" => "0x0", "Physics_Raycast" => "0x5580870", "set_aim" => "0x4A1C91C",
            "HipPosition" => "0x4AA1BD8", "LeftShoulderPosition" => "0x0", "RightShoulderPosition" => "0x0",
            "LeftAnklePosition" => "0x4AA2028", "RightAnklePosition" => "0x4AA2134",
            "LeftToePosition" => "0x4AA2240", "RightToePosition" => "0x4AA234C",
            "LeftHandPosition" => "0x4A1B9B4", "RightHandPosition" => "0x4A1BAB8",
            "RightForeArmPosition" => "0x4A1BCC0", "LeftForeArmPosition" => "0x4A1BBBC",
            "CameraMain" => "0x84E7148", "IsClientBot" => "0x0", "IsAvatarInit" => "0x0",
            "MatchPlayers" => "0x4C869DC"
        ],
        'settings' => ['version' => '1.0.7-FFProduct', 'maintenance_mode' => false]
    ];
    file_put_contents($dbFile, json_encode($default, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

$db = json_decode(file_get_contents($dbFile), true) ?: ['keys' => [], 'offsets' => []];
$action = $_GET['action'] ?? '';
$input = json_decode(file_get_contents('php://input'), true) ?: [];

switch ($action) {
    case 'auth':
        $key = $input['key'] ?? '';
        if (empty($key)) { echo json_encode(['success' => false, 'message' => 'Key is required']); exit; }
        foreach ($db['keys'] as $i => $k) {
            if ($k['key'] === $key && $k['active'] && $k['expires_at'] > time()) {
                $db['keys'][$i]['last_used'] = time();
                $db['keys'][$i]['usage_count'] = ($db['keys'][$i]['usage_count'] ?? 0) + 1;
                file_put_contents($dbFile, json_encode($db, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
                echo json_encode(['success' => true, 'key' => $k['key'], 'version_name' => $k['version_name'], 'expires_at' => $k['expires_at'], 'message' => 'Login successful']);
                exit;
            }
        }
        echo json_encode(['success' => false, 'message' => 'Invalid or expired key']);
        break;

    case 'check':
        echo json_encode(['success' => true, 'allowed' => !($db['settings']['maintenance_mode'] ?? false)]);
        break;

    case 'check_openid':
        $oid = $input['open_id'] ?? 'unknown';
        echo json_encode(['status' => 'exists', 'udid' => 'DEVICE-' . strtoupper(substr(md5($oid), 0, 16))]);
        break;

    case 'request_openid':
    case 'request_open_id':
        echo json_encode(['open_id' => 'OPEN-' . strtoupper(bin2hex(random_bytes(12))), 'url' => 'https://khanhduyapi.free.nf/']);
        break;

    case 'generate_key':
        $vn = $input['version_name'] ?? 'OB53-Free';
        $ed = max(1, (int)($input['expiry_days'] ?? 30));
        $r = bin2hex(random_bytes(12));
        $key = 'MONITE-' . strtoupper(substr($r, 0, 8) . '-' . substr($r, 8, 8) . '-' . substr($r, 16, 8));
        $db['keys'][] = ['key' => $key, 'created_at' => time(), 'expires_at' => time() + ($ed * 86400), 'version_name' => $vn, 'active' => true, 'usage_count' => 0, 'last_used' => null];
        file_put_contents($dbFile, json_encode($db, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        echo json_encode(['success' => true, 'key' => $key, 'message' => 'Key created!']);
        break;

    case 'list_keys':
        echo json_encode(['keys' => $db['keys']]);
        break;

    case 'delete_key':
        $dk = $input['key'] ?? '';
        foreach ($db['keys'] as $i => $k) {
            if ($k['key'] === $dk) {
                unset($db['keys'][$i]); $db['keys'] = array_values($db['keys']);
                file_put_contents($dbFile, json_encode($db, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
                echo json_encode(['success' => true, 'message' => 'Key deleted!']); exit;
            }
        }
        echo json_encode(['success' => false, 'message' => 'Key not found']);
        break;

    case 'extend_key':
        $ek = $input['key'] ?? ''; $days = max(1, (int)($input['days'] ?? 30));
        foreach ($db['keys'] as $i => $k) {
            if ($k['key'] === $ek) {
                $db['keys'][$i]['expires_at'] = max($db['keys'][$i]['expires_at'], time()) + ($days * 86400);
                file_put_contents($dbFile, json_encode($db, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
                echo json_encode(['success' => true, 'message' => "Extended {$days} days!"]); exit;
            }
        }
        echo json_encode(['success' => false, 'message' => 'Key not found']);
        break;

    case 'save_offsets':
        $offs = $input['offsets'] ?? [];
        if (empty($offs)) { echo json_encode(['success' => false, 'message' => 'No offsets']); exit; }
        $db['offsets'] = $offs;
        file_put_contents($dbFile, json_encode($db, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        echo json_encode(['success' => true, 'message' => 'Offsets saved!']);
        break;

    case 'get_offsets':
        echo json_encode(['success' => true, 'offsets' => $db['offsets'], 'total' => count($db['offsets'])]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action: ' . $action]);
}
