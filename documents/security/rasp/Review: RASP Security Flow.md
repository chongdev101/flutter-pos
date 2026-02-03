# Review: RASP Security Flow

## การทำงานของ RASP (Runtime Application Self-Protection)

### **Flow ทั้งหมด:**

```dart
main() async {
  // 1. เตรียม Flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  // 2. โหลดประวัติ threat ที่เคยถูก block (จาก SecureStorage)
  final blockedType = await SecurityStorage.getBlockedThreat();

  // 3. แสดง UI ก่อน (ให้ user เห็นหน้าจอ)
  runApp(const MyApp());

  // 4. รอให้ frame แรกเสร็จ แล้วค่อยเช็ค security
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // ...
  });
}
```

---

## **Step-by-Step ภายใน `addPostFrameCallback`:**

### **Step 1: ตรวจสอบ Build Flavor**
```dart
if (!AppBuild.isSecure) {
  return; // ถ้าเป็น dev/staging → ข้ามการเช็ค RASP
}
```
**คำอธิบาย:**
- `AppBuild.isSecure` = `true` เฉพาะ **production flavor**
- Flavor อื่นๆ (dev, staging) ไม่เปิด RASP เพื่อความสะดวกในการ debug

---

### **Step 2: ตรวจสอบประวัติ Threat**
```dart
if (blockedType != null) {
  // มี threat ที่เคยถูก block ไว้
```
**คำอธิบาย:**
- `blockedType` = ชนิดของภัยคุกคาม เช่น `root`, `emulator`, `hook`
- ค่านี้มาจาก `SecurityStorage` (บันทึกไว้ตั้งแต่รอบก่อน)

---

### **Step 3a: Threat ที่แก้ไม่ได้ → Block ทันที**
```dart
if (!RaspPolicy.isRecoverable(blockedType)) {
  SecurityDialog.show(
    title: 'Security Alert',
    message: 'ไม่สามารถใช้งานแอปในสภาพแวดล้อมนี้ได้',
  );
  return; // หยุดการทำงาน ไม่ init RASP
}
```
**ตัวอย่าง Threat ที่ Unrecoverable:**
- Root device (ถาวร)
- Emulator (เป็นอุปกรณ์จำลอง)
- ตรวจพบ Frida/Xposed

---

### **Step 3b: Threat ที่แก้ได้ → ตรวจใหม่**
```dart
// 🔁 threat แก้ไขได้ → ให้ RASP ตรวจใหม่
RaspService.instance.initialize();
return;
```
**ตัวอย่าง Threat ที่ Recoverable:**
- Developer options เปิดอยู่ (ปิดได้)
- USB debugging เปิดอยู่ (ปิดได้)
- แอปถูก sideload (ถ้า user ลบแล้วติดจาก store ใหม่)

---

### **Step 4: ไม่เคยมีประวัติ → Init ปกติ**
```dart
// 🟢 ไม่เคยโดน block → init ปกติ
RaspService.instance.initialize();
```
**คำอธิบาย:**
- เป็นการเปิดแอปครั้งแรก หรือไม่เคยมี threat
- `RaspService` จะเริ่มตรวจสอบแบบ real-time

---

## **สรุป Decision Tree:**

```
AppBuild.isSecure?
├─ NO  → Skip RASP (dev/staging)
└─ YES → มี blockedType?
         ├─ NO  → Initialize RASP ปกติ
         └─ YES → Recoverable?
                  ├─ NO  → แสดง SecurityDialog + Block
                  └─ YES → Re-initialize RASP (ตรวจใหม่)
```

---

## **ข้อดีของ Architecture นี้:**

✅ **UX ดี:** UI โหลดก่อน ไม่ค้างรอการตรวจสอบ  
✅ **Flexible:** แยก policy ว่า threat ไหนให้โอกาสแก้ไข  
✅ **Persistent:** จำประวัติไว้ ไม่ต้องตรวจซ้ำทุกครั้ง (ถ้า unrecoverable)  
✅ **Performance:** ใช้ `addPostFrameCallback` ไม่กระทบ app startup time