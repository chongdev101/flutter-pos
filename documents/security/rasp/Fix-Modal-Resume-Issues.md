# 🔧 แก้ไขปัญหา RASP Modal และ App Resume

## 📋 ปัญหาที่พบ

### 1. ❌ Re-sign ยัง false
- **ปัญหา**: UI แสดงผล App Integrity ผิด (กลับด้าน)
- **สาเหตุ**: ใช้ `!_isAppIntegrityFailed!` แทนที่จะใช้ `_isAppIntegrityFailed`

### 2. ❌ Modal ขึ้นครั้งแรก แต่กดเข้ามาอีกครั้ง modal ไม่ขึ้น
- **ปัญหา**: หลังจาก modal แสดงครั้งแรก เมื่อ minimize แล้วกลับมาที่ app อีกครั้ง modal ไม่ขึ้น
- **สาเหตุ**: 
  - `_pending` ยังค้างอยู่ ทำให้ถูก skip โดย duplicate check
  - `RaspLifecycleObserver` เรียก `resetForTest()` แต่ไม่ได้ trigger RASP ให้ตรวจใหม่

### 3. ❌ เปิด dev mode หลังปิดแอพ แล้วเข้าแอพใหม่ ใช้งานได้ปกติ
- **ปัญหา**: ควรขึ้น modal เตือน แต่กลับใช้งานได้ปกติ
- **สาเหตุ**: RASP ไม่ถูก re-initialize เมื่อ app resume

---

## ✅ การแก้ไข

### 1️⃣ แก้ไข `rasp_threat_handler.dart`

#### เพิ่ม `_detectedThreats` Set
```dart
static final Set<RaspThreatType> _detectedThreats = {};
```

#### ปรับการป้องกัน duplicate
```dart
// 2️⃣ เก็บ threat ที่ตรวจพบ
_detectedThreats.add(type);

// 3️⃣ ป้องกัน event ซ้ำขณะที่กำลังแสดง modal
if (_pending == type) {
  print('   → Skipped (duplicate while showing modal)');
  return;
}
```

#### เพิ่ม method `reset()` และ `hasDetected()`
```dart
/// Reset ทุกอย่างเพื่อให้ RASP สามารถตรวจและแสดง modal ใหม่ได้
static void reset() {
  print('🔄 RaspThreatHandler: Resetting all states');
  _pending = null;
  _detectedThreats.clear();
}

/// ตรวจสอบว่ามี threat ประเภทนี้ถูกตรวจพบหรือไม่
static bool hasDetected(RaspThreatType type) {
  return _detectedThreats.contains(type);
}
```

---

### 2️⃣ แก้ไข `rasp_lifecycle_observer.dart`

#### เพิ่ม import
```dart
import 'rasp_service.dart';
```

#### ปรับ logic ให้ reset และ re-initialize RASP
```dart
static Future<void> onAppResumed() async {
  if (!AppBuild.isSecure) {
    print('📱 Lifecycle: Skipped (dev mode)');
    return;
  }

  print('📱 Lifecycle: App resumed - checking threats...');

  // 1️⃣ Reset RASP state เพื่อให้สามารถตรวจและแสดง modal ใหม่ได้
  RaspThreatHandler.reset();

  // 2️⃣ เช็ค critical threat ที่ถูก block ไว้
  final blockedType = await SecurityStorage.getBlockedThreat();
  if (blockedType != null) {
    print('📱 Lifecycle: Found blocked threat: $blockedType');

    if (!RaspPolicy.isRecoverable(blockedType)) {
      // Critical threat → แสดง modal ทันที
      SecurityDialog.show(
        title: 'Security Alert',
        message: 'ไม่สามารถใช้งานแอปในสภาพแวดล้อมนี้ได้',
      );
      return;
    }

    // Recoverable threat → ให้ RASP ตรวจใหม่
    print('📱 Lifecycle: Threat is recoverable, re-initializing RASP...');
    await SecurityStorage.clearBlocked();
  }

  // 3️⃣ Re-initialize RASP เพื่อให้ตรวจหา threat ใหม่
  print('📱 Lifecycle: Re-initializing RASP to detect new threats...');
  await RaspService.instance.initialize();
  
  print('📱 Lifecycle: RASP re-initialized, waiting for callbacks...');
}
```

**🔑 Key Changes:**
1. ✅ เรียก `RaspThreatHandler.reset()` ก่อนเช็ค
2. ✅ Clear blocked threat ถ้าเป็น recoverable
3. ✅ **Re-initialize RASP** เพื่อให้ตรวจหา threat ใหม่ทุกครั้งที่ resume

---

### 3️⃣ แก้ไข `security_storage.dart`

