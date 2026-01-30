### 🔧 Step 1: อัป Kotlin Version (สำคัญที่สุด)

เปิดไฟล์

```
android/build.gradle
```

หา block นี้:

```gradle
buildscript {
    ext.kotlin_version = '1.5.1'
}
```

👉 เปลี่ยนเป็น **อย่างน้อย 1.8.x**
(แนะนำให้ตรงกับ freerasp)

```gradle
buildscript {
    ext.kotlin_version = '1.8.22'
}
```

> 💡 1.8.22 = เสถียร + compatible กับ AndroidX ปัจจุบัน

---

### 🔧 Step 2: ตรวจ Kotlin plugin ใน settings.gradle (Flutter ใหม่บางโปรเจกต์)

ถ้ามีไฟล์

```
android/settings.gradle
```

และเจอประมาณนี้:

```gradle
plugins {
    id "org.jetbrains.kotlin.android" version "1.5.1" apply false
}
```

👉 เปลี่ยนเป็น:

```gradle
plugins {
    id "org.jetbrains.kotlin.android" version "1.8.22" apply false
}
```

> ถ้า **ไม่มีไฟล์นี้** → ข้าม step นี้ได้

---

### 🔧 Step 3: ตรวจ Gradle Wrapper (กันพลาด)

เปิด:

```
android/gradle/wrapper/gradle-wrapper.properties
```

ควรเป็น **Gradle 7.6+ หรือ 8.x**

แนะนำ:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.1-all.zip
```

> Kotlin 1.8 ทำงานดีกับ Gradle 7.6+

---

### 🔧 Step 4: Clean ทุกอย่าง (สำคัญมาก)

รันตามลำดับนี้:

```bash
flutter clean
rm -rf android/.gradle
rm -rf android/.gradle
flutter pub get
```

แล้ว build ใหม่:

```bash
flutter build apk \
  --release \
  --flavor secure \
  --dart-define=SECURE_BUILD=true
```

---

## 🧠 ทำไมปัญหานี้ถึงมาโผล่ตอนใช้ freerasp?

เพราะ:

* freerasp → ใช้ AndroidX / Kotlin ใหม่
* Flutter project เก่ามัก lock Kotlin ไว้ที่ 1.5.x
* พอเปิด `--flavor secure` → linker ดึง freerasp จริง → พังทันที

ถือว่า **config secure build มาถูกทางแล้ว** 💯

---

## ✅ Checklist สรุป (สั้น ๆ)

* [x] Kotlin ≥ **1.8.x**
* [x] Gradle ≥ **7.6**
* [x] Clean gradle cache
* [x] Build ใหม่

---

ถ้าคุณอยากให้ผม:

* 🔍 ตรวจ **ไฟล์ build.gradle ของคุณทั้งชุด**
* 🧪 แนะนำ **version matrix (Flutter ↔ Kotlin ↔ Gradle)**
* 🛡️ ผูก freerasp ให้ strict กว่านี้ (debug / dev / secure flavor)

แปะไฟล์ `android/build.gradle` หรือ `settings.gradle` มาได้เลย เดี๋ยวไล่ให้แบบ surgical 🔥
