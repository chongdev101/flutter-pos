# 1. Clean ทุกอย่าง
flutter clean
cd android && ./gradlew clean && cd ..

# 2. Get dependencies
flutter pub get

# 3. Build secure flavor
flutter build apk --dart-define=FLAVOR=secure --flavor secure --release

# 4. ตรวจสอบว่าไฟล์ถูกต้อง
ls -lh build/app/outputs/flutter-apk/


## Step 3: ติดตั้งและตรวจสอบ
```bash
# ถอนแอปเก่าออกก่อน
adb uninstall com.chongdev.pos_android
adb uninstall com.chongdev.pos_android.dev

# ติดตั้งแอปใหม่
adb install build/app/outputs/flutter-apk/app-secure-release.apk

# ดู logs
adb logcat | grep -E "flutter|🔧|⚠️|🔒"
```

