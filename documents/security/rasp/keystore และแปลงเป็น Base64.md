# 1. ดึง SHA256 จาก keystore และแปลงเป็น Base64
./scripts/convert_sha256.sh --from-keystore android/app/pos-release-key.jks pos-key

# 2. นำ Base64 ไปใส่ใน rasp_config.dart
#    signingCertHashes: ['QZgiggrbYcogNK/7LvaZ3+dEAi961cnKs6RBy92uHPg=']

# 3. Build secure flavor
./scripts/build.sh secure

# 4. ติดตั้งและทดสอบ
adb install build/app/outputs/flutter-apk/app-secure-release.apk
