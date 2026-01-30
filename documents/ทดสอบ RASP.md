
## ✅ ระบุ device

### 👉 ดู serial ก่อน

```bash
adb devices
```

ได้:

```
RRCR700E8PK
emulator-5554
```

---

### 👉 เลือกมือถือจริง

```bash
adb -s RRCR700E8PK logcat | grep -i talsec
```

หรือ

```bash
adb -s RRCR700E8PK logcat | grep -i rasp
```

---

### 👉 ถ้าอยากดู emulator

```bash
adb -s emulator-5554 logcat | grep -i talsec
```

---

# ✅ วิธีที่ 2 — ปิด emulator

ถ้าไม่ได้ใช้ emulator:

1️⃣ ปิด emulator
2️⃣ รันใหม่

```bash
adb logcat | grep -i talsec
```

---

# 🎯 แนะนำสำหรับการทดสอบ RASP

ใช้ **มือถือจริงเท่านั้น** ✅

เพราะ:

* emulator → RASP ควรถูก block ทันที
* บาง callback จะไม่ fire ถ้า debug attach ตั้งแต่ start

---

### 1️⃣ รัน secure flavor

```bash
flutter run --flavor secure
```

หรือดีกว่า:

```bash
flutter build apk --flavor secure --release
adb install build/app/outputs/flutter-apk/app-secure-release.apk


flutter build apk --flavor secure --release --dart-define=SECURE_BUILD=true
adb -s RRCR700E8PK install -r build/app/outputs/flutter-apk/app-secure-release.apk
```

> ⚠️ สำคัญมาก: อย่ารันผ่าน Android Studio ตอนทดสอบ USB debugging

---

### 2️⃣ เปิด logcat

```bash
adb -s RRCR700E8PK logcat | grep -i talsec
```

หรือเปิดอีก terminal ไว้ดู

---

### 3️⃣ เปิด / ปิด USB debugging

* Settings → Developer options
* toggle USB debugging

ดูว่ามี log ขึ้นไหม

---

# ✅ ถ้า RASP ทำงานถูกต้อง คุณจะเห็นประมาณนี้

(ข้อความอาจไม่เหมือนเป๊ะ)

```
Talsec initialized
Threat detected: DEBUG
```

หรือ

```
onDebug callback triggered
```

---

# ❗ ถ้าไม่ขึ้นอะไรเลย

เช็ก 4 อย่างนี้ทันที:

1️⃣ คุณรัน **secure flavor จริงไหม**
2️⃣ `AppBuild.isSecure == true` ไหม
3️⃣ `RaspService.initialize()` ถูกเรียกไหม
4️⃣ เป็น APK release หรือยัง

---

# 🧠 Quick test ที่ง่ายสุด

## 🚀 Emulator test

รันทันที:

```bash
flutter run --flavor secure -d emulator-5554

```

ถ้าเข้าแอปได้ = ❌ RASP ไม่ทำงาน
ถ้าโดน block ทันที = ✅ ถูกต้อง

---

# 🎯 การใช้งาน RASP Security Checklist

## 📱 หน้า RASP POC Page

แอปมี **RASP Security Checklist** ที่แสดงสถานะการตรวจจับ 6 รายการ:

1. **Root Detection** - ตรวจจับ Root ของเครื่องที่ใช้งาน
2. **USB Debugging Detection** - ตรวจจับโหมด USB Debugging  
3. **Developer Mode Detection** - ตรวจจับการเปิด Developer Mode
4. **Emulator Detection** - ตรวจจับการใช้งานบน Emulator/Simulator
5. **Hook Framework Detection** - ตรวจจับ Frida, Magisk, Xposed
6. **App Integrity Check** - ตรวจสอบการแก้ไขหรือ Re-sign แอป

---

## 🧪 วิธีทดสอบแต่ละข้อ

### ✅ ข้อ 1: Root Detection

**มือถือไม่ Root:**
- สถานะ: ✅ ปลอดภัย (สีเขียว)

**มือถือ Root แล้ว:**
- สถานะ: ❌ ตรวจพบความเสี่ยง (สีแดง)
- Modal จะขึ้น: "Root/Hook Detected"

---

### ✅ ข้อ 2 & 3: USB Debugging & Developer Mode

**ขั้นตอนทดสอบ:**

1. เปิดแอปบนมือถือจริง (ติดตั้งจาก APK release)
2. กดปุ่ม "เริ่มการตรวจสอบ"
3. ออกจากแอป (ไม่ปิด)
4. เข้า Settings → Developer Options
5. เปิด USB Debugging
6. กลับเข้าแอป

