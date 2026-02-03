# RASP (Runtime Application Self-Protection) Implementation Guide

## 📋 สารบัญ
1. [ภาพรวม](#ภาพรวม)
2. [สถาปัตยกรรม](#สถาปัตยกรรม)
3. [การตรวจจับภัยคุกคาม](#การตรวจจับภัยคุกคาม)
4. [ขั้นตอนการติดตั้งและทดสอบ](#ขั้นตอนการติดตั้งและทดสอบ)
5. [คู่มือสำหรับ QA](#คู่มือสำหรับ-qa)
6. [คู่มือสำหรับ Production](#คู่มือสำหรับ-production)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 ภาพรวม

RASP เป็นระบบป้องกันความปลอดภัยแบบ real-time ที่ตรวจจับภัยคุกคามต่างๆ เช่น:
- การติดตั้งบนอุปกรณ์ที่ root/jailbreak
- การเปิดใช้งาน Developer Options
- การติดตั้งผ่าน unofficial store
- การตรวจสอบความสมบูรณ์ของแอป (app integrity)
- การตรวจจับ emulator/simulator

### 📦 Dependencies
- `freerasp: 6.11.0` - Core RASP library
- `shared_preferences: ^2.2.3` - Local storage

---

## 🏗️ สถาปัตยกรรม

```
lib/core/security/
├── rasp/
│   ├── config/
│   │   └── rasp_config.dart          # การตั้งค่า RASP
│   ├── models/
│   │   └── rasp_threat_type.dart     # ประเภทภัยคุกคาม
│   ├── services/
│   │   ├── rasp_service.dart         # Core service
│   │   └── rasp_threat_handler.dart  # จัดการภัยคุกคาม
│   └── storage/
│       └── security_storage.dart     # บันทึกข้อมูลภัยคุกคาม
└── widgets/
    └── security_alert_dialog.dart    # UI แสดงคำเตือน
```

---

## 🛡️ การตรวจจับภัยคุกคาม

### 1. **Critical Threats** (ไม่สามารถใช้งานแอปได้)

| Threat Type | คำอธิบาย | ผลกระทบ |
|------------|---------|---------|
| `privilegedAccess` | อุปกรณ์ถูก root/jailbreak | 🔴 Block |
| `appIntegrity` | แอปถูกแก้ไขหรือ re-sign | 🔴 Block |
| `simulator` | ทำงานบน emulator | 🔴 Block |
| `hooks` | มี debugging hook | 🔴 Block |

### 2. **Recoverable Threats** (เตือนผู้ใช้แต่ยังใช้งานได้)

| Threat Type | คำอธิบาย | ผลกระทบ |
|------------|---------|---------|
| `debug` | เปิด Developer Options | 🟡 Warning |
| `deviceBinding` | เปลี่ยนอุปกรณ์ | 🟡 Warning |

### 3. **Non-Critical Threats** (ไม่แสดงผล)

| Threat Type | คำอธิบาย | ผลกระทบ |
|------------|---------|---------|
| `unofficialStore` | ติดตั้งผ่าน ADB/APK | 🟢 Ignore (Development) |
| `obfuscationIssues` | ปัญหา code obfuscation | 🟢 Ignore |

---

## 🚀 ขั้นตอนการติดตั้งและทดสอบ

### **Step 1: สร้าง Keystore และ SHA256 Certificate**

```bash
# 1. สร้าง keystore (ถ้ายังไม่มี)
keytool -genkey -v \
  -keystore /Users/chongdev/workspace/flutter-keys/pos-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias <aliasName>

# 2. ดู SHA256 certificate fingerprint
keytool -list -v \
  -keystore /Users/chongdev/workspace/flutter-keys/pos-release.jks \
  -alias pos-release | grep SHA256

# ผลลัพธ์:
# SHA256: 49:6A:E8:A9:XXX...
```

### **Step 2: ตั้งค่า Signing Configuration**

สร้างไฟล์ `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=<aliasName>
storeFile=/path/to/your/keystore.jks
```

### **Step 3: อัพเดท SHA256 ใน Configuration Files**

#### `lib/core/security/rasp/config/rasp_config.dart`
```dart
static const String _releaseSigningCertHash = '<SHA256_KEY>';
```

#### `assets/security/talsec_config.json`
```json
{
  "androidConfig": {
    "signingCertHashes": [
      "<SHA256_KEY>"
    ]
  }
}
```

### **Step 4: Build และติดตั้ง**

```bash
# Build release APK
flutter build apk --release --flavor secure

# ติดตั้งบนอุปกรณ์
adb install -r build/app/outputs/flutter-apk/app-secure-release.apk
```

---

## 🧪 คู่มือสำหรับ QA

### **การทดสอบ RASP Threats**

#### 1. **ทดสอบ Developer Options Detection**

```bash
# เปิด Developer Options บนอุปกรณ์
Settings > About Phone > Tap "Build Number" 7 times
Settings > Developer Options > Enable

# เปิดแอปและดู logs
adb logcat -c
adb logcat | grep -E "flutter|🔧|⚠️|🔒|🚨"
```

**ผลลัพธ์ที่ควรได้:**
```
🔧 Build Flavor: secure
🔧 Is Secure: true
🔒 Starting RASP initialization...
🔒 RaspService: Initializing...
✅ RaspService: Initialized successfully
🚨 Threat Detected: RaspThreatType.debug
   → Showing modal...
```

**สิ่งที่ต้องตรวจสอบ:**
- ✅ แสดง Security Alert Dialog
- ✅ Dialog แสดงข้อความ "Debug Detected"
- ✅ แสดง action: "Settings" และ "Continue"
- ✅ กด "Settings" เปิด Developer Options
- ✅ กด "Continue" ปิด dialog และใช้งานต่อได้

---

#### 2. **ทดสอบ App Integrity**

```bash
# Build debug APK (จะมี debug signing key)
flutter build apk --debug --flavor secure
adb install -r build/app/outputs/flutter-apk/app-secure-debug.apk
```

**ผลลัพธ์ที่ควรได้:**
```
🚨 Threat Detected: RaspThreatType.appIntegrity
   → Critical threat! Showing modal...
```

**สิ่งที่ต้องตรวจสอบ:**
- ✅ แสดง Security Alert Dialog
- ✅ Dialog แสดงข้อความ "App Integrity Violated"
- ✅ แสดงเฉพาะ action: "Exit App"
- ✅ กด "Exit App" ปิดแอป
- ⚠️ **ไม่สามารถใช้งานแอปได้ (Critical Threat)**

---

#### 3. **ทดสอบ Simulator Detection**

```bash
# รันบน iOS Simulator
flutter run --flavor secure -d "iPhone 15 Pro"

# หรือ Android Emulator
flutter run --flavor secure -d emulator-5554
```

**ผลลัพธ์ที่ควรได้:**
```
🚨 Threat Detected: RaspThreatType.simulator
   → Critical threat! Showing modal...
```

**สิ่งที่ต้องตรวจสอบ:**
- ✅ แสดง Security Alert Dialog
- ✅ Dialog แสดงข้อความ "Simulator Detected"
- ✅ แสดงเฉพาะ action: "Exit App"
- ⚠️ **ไม่สามารถใช้งานบน Simulator ได้**

---

#### 4. **ทดสอบ Root/Jailbreak Detection**

**Android (Root):**
```bash
# ติดตั้งแอปบนอุปกรณ์ที่ root แล้ว
adb install -r app-secure-release.apk
```

**iOS (Jailbreak):**
```bash
# ติดตั้งแอปบนอุปกรณ์ที่ jailbreak แล้ว
```

**ผลลัพธ์ที่ควรได้:**
```
🚨 Threat Detected: RaspThreatType.privilegedAccess
   → Critical threat! Showing modal...
```

**สิ่งที่ต้องตรวจสอบ:**
- ✅ แสดง Security Alert Dialog
- ✅ Dialog แสดงข้อความ "Device Compromised"
- ✅ แสดงเฉพาะ action: "Exit App"
- ⚠️ **ไม่สามารถใช้งานบนอุปกรณ์ที่ root/jailbreak ได้**

---

#### 5. **ทดสอบ Unofficial Store Detection**

```bash
# ติดตั้งผ่าน ADB (ไม่ใช่ Google Play Store)
adb install -r app-secure-release.apk
```

**ผลลัพธ์ที่ควรได้:**
```
🚨 Threat Detected: RaspThreatType.unofficialStore
   → Skipped (testing via ADB)  ← Development Mode
```

**สิ่งที่ต้องตรวจสอบ:**
- ✅ **Development Mode:** ไม่แสดง dialog (ignore threat)
- ⚠️ **Production Build:** แสดง dialog และ block แอป

---

### **Test Case Matrix**

| Test Case | Device Type | Expected Result | Priority |
|-----------|------------|-----------------|----------|
| Developer Options เปิด | Real Device | 🟡 Warning Dialog | High |
| Debug APK | Real Device | 🔴 Block App | Critical |
| Release APK (wrong signing) | Real Device | 🔴 Block App | Critical |
| Run on Emulator | Emulator | 🔴 Block App | High |
| Root Device | Rooted Device | 🔴 Block App | Critical |
| Install via ADB | Real Device | 🟢 Allow (Dev Mode) | Medium |
| Install via Play Store | Real Device | ✅ Normal | High |

---

## 🚀 คู่มือสำหรับ Production

### **Pre-Deployment Checklist**

#### 1. **ลบ Testing/Development Code**

ตรวจสอบและ**ลบ**โค้ดเหล่านี้ก่อน deploy:

```dart
// ❌ ลบ: rasp_threat_handler.dart
if (threat == RaspThreatType.unofficialStore) {
  _logger.d('   → Skipped (testing via ADB)');
  return;
}
```

#### 2. **ตรวจสอบ Configuration Files**

**`rasp_config.dart`:**
```dart
// ✅ ต้องใช้ release SHA256
static const String _releaseSigningCertHash = 'YOUR_RELEASE_SHA256';

// ✅ supportedStores ต้องระบุ Google Play Store
supportedStores: ['com.android.vending'],
```

**`talsec_config.json`:**
```json
{
  "androidStore": [
    "google_play"  // ✅ เฉพาะ Google Play Store
  ],
  "signingCertHashes": [
    "YOUR_RELEASE_SHA256"  // ✅ ต้องตรงกับ release keystore
  ]
}
```

#### 3. **Build Production APK**

```bash
# Clean build
flutter clean
flutter pub get

# Build release APK
flutter build apk --release --flavor secure

# หรือ build app bundle (แนะนำสำหรับ Google Play)
flutter build appbundle --release --flavor secure
```

#### 4. **ตรวจสอบ APK Signing**

```bash
# ตรวจสอบว่า APK ถูก sign ด้วย release key
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-secure-release.apk

# ดู SHA256 certificate
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-secure-release.apk | grep SHA256
```

**ผลลัพธ์ที่ต้องได้:**
```
SHA256: 49:6A:E8:A9:F6:7E:64:61:F3:00:EF:02:76:A4:DD:22:08:99:E4:A2:6E:62:74:76:E1:52:04:6D:CD:B6:B9:32
```

---

### **Production Deployment Steps**

#### **ขั้นตอนที่ 1: อัพโหลดไปยัง Google Play Console**

1. เข้า [Google Play Console](https://play.google.com/console)
2. เลือกแอป
3. Production > Create new release
4. อัพโหลด `app-secure-release.aab`
5. กรอก Release notes
6. Review and rollout

#### **ขั้นตอนที่ 2: ทดสอบบน Internal/Closed Testing**

```bash
# ติดตั้งจาก Play Store (Internal Testing)
# ตรวจสอบ logs
adb logcat -c
adb logcat | grep -E "flutter|🔧|⚠️|🔒|🚨"
```

**ผลลัพธ์ที่ต้องได้:**
```
🔧 Build Flavor: secure
🔧 Is Secure: true
🔒 Starting RASP initialization...
✅ RaspService: Initialized successfully
✅ No threats detected
```

#### **ขั้นตอนที่ 3: Monitor Production**

ติดตั้ง Firebase Crashlytics หรือ Sentry เพื่อ monitor:
- จำนวน threat ที่ถูกตรวจพบ
- จำนวน user ที่โดน block
- ประเภท threat ที่พบบ่อย

---

## 🔧 Troubleshooting

### **1. Modal ขึ้นตลอดเวลาใน Development**

**สาเหตุ:** Developer Options เปิดอยู่

**แก้ไข:**
```bash
# ปิด Developer Options ชั่วคราว
Settings > Developer Options > Disable

# หรือปิด USB Debugging
Settings > Developer Options > USB Debugging > Disable
```

---

### **2. App Integrity Threat ขึ้นตลอด**

**สาเหตุ:** SHA256 certificate ไม่ตรงกัน

**วิธีตรวจสอบ:**
```bash
# 1. ดู SHA256 จาก keystore
keytool -list -v -keystore pos-release.jks -alias pos-release | grep SHA256

# 2. ดู SHA256 จาก APK ที่ติดตั้ง
adb shell pm list packages -f | grep pos_android
adb pull /data/app/...base.apk
keytool -printcert -jarfile base.apk | grep SHA256
```

**แก้ไข:**
- อัพเดท SHA256 ใน `rasp_config.dart` และ `talsec_config.json`
- Build APK ใหม่

---

### **3. Unofficial Store Threat ขึ้นใน Production**

**สาเหตุ:** ผู้ใช้ติดตั้งจากแหล่งอื่นที่ไม่ใช่ Google Play Store

**พฤติกรรมที่ถูกต้อง:**
- ✅ Production build ควร block แอป
- ✅ แสดง dialog และให้ผู้ใช้ติดตั้งจาก Play Store

**ถ้าไม่ต้องการ block:**
```dart
// แก้ไข rasp_config.dart
supportedStores: [], // ไม่เช็ค store
```

---

### **4. ไม่สามารถทดสอบบน Emulator ได้**

**สาเหตุ:** RASP block emulator โดย design

**แก้ไข (Development Only):**
```dart
// rasp_threat_handler.dart
if (threat == RaspThreatType.simulator) {
  _logger.d('   → Skipped (testing on emulator)');
  return;
}
```

⚠️ **อย่าลืมลบโค้ดนี้ก่อน deploy production!**

---

## 📚 Additional Resources

- [FreeRASP Documentation](https://github.com/talsec/Free-RASP-Flutter)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS Code Signing](https://developer.apple.com/support/code-signing/)

---

## 📝 Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-30 | Initial RASP implementation |
| 1.0.1 | 2025-01-30 | Added unofficialStore handling for ADB testing |

---

## 👥 Support

หากพบปัญหาหรือมีคำถาม ติดต่อ:
- **Developer:** chongdev
- **Project:** POS Android

---

**หมายเหตุ:**
- ⚠️ **อย่าลืมลบ development code ก่อน deploy production**
- ⚠️ **ตรวจสอบ SHA256 certificate ให้ตรงกับ keystore ที่ใช้จริง**
- ⚠️ **ทดสอบบน real device ก่อน deploy**