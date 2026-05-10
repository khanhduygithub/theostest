<?php
// Monite API Manager - Complete
// Version: 2.1

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
                'get_main' => '0x0',
                'get_transform' => '0x0',
                'get_transformNode' => '0x0',
                'WorldToViewpoint' => '0x0',
                'get_position' => '0x0',
                'Team' => '0x0',
                'Local' => '0x0',
                'get_HP' => '0x0',
                'get_maxHP' => '0x0',
                'get_IsDieing' => '0x0',
                'get_IsVisible' => '0x0',
                'GetLocalPlayer' => '0x0',
                'CurrentMatch' => '0x0',
                'Camera_main' => '0x0',
                'GetRotation' => '0x0',
                'get_isLocalTeam' => '0x0',
                'get_IsSighting' => '0x0',
                'get_IsFiring' => '0x0',
                'WorldToScreenPoint' => '0x0',
                'GetHeadPositions' => '0x0',
                'Component_GetTransform' => '0x0',
                'GetForward' => '0x0',
                'Player_GetHeadCollider' => '0x0',
                'Transform_GetPosition' => '0x0',
                'GetAnimator' => '0x0',
                'Physics_Raycast' => '0x0',
                'set_aim' => '0x0',
                'HipPosition' => '0x0',
                'LeftShoulderPosition' => '0x0',
                'RightShoulderPosition' => '0x0',
                'LeftAnklePosition' => '0x0',
                'RightAnklePosition' => '0x0',
                'LeftToePosition' => '0x0',
                'RightToePosition' => '0x0',
                'LeftHandPosition' => '0x0',
                'RightHandPosition' => '0x0',
                'RightForeArmPosition' => '0x0',
                'LeftForeArmPosition' => '0x0',
                'CameraMain' => '0x0',
                'IsClientBot' => '0x0',
                'IsAvatarInit' => '0x0',
                'MatchPlayers' => '0x0'
            ],
            'settings' => [
                'version' => '1.0.0',
                'last_update' => time()
            ]
        ];
        file_put_contents(DB_FILE, json_encode($data, JSON_PRETTY_PRINT));
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
    file_put_contents(DB_FILE, json_encode($data, JSON_PRETTY_PRINT));
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

// Generate key with MONITE_ prefix (32 chars total)
function generateKey($length = 32) {
    $prefix = 'MONITE_';
    $remaining = $length - strlen($prefix);
    $characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    $key = $prefix;
    for ($i = 0; $i < $remaining; $i++) {
        $key .= $characters[rand(0, strlen($characters) - 1)];
    }
    return $key;
}

// Get request method and endpoint
$method = $_SERVER['REQUEST_METHOD'];
$endpoint = $_GET['endpoint'] ?? '';

