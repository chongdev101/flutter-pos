# วิธีการทดสอบ RASP บนเครื่องจริง

## **คำสั่ง Build แต่ละ Flavor**

### **Development (ไม่เปิด RASP):**
```bash
flutter build apk \
  --dart-define-from-file=config/dev.json \
  --flavor dev \
  --release
```

### **Production (เปิด RASP):**
```bash
flutter build apk \
  --dart-define-from-file=config/secure.json \
  --flavor secure \
  --release
```

หรือใช้ build script:
```bash
chmod +x scripts/build.sh
./scripts/build.sh secure
```

---

## **Step-by-Step การ Build และติดตั้ง**

```bash
# 1. Clean ทุกอย่าง
flutter clean
cd android && ./gradlew clean && cd ..

# 2. Get dependencies
flutter pub get

# 3. Build secure flavor
flutter build apk \
  --dart-define=FLAVOR=secure \
  --dart-define=SECURE_BUILD=true \
  --flavor secure \
  --release

# 4. ตรวจสอบว่าไฟล์ถูกต้อง
ls -lh build/app/outputs/flutter-apk/


# 5. ถอนแอปเก่าออกก่อน
adb uninstall com.chongdev.pos_android
adb uninstall com.chongdev.pos_android.dev

# 5.1 Clear app data ก่อนทดสอบ
adb shell pm clear com.chongdev.pos_android

# 6. ติดตั้งแอปใหม่
adb install build/app/outputs/flutter-apk/app-secure-release.apk

# 7. ดู logs
adb logcat -c  # Clear logs
adb logcat | grep -E "flutter|🔧|⚠️|🔒|🚨|✅"
```

---

## **ผลลัพธ์ที่ต้องการเห็นใน Logs**

### **✅ RASP ทำงานปกติ (ไม่มี threat):**
```
🔧 Build Flavor: secure
🔧 Is Secure: true
🔒 Starting RASP initialization...
🔒 RaspService: Initializing...
✅ RaspService: Initialized successfully
```

### **⚠️ เมื่อตรวจพบ Developer Options:**
```
🚨 Threat Detected: RaspThreatType.debug
   → Showing modal...
```

### **🚫 เมื่อตรวจพบ Root/Hook:**
```
🚨 Threat Detected: RaspThreatType.hook
   → Critical threat! Saving to storage...
   → Showing modal...
```

### **❌ เมื่อตรวจพบ App Integrity Failed:**
```
🚨 Threat Detected: RaspThreatType.appIntegrity
   → Critical threat! Saving to storage...
   → Showing modal...
```

---

## **การทดสอบ Threats แต่ละประเภท**

### **1. Developer Options / USB Debugging:**
- เปิด Developer Options
- เปิด USB Debugging
- เปิดแอป → ควรเห็น modal "Debug Detected"
- ปิด Developer Options
- เปิดแอปใหม่ → ไม่ควรมี modal (recoverable)

### **2. Emulator Detection:**
```bash
# รันบน Android Emulator
flutter run --dart-define=FLAVOR=secure --dart-define=SECURE_BUILD=true --flavor secure --release
```
→ ควรเห็น modal "Simulator Detected"

### **3. Root Detection:**
- ทดสอบบนเครื่องที่ root แล้ว
- เปิดแอป → ควรเห็น modal "Device Compromised"
- แอปจะ block ถาวร (unrecoverable)

### **4. App Integrity:**
- ถ้า SHA256 ไม่ตรง → modal "App Integrity Failed"
- ตรวจสอบ SHA256:
```bash
./scripts/convert_sha256.sh --from-keystore /Users/chongdev/workspace/flutter-keys/pos-release.jks pos-release
```

---

## **หมายเหตุสำคัญ**

### **🧪 Testing Mode:**
- `unofficialStore` threat ถูก **ignore** เพื่อให้ติดตั้งผ่าน ADB ได้
- ดูที่ `lib/core/security/rasp/rasp_threat_handler.dart`:
```dart
// 🧪 TESTING: Ignore unofficialStore (because we install via ADB)
// TODO: Remove this in production!
if (type == RaspThreatType.unofficialStore) {
  return;
}
```

### **🚀 Production Build:**
- ลบ code ข้างต้นออกก่อน deploy
- หรือเพิ่มเงื่อนไข:
```dart
if (type == RaspThreatType.unofficialStore && !AppBuild.isProduction) {
  return;
}
```

---

## **Troubleshooting**

### **ปัญหา: App Integrity Failed ทุกครั้ง**
**สาเหตุ:** SHA256 ไม่ตรงกับ keystore

**วิธีแก้:**
1. ดึง SHA256 จาก keystore:
```bash
keytool -list -v -keystore /path/to/keystore.jks -alias your-alias | grep SHA256
```

2. แปลงเป็น Base64:
```bash
./scripts/convert_sha256.sh "49:6A:E8:A9:..."
```

3. อัพเดทใน `rasp_config.dart` และ `talsec_config.json`

### **ปัญหา: Modal ไม่ขึ้นแม้มี threat**
**สาเหตุ:** `AppBuild.isSecure = false`

**วิธีแก้:**
- ตรวจสอบว่าใช้ `--dart-define=SECURE_BUILD=true`
- ดู log: `🔧 Is Secure: true`

### **ปัญหา: RASP ไม่ทำงานเลย**
**สาเหตุ:** Build เป็น dev flavor

**วิธีแก้:**
- ตรวจสอบว่าใช้ `--flavor secure`
- ดู log: `🔧 Build Flavor: secure`

---

## **คำแนะนำเพิ่มเติม**

1. **ทดสอบบนเครื่องจริงเสมอ** (Emulator จะถูก block ทันที)
2. **ปิด Developer Options** เมื่อทดสอบ normal flow
3. **ใช้ release build เท่านั้น** (debug build อาจมี behavior ต่าง)
4. **บันทึก logs** เพื่อ audit และ troubleshoot

