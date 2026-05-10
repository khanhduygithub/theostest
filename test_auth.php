<?php
$SECRET_KEY = 'A1B2C3D4E5F607182933A4B5C6D7E8F9012233445667788899AABBCCDDEEFF001';

// Đọc key từ database
$db = json_decode(file_get_contents(__DIR__ . '/database.json'), true);
$key = $db['keys'][0]['key'] ?? 'MONITE_test';

$payload = json_encode([
    'id' => 'TEST-123',
    'key' => $key,
    'game' => 'Free Fire',
    'game_uid' => '00006',
    'timestamp' => time(),
    'current_update' => '1.0.7-FFProduct'
]);

// Mã hóa
$iv = openssl_random_pseudo_bytes(16);
$encrypted = openssl_encrypt($payload, 'AES-256-CBC', hex2bin($SECRET_KEY), OPENSSL_RAW_DATA, $iv);
$data = base64_encode($iv . $encrypted);

// Gửi đến API auth
$ch = curl_init('https://khanhduyapi.free.nf/api.php?endpoint=auth');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: text/plain']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
$response = curl_exec($ch);
curl_close($ch);

// Giải mã response
$decoded = base64_decode($response);
$iv = substr($decoded, 0, 16);
$cipher = substr($decoded, 16);
$result = openssl_decrypt($cipher, 'AES-256-CBC', hex2bin($SECRET_KEY), OPENSSL_RAW_DATA, $iv);

echo "=== API RESPONSE ===\n";
echo $result;
echo "\n=== CHECK FIELDS ===\n";

$json = json_decode($result, true);
echo "success: " . (isset($json['success']) ? ($json['success'] ? '✅ YES' : '❌ FALSE') : '❌ MISSING') . "\n";
echo "key: " . (isset($json['key']) ? '✅ YES' : '❌ MISSING') . "\n";
echo "version_name: " . (isset($json['version_name']) ? '✅ YES' : '❌ MISSING') . "\n";
echo "version: " . (isset($json['version']) ? '✅ YES' : '❌ MISSING') . "\n";
echo "expires_at: " . (isset($json['expires_at']) ? '✅ YES' : '❌ MISSING') . "\n";
?>
