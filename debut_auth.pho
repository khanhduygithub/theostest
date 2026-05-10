<?php
$SECRET_KEY = 'A1B2C3D4E5F607182933A4B5C6D7E8F9012233445667788899AABBCCDDEEFF001';

// Đọc key từ database
$db = json_decode(file_get_contents(__DIR__ . '/database.json'), true);
$key = $db['keys'][0]['key'] ?? 'MONITE_test';

// Log request từ app (nếu có)
$rawInput = file_get_contents('php://input');
if (!empty($rawInput)) {
    file_put_contents(__DIR__ . '/debug.log', 
        "[" . date('Y-m-d H:i:s') . "] REQUEST RECEIVED (len: " . strlen($rawInput) . ")\n", 
        FILE_APPEND);
    
    // Giải mã thử
    $decoded = base64_decode($rawInput);
    $iv = substr($decoded, 0, 16);
    $cipher = substr($decoded, 16);
    $result = openssl_decrypt($cipher, 'AES-256-CBC', hex2bin($SECRET_KEY), OPENSSL_RAW_DATA, $iv);
    
    if ($result) {
        file_put_contents(__DIR__ . '/debug.log', 
            "[" . date('Y-m-d H:i:s') . "] DECRYPT OK: " . $result . "\n", 
            FILE_APPEND);
    } else {
        file_put_contents(__DIR__ . '/debug.log', 
            "[" . date('Y-m-d H:i:s') . "] DECRYPT FAILED\n", 
            FILE_APPEND);
    }
}

// Test API auth trực tiếp
$payload = json_encode([
    'id' => 'TEST-' . time(),
    'key' => $key,
    'game' => 'Free Fire',
    'game_uid' => '00006',
    'timestamp' => time(),
    'current_update' => '1.0.7-FFProduct'
]);

$iv = openssl_random_pseudo_bytes(16);
$encrypted = openssl_encrypt($payload, 'AES-256-CBC', hex2bin($SECRET_KEY), OPENSSL_RAW_DATA, $iv);
$data = base64_encode($iv . $encrypted);

$ch = curl_init('https://khanhduyapi.free.nf/api.php?endpoint=auth');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: text/plain']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
$response = curl_exec($ch);
curl_close($ch);

$decoded = base64_decode($response);
$iv = substr($decoded, 0, 16);
$cipher = substr($decoded, 16);
$result = openssl_decrypt($cipher, 'AES-256-CBC', hex2bin($SECRET_KEY), OPENSSL_RAW_DATA, $iv);

$json = json_decode($result, true);

echo "=== DEBUG INFO ===\n\n";
echo "1. Key in database: " . $key . "\n";
echo "2. Key length: " . strlen($key) . "\n\n";
echo "3. API Response:\n" . $result . "\n\n";
echo "4. Fields check:\n";
echo "   success: " . ($json['success'] ?? 'MISSING') . "\n";
echo "   key: " . ($json['key'] ?? 'MISSING') . "\n";
echo "   version_name: " . ($json['version_name'] ?? 'MISSING') . "\n";
echo "   version: " . ($json['version'] ?? 'MISSING') . "\n";
echo "   expires_at: " . ($json['expires_at'] ?? 'MISSING') . "\n";
echo "   offsets: " . (isset($json['offsets']) ? count($json['offsets']) . ' items' : 'MISSING') . "\n";

// Kiểm tra offset có giá trị lạ không
if (isset($json['offsets'])) {
    echo "\n5. First 5 offsets:\n";
    $count = 0;
    foreach ($json['offsets'] as $name => $value) {
        if ($count++ >= 5) break;
        echo "   $name: $value\n";
    }
}
?>