#### เพิ่ม method `clearBlocked()`
```dart
/// ลบ blocked threat (ใช้เมื่อ threat หายไปแล้ว)
static Future<void> clearBlocked() async {
  await clear();
}
```

---

### 4️⃣ แก้ไข `main.dart`

#### ปรับให้ clear blocked threat ก่อน re-initialize
```dart
if (blockedType != null) {
  if (!RaspPolicy.isRecoverable(blockedType)) {
    SecurityDialog.show(
      title: 'Security Alert',
      message: 'ไม่สามารถใช้งานแอปในสภาพแวดล้อมนี้ได้',
    );
    return;
  }

  // 🔁 threat แก้ไขได้ → clear และให้ RASP ตรวจใหม่
  print('🔄 Clearing recoverable threat: $blockedType');
  await SecurityStorage.clearBlocked();
  RaspService.instance.initialize();
  return;
}
```

---

### 5️⃣ แก้ไข `rasp_flutter_page.dart`

#### แก้การแสดงผล App Integrity
```dart
_buildChecklistItem(
  number: '6',
  title: 'App Integrity Check',
  subtitle: 'ตรวจสอบการแก้ไขหรือ Re-sign แอป',
  status: _isAppIntegrityFailed, // ✅ ไม่ invert
),
```

---

## 🎯 ผลลัพธ์หลังแก้ไข

### ✅ ปัญหา 1: Re-sign แสดงผลถูกต้อง
- `_isAppIntegrityFailed = true` → แสดงสีแดง "ตรวจพบความเสี่ยง"
- `_isAppIntegrityFailed = false` → แสดงสีเขียว "ปลอดภัย"

### ✅ ปัญหา 2: Modal ขึ้นทุกครั้งที่กลับมา
- เมื่อ minimize แล้วกลับมา → `RaspLifecycleObserver.onAppResumed()` ทำงาน
- Reset state และ re-initialize RASP
- Modal จะขึ้นใหม่ถ้ายังมี threat

### ✅ ปัญหา 3: ตรวจจับ dev mode เมื่อเปิดใหม่
- เมื่อปิดแอพ → เปิด dev mode → เปิดแอพใหม่
- App resume → RASP re-initialize
- ตรวจพบ debug threat → แสดง modal

---

## 🔄 Flow การทำงาน

### 📱 เมื่อ App Resume
```
1. AppLifecycleListener.onResume()
2. RaspLifecycleObserver.onAppResumed()
3. RaspThreatHandler.reset() ← clear _pending + _detectedThreats
4. Check blocked threat from storage
5. If recoverable → clear storage
6. RaspService.initialize() ← re-attach listener
7. RASP callbacks trigger → show modal
```

### 🚨 เมื่อตรวจพบ Threat
```
1. RASP callback (e.g., onDebug)
2. RaspThreatHandler.handle(type)
3. Add to _detectedThreats set
4. Check duplicate (skip if _pending == type)
5. If critical → save to storage
6. Set _pending = type
7. Show modal
8. User กด OK → close app
```

---

## 🧪 การทดสอบ

### Test Case 1: Re-sign Detection
1. Build แอพด้วย key อื่น
2. Install แอพ
3. เปิดแอพ → ควรเห็น modal "App Integrity Failed"
4. ดูที่ RASP POC page → App Integrity ควรแสดงสีแดง ✅

### Test Case 2: Modal ขึ้นซ้ำเมื่อ Resume
1. เปิด USB debugging
2. เปิดแอพ → modal ขึ้น
3. กด Home (minimize app)
4. กลับมาที่แอพ → modal ควรขึ้นอีกครั้ง ✅

### Test Case 3: เปิด Dev Mode หลังปิดแอพ
1. เปิดแอพปกติ (ไม่มี dev mode)
2. ปิดแอพ
3. เปิด dev mode
4. เปิดแอพใหม่ → modal ควรขึ้น ✅

---

## 📝 สรุป

### การเปลี่ยนแปลงหลัก
1. ✅ เพิ่ม `_detectedThreats` Set เพื่อเก็บ threat history
2. ✅ เพิ่ม `reset()` method เพื่อ clear state ทั้งหมด
3. ✅ **Re-initialize RASP** เมื่อ app resume
4. ✅ Clear blocked threat ก่อน re-initialize
5. ✅ แก้การแสดงผล App Integrity

### ประโยชน์
- ✅ Modal แสดงทุกครั้งที่ยังมี threat
- ✅ ตรวจจับ threat ใหม่เมื่อ app resume
- ✅ UI แสดงผลถูกต้อง
- ✅ รองรับ recoverable threats

---

**วันที่แก้ไข**: 30 มกราคม 2026
