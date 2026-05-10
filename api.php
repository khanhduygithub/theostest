<?php
// Monite API Manager - Complete v3.0
// Full 42 Offsets + Key Management + 5 Monite APIs

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Database configuration
define('DB_FILE', __DIR__ . '/database.json');
define('SECRET_KEY', 'A1B2C3D4E5F607182933A4B5C6D7E8F9012233445667788899AABBCCDDEEFF001');

// Initialize database if not exists
function initDatabase() {
    if (!file_exists(DB_FILE)) {
        $data = [
            'keys' => [],
            'offsets' => [
                "get_main" => "0x4A8478C",
                "get_transform" => "0x854060C",
                "get_transformNode" => "0x5C52CFC",
                "WorldToViewpoint" => "0x84E6AC8",
                "get_position" => "0x8552BAC",
                "Team" => "0x4A38D90",
                "Local" => "0x28FC854",
                "get_HP" => "0x58691B8",
                "get_maxHP" => "0x4A8489C",
                "get_IsDieing" => "0x4A02EA8",
                "get_IsVisible" => "0x4A20AF4",
                "GetLocalPlayer" => "0x4C5A64C",
                "CurrentMatch" => "0x4E355B0",
                "Camera_main" => "0x84E7148",
                "GetRotation" => "0x5081084",
                "get_isLocalTeam" => "0x55A0560",
                "get_IsSighting" => "0x4A0FF18",
                "get_IsFiring" => "0x56D1580",
                "WorldToScreenPoint" => "0x84E6AC8",
                "GetHeadPositions" => "0x4AA1A28",
                "Component_GetTransform" => "0x854060C",
                "GetForward" => "0x85534CC",
                "Player_GetHeadCollider" => "0x4A1A9D4",
                "Transform_GetPosition" => "0x8552C10",
                "GetAnimator" => "0x0",
                "Physics_Raycast" => "0x5580870",
                "set_aim" => "0x4A1C91C",
                "HipPosition" => "0x4AA1BD8",
                "LeftShoulderPosition" => "0x0",
                "RightShoulderPosition" => "0x0",
                "LeftAnklePosition" => "0x4AA2028",
                "RightAnklePosition" => "0x4AA2134",
                "LeftToePosition" => "0x4AA2240",
                "RightToePosition" => "0x4AA234C",
                "LeftHandPosition" => "0x4A1B9B4",
                "RightHandPosition" => "0x4A1BAB8",
                "RightForeArmPosition" => "0x4A1BCC0",
                "LeftForeArmPosition" => "0x4A1BBBC",
                "CameraMain" => "0x84E7148",
                "IsClientBot" => "0x0",
                "IsAvatarInit" => "0x0",
                "MatchPlayers" => "0x4C869DC"
            ],
            'settings' => [
                'version' => '1.0.7-FFProduct',
                'last_update' => time(),
                'maintenance_mode' => false
            ]
        ];
        file_put_contents(DB_FILE, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    }
}

// Read database
function readDB() {
    initDatabase();
    return json_decode(file_get_contents(DB_FILE), true);
}

// Write database
function writeDB($data) {
    $data['settings']['last_update'] = time();
    file_put_contents(DB_FILE, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

// AES-256-CBC encryption
function encrypt_data($data, $key) {
    $iv = openssl_random_pseudo_bytes(16);
    $encrypted = openssl_encrypt($data, 'AES-256-CBC', hex2bin($key), OPENSSL_RAW_DATA, $iv);
    return base64_encode($iv . $encrypted);
}

function decrypt_data($encrypted, $key) {
    $data = base64_decode($encrypted);
    if (strlen($data) < 16) return false;
    $iv = substr($data, 0, 16);
    $encrypted_text = substr($data, 16);
    $result = openssl_decrypt($encrypted_text, 'AES-256-CBC', hex2bin($key), OPENSSL_RAW_DATA, $iv);
    return $result;
}

// Generate key with MONITE- prefix
function generateKey() {
    $prefix = 'MONITE-';
    $random = bin2hex(openssl_random_pseudo_bytes(12));
    return $prefix . strtoupper(substr($random, 0, 8) . '-' . substr($random, 8, 8) . '-' . substr($random, 16, 8));
}

// Get request method and endpoint
$method = $_SERVER['REQUEST_METHOD'];
$endpoint = $_GET['endpoint'] ?? $_GET['action'] ?? '';

// Handle requests
switch ($endpoint) {
    
    // ═══════════════════════════════════════
    // KEY MANAGEMENT
    // ═══════════════════════════════════════
    
    case 'generate_key':
    case 'add_key':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $db = readDB();
            
            $key = [
                'key' => generateKey(),
                'version_name' => $input['version_name'] ?? $input['name'] ?? 'OB53-Free',
                'created_at' => time(),
                'expires_at' => time() + (($input['expiry_days'] ?? $input['duration_days'] ?? 30) * 86400),
                'active' => true,
                'usage_count' => 0,
                'last_used' => null
            ];
            
            $db['keys'][] = $key;
            writeDB($db);
            
            echo json_encode(['success' => true, 'key' => $key['key'], 'message' => 'Key created!']);
        }
        break;
    
    case 'list_keys':
        if ($method === 'GET') {
            $db = readDB();
            echo json_encode(['success' => true, 'keys' => $db['keys']]);
        }
        break;
    
    case 'delete_key':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $key_to_delete = $input['key'] ?? '';
            $db = readDB();
            
            foreach ($db['keys'] as $i => $k) {
                if ($k['key'] === $key_to_delete) {
                    unset($db['keys'][$i]);
                    $db['keys'] = array_values($db['keys']);
                    writeDB($db);
                    echo json_encode(['success' => true, 'message' => 'Key deleted!']);
                    exit;
                }
            }
            echo json_encode(['success' => false, 'message' => 'Key not found']);
        }
        break;
    
    case 'extend_key':
    case 'update_key_expiry':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $key_to_update = $input['key'] ?? '';
            $days = max(1, (int)($input['days'] ?? $input['duration_days'] ?? 30));
            $db = readDB();
            
            foreach ($db['keys'] as $i => &$k) {
                if ($k['key'] === $key_to_update) {
                    $k['expires_at'] = max($k['expires_at'], time()) + ($days * 86400);
                    writeDB($db);
                    echo json_encode(['success' => true, 'message' => "Extended {$days} days!"]);
                    exit;
                }
            }
            echo json_encode(['success' => false, 'message' => 'Key not found']);
        }
        break;
    
    // ═══════════════════════════════════════
    // OFFSET MANAGEMENT
    // ═══════════════════════════════════════
    
    case 'get_offsets':
        if ($method === 'GET') {
            $db = readDB();
            echo json_encode(['success' => true, 'offsets' => $db['offsets'], 'total' => count($db['offsets'])]);
        }
        break;
    
    case 'save_offsets':
    case 'update_all_offsets':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $offsets = $input['offsets'] ?? [];
            
            if (empty($offsets)) {
                echo json_encode(['success' => false, 'message' => 'No offsets provided']);
                exit;
            }
            
            $db = readDB();
            foreach ($offsets as $name => $value) {
                $db['offsets'][$name] = $value;
            }
            writeDB($db);
            echo json_encode(['success' => true, 'message' => 'Offsets saved!']);
        }
        break;
    
    case 'update_offset':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $name = $input['name'] ?? '';
            $value = $input['value'] ?? '0x0';
            $db = readDB();
            
            $db['offsets'][$name] = $value;
            writeDB($db);
            echo json_encode(['success' => true, 'message' => 'Offset updated!']);
        }
        break;
    
    case 'system_info':
        if ($method === 'GET') {
            $db = readDB();
            $activeKeys = count(array_filter($db['keys'], function($k) {
                return $k['active'] && $k['expires_at'] > time();
            }));
            echo json_encode([
                'success' => true,
                'total_keys' => count($db['keys']),
                'active_keys' => $activeKeys,
                'total_offsets' => count($db['offsets']),
                'version' => $db['settings']['version'],
                'last_update' => $db['settings']['last_update']
            ]);
        }
        break;

    // ═══════════════════════════════════════
    // 5 MONITE API ENDPOINTS
    // ═══════════════════════════════════════
    
    case 'auth':
        if ($method === 'POST') {
            $encrypted_input = file_get_contents('php://input');
            $decrypted = decrypt_data($encrypted_input, SECRET_KEY);
            
            if ($decrypted === false) {
                header('Content-Type: text/plain');
                echo encrypt_data(json_encode(['success' => false, 'message' => 'Decryption failed']), SECRET_KEY);
                break;
            }
            
            $input = json_decode($decrypted, true);
            $client_key = $input['key'] ?? '';
            $db = readDB();
            
            $valid = false;
            $key_info = null;
            
            foreach ($db['keys'] as $i => $k) {
                if ($k['key'] === $client_key && $k['active'] && $k['expires_at'] > time()) {
                    $valid = true;
                    $key_info = $k;
                    // Update usage
                    $db['keys'][$i]['last_used'] = time();
                    $db['keys'][$i]['usage_count'] = ($db['keys'][$i]['usage_count'] ?? 0) + 1;
                    writeDB($db);
                    break;
                }
            }
            
            if ($valid) {
                $response = [
                    'success' => true,
                    'key' => $key_info['key'],
                    'version_name' => '1.0.7-FFProduct',
                    'version' => time(),
                    'expires_at' => $key_info['expires_at'],
                    'message' => 'Login successful'
                ];
            } else {
                $response = ['success' => false, 'message' => 'Invalid or expired key'];
            }
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    case 'offsets':
        if ($method === 'POST') {
            $encrypted_input = file_get_contents('php://input');
            $decrypted = decrypt_data($encrypted_input, SECRET_KEY);
            
            if ($decrypted === false) {
                $response = ['success' => false, 'message' => 'Decryption failed'];
            } else {
                $db = readDB();
                $response = ['success' => true, 'offsets' => $db['offsets']];
            }
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    case 'check':
        if ($method === 'POST') {
            $db = readDB();
            $response = [
                'success' => true,
                'allowed' => !($db['settings']['maintenance_mode'] ?? false)
            ];
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    case 'check_openid':
        if ($method === 'POST') {
            $encrypted_input = file_get_contents('php://input');
            
            if (!empty($encrypted_input)) {
                $decrypted = decrypt_data($encrypted_input, SECRET_KEY);
                if ($decrypted !== false) {
                    $input = json_decode($decrypted, true);
                    $open_id = $input['open_id'] ?? '';
                    $response = ['status' => 'exists', 'udid' => 'DEVICE-' . strtoupper(substr(md5($open_id), 0, 16))];
                } else {
                    $response = ['status' => 'error', 'message' => 'Decryption failed'];
                }
            } else {
                $response = ['status' => 'new', 'url' => 'https://khanhduyapi.free.nf/'];
            }
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    case 'request_openid':
    case 'request_open_id':
        if ($method === 'POST') {
            $response = [
                'open_id' => 'OPEN-' . strtoupper(bin2hex(openssl_random_pseudo_bytes(12))),
                'url' => 'https://khanhduyapi.free.nf/'
            ];
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    default:
        echo json_encode([
            'success' => false,
            'message' => 'Invalid endpoint. Available: generate_key, list_keys, delete_key, extend_key, get_offsets, save_offsets, update_offset, system_info, auth, offsets, check, check_openid, request_openid'
        ]);
        break;
}