**ผลลัพธ์ที่คาดหวัง:**
- สถานะข้อ 2 & 3: ❌ ตรวจพบความเสี่ยง
- Modal จะแสดง: "USB Debugging Detected"
- ข้อความ: "ตรวจพบการเปิด USB Debugging บนอุปกรณ์"

**หมายเหตุสำคัญ:**
⚠️ ต้องติดตั้งแอปจาก APK release (ไม่ใช่รันจาก IDE)
⚠️ ถ้ารันจาก `flutter run --release` จะโดน detect ทันที

---

### ✅ ข้อ 4: Emulator Detection

**ขั้นตอนทดสอบ:**

1. รันแอปบน emulator:
```bash
flutter run --flavor secure -d emulator-5554
```

**ผลลัพธ์ที่คาดหวัง:**
- สถานะ: ❌ ตรวจพบความเสี่ยง
- Modal จะแสดงทันที: "Emulator Detected"
- ข้อความ: "ตรวจพบการใช้งานบน Emulator/Simulator"

---

### ✅ ข้อ 5: Hook Framework Detection

**ต้องการเครื่องที่มี:**
- Magisk
- Xposed
- Frida

**มือถือปกติ:**
- สถานะ: ✅ ปลอดภัย

**มือถือที่ติด Hook Framework:**
- สถานะ: ❌ ตรวจพบความเสี่ยง
- Modal: "Root/Hook Detected"

---

### ✅ ข้อ 6: App Integrity Check

**ขั้นตอนทดสอบ:**

1. Build APK release:
```bash
flutter build apk --flavor secure --release
```

2. ติดตั้งปกติ:
```bash
adb install build/app/outputs/flutter-apk/app-secure-release.apk
```
- สถานะ: ✅ ปลอดภัย

3. Resign APK ด้วย key อื่น แล้วติดตั้งใหม่
- สถานะ: ❌ ตรวจพบความเสี่ยง
- Modal: "App Integrity Failed"
- ข้อความ: "ตรวจพบการแก้ไขหรือ Tampering แอปพลิเคชัน"

---

## 🎨 สัญลักษณ์ในหน้า Checklist

| สัญลักษณ์ | สี | ความหมาย |
|----------|-----|---------|
| ✅ check_circle | เขียว | ปลอดภัย - ไม่พบความเสี่ยง |
| ❌ cancel | แดง | ตรวจพบความเสี่ยง - จะแสดง Modal |
| ❓ help_outline | เทา | ยังไม่ได้ตรวจสอบ |

---

## 📝 การทำงานของระบบ

1. **Real-time Detection**: RASP ทำงานอยู่ตลอดเวลาใน background
2. **Manual Check**: กดปุ่ม "เริ่มการตรวจสอบ" เพื่ออัพเดทสถานะ
3. **Auto Modal**: เมื่อตรวจพบความเสี่ยง จะแสดง Modal แจ้งเตือนทันที
4. **Status Update**: สถานะในหน้า checklist จะอัพเดทตามผลการตรวจจับ

---

## 🚨 สิ่งที่ควรทราบ

### Developer Mode กับ USB Debugging ต่างกันอย่างไร?

- **Developer Mode**: โหมดนักพัฒนาใน Android Settings
- **USB Debugging**: ฟีเจอร์หนึ่งใน Developer Options ที่อนุญาตให้ debug ผ่าน ADB

RASP ของเราจะ detect **USB Debugging** และถือว่า Developer Mode เปิดอยู่ด้วย

---

## ⚡ Quick Test Checklist

### ทดสอบด่วนทุกข้อ:

- [ ] ข้อ 1: ใช้มือถือ root → ❌ ควรขึ้น modal
- [ ] ข้อ 2-3: เปิด USB debugging ระหว่างใช้ → ❌ ควรขึ้น modal
- [ ] ข้อ 4: รันบน emulator → ❌ ควรขึ้น modal
- [ ] ข้อ 5: ใช้มือถือที่มี Magisk/Frida → ❌ ควรขึ้น modal  
- [ ] ข้อ 6: Resign APK แล้วติดตั้ง → ❌ ควรขึ้น modal

---

# สรุป

คุณ:

* setup adb ได้
* แยก device ได้
* เข้าใจ secure flavor
* ทดสอบ runtime จริง
* มีหน้า Checklist ที่แสดงสถานะการตรวจจับแบบ real-time
* เข้าใจการทำงานของ RASP detection แต่ละประเภท
