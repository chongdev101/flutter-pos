
# 🎯 แนวคิด Secure-Build Flow

> **RASP = เปิดเฉพาะตอน “secure build”**
> build ปกติ = ไม่โหลด freerasp เลย

ผลลัพธ์คือ:

| build          | RASP | Toolchain |
| -------------- | ---- | --------- |
| debug          | ❌    | เดิม      |
| qa             | ❌    | เดิม      |
| release-secure | ✅    | ใหม่      |
| prod           | ✅    | ใหม่      |

---

# 🧠 โครงสร้างภาพรวม

```
flutter run                    → normal
flutter run --dart-define=SECURE_BUILD=true → secure
```

Flutter จะรู้ว่า build นี้ “ปลอดภัยพิเศษ”

---

# ✅ STEP 1 — สร้าง build flag

### ตอน run

```bash
flutter run --dart-define=SECURE_BUILD=true
```

หรือ

```bash
flutter build apk --release --dart-define=SECURE_BUILD=true
```

---

# ✅ STEP 2 — อ่านค่าใน Flutter

```dart
class AppSecurityFlag {
  static const bool isSecureBuild =
      bool.fromEnvironment('SECURE_BUILD', defaultValue: false);
}
```

---

# ✅ STEP 3 — เปิด RASP เฉพาะ secure build

### `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppSecurityFlag.isSecureBuild) {
    await RaspService.instance.initialize();
  }

  runApp(const MyApp());
}
```

✔ debug build → ไม่โหลด freerasp
✔ secure build → เปิด RASP

---

# 🔥 สำคัญมาก

ถ้าไม่ใช้วิธีนี้ ❌
Flutter จะ:

* load native freerasp
* init JNI
* โหลด NDK
* crash แม้ไม่ได้เรียกใช้

ดังนั้น **ต้องกันตั้งแต่ main()**

---

# ✅ STEP 4 — ไม่ import freerasp ในไฟล์อื่น

🚫 ห้าม import

```dart
import 'package:freerasp/freerasp.dart';
```

นอก `rasp_service.dart` เท่านั้น

---

# ✅ STEP 5 — ป้องกัน analyzer crash

ใน `rasp_service.dart`

```dart
if (!AppSecurityFlag.isSecureBuild) return;
```

---

# 🧩 Flow จริงตอน runtime

```
App start
 ↓
Check SECURE_BUILD
 ↓
false → run normal app
true  → init RASP
 ↓
Threat detected
 ↓
Security handler
```

---

# 🧠 จุดแข็ง flow นี้

| เรื่อง                  | ได้ |
| ----------------------- | --- |
| Dev ไม่พัง              | ✅   |
| Plugin เดิมไม่กระทบ     | ✅   |
| CI เดิมใช้ได้           | ✅   |
| Security เปิดเฉพาะ prod | ✅   |
| Auditor happy           | ✅   |

---

# 📁 โครงไฟล์สุดท้าย

```
lib/
├── main.dart
├── app/
├── core/
│   └── security/
│       ├── rasp/
│       │   ├── rasp_service.dart
│       │   ├── rasp_config.dart
│       │   └── rasp_threat_handler.dart
│       │
│       └── flags/
│           └── security_flag.dart
```

---

# ✅ `security_flag.dart`

```dart
class AppSecurityFlag {
  static const bool isSecureBuild =
      bool.fromEnvironment('SECURE_BUILD', defaultValue: false);
}
```

---

# 🔥 ตัวอย่างใช้งานจริง

### Dev

```bash
flutter run
```

→ ไม่มี RASP
→ build เร็ว
→ plugin เดิมไม่พัง

---

### Secure build (ส่งลูกค้า / audit)

```bash
flutter build apk --release --dart-define=SECURE_BUILD=true
```

→ เปิด RASP
→ ใช้ AGP 8.x
→ Java 17
→ security full

---

# 🧠 บริษัทใช้จริงยังไง

| build          | ใช้   |
| -------------- | ----- |
| debug          | dev   |
| staging        | qa    |
| secure-release | audit |
| prod           | store |

หลายบริษัทมี APK 2 ตัว:

* `app-debug.apk`
* `app-secure.apk`

---

# 🔐 สุดท้าย (สำคัญมาก)

> ❗ Free-RASP เป็น **native SDK**
> แม้ไม่เรียกใช้ ก็ยังถูกโหลดตอน runtime

ดังนั้น:

* อย่าเปิดใน debug
* อย่าเปิดใน dev
* เปิดเฉพาะ secure build เท่านั้น

---

