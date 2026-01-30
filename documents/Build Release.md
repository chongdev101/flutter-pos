## Build APK (ใช้กับ POS / sideload)

flutter build apk \
--release \
--flavor secure \
--dart-define=SECURE_BUILD=true

## Build AAB (ถ้าใช้ Play Store / Managed Play)
flutter build appbundle \
    --release \
    --flavor secure \
    --dart-define=SECURE_BUILD=true