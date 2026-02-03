## 🎯 รันเฉพาะ test ที่เกี่ยวกับ RASP / policy

### 1️⃣ รันเฉพาะ policy

```bash
flutter test test/core/security/rasp/rasp_policy_test.dart
```

### 2️⃣ รันเฉพาะ storage

```bash
flutter test test/core/security/storage/security_storage_test.dart
```

### 3️⃣ รันเฉพาะ handler + policy enforcement

```bash
flutter test test/core/security/rasp/rasp_threat_handler_policy_test.dart
```

---

## 🧪 รันแบบดู log ชัด (debug test)

```bash
flutter test --verbose
```

หรือถ้าอยากเจาะ test เดียว:

```bash
flutter test test/core/security/rasp/rasp_threat_handler_policy_test.dart --verbose
```

---

## 🔁 ใช้ตอนพัฒนา (เร็วมาก)

```bash
flutter test --watch
```

> ทุกครั้งที่ save ไฟล์ → test รันทันที
> เหมาะกับปรับ policy / logic

---

## ⚠️ ข้อควรระวัง (ที่คนเจอบ่อย)

### ❌ อย่ารันแบบนี้

```bash
flutter run test
```

### ❌ ไม่ต้องต่อมือถือ / emulator

```bash
adb devices   # ไม่เกี่ยว
```

Unit test = รันบน Dart VM เท่านั้น

---

## ✅ ผลลัพธ์ที่ถูกต้องควรเห็น

```text
00:02 +5: All tests passed!
```

ถ้ามี policy พัง จะเห็นชัด เช่น:

```text
Expected: null
  Actual: RaspThreatType.debug
```