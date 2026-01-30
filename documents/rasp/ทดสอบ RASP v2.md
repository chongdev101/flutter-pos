# RASP Test Cases v2

## 🔧 Setup
```bash
flutter clean
flutter pub get

# 1. Clear app data
adb shell pm clear com.chongdev.pos_android

# 2. Build และติดตั้ง
flutter build apk --dart-define=FLAVOR=secure --dart-define=SECURE_BUILD=true --flavor secure --release
adb install build/app/outputs/flutter-apk/app-secure-release.apk

# 3. ดู logs
adb logcat -c  # Clear logs
adb logcat | grep -E "flutter|🔧|⚠️|🔒|🚨|✅"
```

## 🧪 Test Cases

### Test 1: เปิดแอพ (Developer Mode Enabled)
- **Action**: เปิด Developer Mode → เปิดแอพ
- **Expected**: modal ขึ้น ✅
- **Result**: ⬜

### Test 2: ปิดแอพ (Developer Mode Enabled)
- **Action**: กด OK → แอพปิด → เปิดแอพใหม่
- **Expected**: modal ขึ้น ✅ (RASP detect ใหม่)
- **Result**: ⬜

### Test 3: ปิด Developer Mode
- **Action**: ปิด Developer Mode → เปิดแอพ
- **Expected**: modal ไม่ขึ้น ✅ (RASP ไม่ detect threat)
- **Result**: ⬜

### Test 4: เปิด Developer Mode อีกครั้ง
- **Action**: เปิด Developer Mode → เปิดแอพ
- **Expected**: modal ขึ้น ✅
- **Result**: ⬜

---

## 🔄 Flow

```
เปิดแอพ:
1. Check storage → ถ้ามี recoverable threat → clear storage
2. Init RASP
3. RASP scan → ถ้ามี threat → save storage + show modal
4. ถ้าไม่มี threat → ไม่ทำอะไร

Resume:
1. Clear recoverable threat จาก storage
2. Reset handler
3. Restart RASP → ถ้ามี threat → save + show modal
```
