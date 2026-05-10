<?php
header('Content-Type: text/plain');

// Test giải mã + phản hồi
$SECRET_KEY = 'A1B2C3D4E5F607182933A4B5C6D7E8F9012233445667788899AABBCCDDEEFF001';

// Tạo phản hồi giả
$response = [
    'success' => true,
    'key' => 'DB5Y2wEs6ErdAgcURtIXZTNraSsk0PII',
    'version_name' => '1.0.7-FFProduct',
    'version' => time(),
    'expires_at' => strtotime('2026-06-09'),
    'offsets' => ['get_main' => '0x123', 'Team' => '0x456']
];

// Mã hóa
$iv = openssl_random_pseudo_bytes(16);
$encrypted = openssl_encrypt(json_encode($response), 'AES-256-CBC', hex2bin($SECRET_KEY), OPENSSL_RAW_DATA, $iv);
echo base64_encode($iv . $encrypted);
?>