// Handle requests
switch ($endpoint) {
    
    // ========== QUẢN LÝ KEY ==========
    
    case 'add_key':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $db = readDB();
            
            $key = [
                'key' => generateKey(32),
                'name' => $input['name'] ?? 'Unnamed Key',
                'created_at' => time(),
                'expires_at' => time() + ($input['duration_days'] ?? 30) * 86400,
                'status' => 'active'
            ];
            
            $db['keys'][] = $key;
            writeDB($db);
            
            echo json_encode([
                'success' => true,
                'key' => $key
            ]);
        }
        break;
    
    case 'list_keys':
        if ($method === 'GET') {
            $db = readDB();
            echo json_encode([
                'success' => true,
                'keys' => $db['keys']
            ]);
        }
        break;
    
    case 'delete_key':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $db = readDB();
            
            $key_to_delete = $input['key'] ?? '';
            $new_keys = array_filter($db['keys'], function($k) use ($key_to_delete) {
                return $k['key'] !== $key_to_delete;
            });
            
            $db['keys'] = array_values($new_keys);
            writeDB($db);
            
            echo json_encode([
                'success' => true,
                'message' => 'Key deleted successfully'
            ]);
        }
        break;
    
    case 'update_key_expiry':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $db = readDB();
            
            $key_to_update = $input['key'] ?? '';
            $new_duration_days = $input['duration_days'] ?? 30;
            
            foreach ($db['keys'] as &$k) {
                if ($k['key'] === $key_to_update) {
                    $k['expires_at'] = time() + $new_duration_days * 86400;
                    break;
                }
            }
            
            writeDB($db);
            
            echo json_encode([
                'success' => true,
                'message' => 'Key expiry updated successfully'
            ]);
        }
        break;
    
    // ========== QUẢN LÝ OFFSETS ==========
    
    case 'get_offsets':
        if ($method === 'GET') {
            $db = readDB();
            echo json_encode([
                'success' => true,
                'offsets' => $db['offsets']
            ]);
        }
        break;
    
    case 'update_offset':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $db = readDB();
            
            $offset_name = $input['name'] ?? '';
            $offset_value = $input['value'] ?? '0x0';
            
            if (isset($db['offsets'][$offset_name])) {
                $db['offsets'][$offset_name] = $offset_value;
                writeDB($db);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Offset updated successfully'
                ]);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'Offset not found'
                ]);
            }
        }
        break;
    
    case 'update_all_offsets':
        if ($method === 'POST') {
            $input = json_decode(file_get_contents('php://input'), true);
            $db = readDB();
            
            if (isset($input['offsets']) && is_array($input['offsets'])) {
                foreach ($input['offsets'] as $name => $value) {
                    if (isset($db['offsets'][$name])) {
                        $db['offsets'][$name] = $value;
                    }
                }
                writeDB($db);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'All offsets updated successfully'
                ]);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'Invalid offset data'
                ]);
            }
        }
        break;
    
    case 'system_info':
        if ($method === 'GET') {
            $db = readDB();
            echo json_encode([
                'success' => true,
                'total_keys' => count($db['keys']),
                'active_keys' => count(array_filter($db['keys'], function($k) {
                    return $k['status'] === 'active' && $k['expires_at'] > time();
                })),
                'version' => $db['settings']['version'],
                'last_update' => $db['settings']['last_update']
            ]);
        }
        break;

    // ========== 5 API MONITE ==========
    
    // API 1: Auth
    case 'auth':
        if ($method === 'POST') {
            $encrypted_input = file_get_contents('php://input');
            $decrypted = decrypt_data($encrypted_input, SECRET_KEY);
            
            if ($decrypted === false) {
                header('Content-Type: text/plain');
                echo encrypt_data(json_encode([
                    'success' => false,
                    'message' => 'Decryption failed'
                ]), SECRET_KEY);
                break;
            }
            
            $input = json_decode($decrypted, true);
            $client_key = $input['key'] ?? '';
            $db = readDB();
            
            $valid = false;
            $key_info = null;
            
            foreach ($db['keys'] as $k) {
                if ($k['key'] === $client_key && $k['status'] === 'active') {
                    if ($k['expires_at'] > time()) {
                        $valid = true;
                        $key_info = $k;
                        break;
                    }
                }
            }
            
            if ($valid) {
                $response = [
                    'success' => true,
                    'key' => $key_info['key'],
                    'version_name' => '1.0.7-FFProduct',
                    'version' => time(),
                    'expires_at' => $key_info['expires_at'],
                    'offsets' => $db['offsets']
                ];
            } else {
                $response = [
                    'success' => false,
                    'message' => 'Invalid or expired key'
                ];
            }
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    // API 2: Offsets
    case 'offsets':
        if ($method === 'POST') {
            $encrypted_input = file_get_contents('php://input');
            $decrypted = decrypt_data($encrypted_input, SECRET_KEY);
            
            if ($decrypted === false) {
                $response = ['success' => false, 'message' => 'Decryption failed'];
            } else {
                $db = readDB();
                $response = [
                    'success' => true,
                    'offsets' => $db['offsets']
                ];
            }
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    // API 3: Check Access
    case 'check':
        if ($method === 'POST') {
            $response = [
                'success' => true,
                'allowed' => true
            ];
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    // API 4: Check OpenID
    case 'check_openid':
        if ($method === 'POST') {
            $encrypted_input = file_get_contents('php://input');
            
            if (!empty($encrypted_input)) {
                $decrypted = decrypt_data($encrypted_input, SECRET_KEY);
                if ($decrypted !== false) {
                    $input = json_decode($decrypted, true);
                    $open_id = $input['open_id'] ?? '';
                    
                    $response = [
                        'status' => 'exists',
                        'udid' => 'DEVICE-' . substr(md5($open_id), 0, 16)
                    ];
                } else {
                    $response = ['status' => 'error', 'message' => 'Decryption failed'];
                }
            } else {
                $response = ['status' => 'error', 'message' => 'Empty request'];
            }
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    // API 5: Request OpenID
    case 'request_openid':
        if ($method === 'POST') {
            $response = [
                'open_id' => 'OPEN-' . bin2hex(openssl_random_pseudo_bytes(16)),
                'url' => 'https://khanhduyapi.free.nf/verify-udid'
            ];
            
            header('Content-Type: text/plain');
            echo encrypt_data(json_encode($response), SECRET_KEY);
        }
        break;
    
    default:
        echo json_encode([
            'success' => false,
            'message' => 'Invalid endpoint'
        ]);
        break;
}
?>
