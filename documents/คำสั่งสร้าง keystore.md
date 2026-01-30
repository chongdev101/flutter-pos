
โฟกัส **Android + Flutter + secure flavor + POS production**

---

# 🧭 ภาพรวมก่อน

1. สร้าง **release keystore** (ทำครั้งเดียว ใช้ยาว)
2. เก็บ keystore อย่างปลอดภัย
3. สร้าง `key.properties`
4. ผูก keystore กับ Gradle
5. ทดสอบ build release ว่า sign สำเร็จจริง

---

## STEP 1️⃣ สร้าง Release Keystore (ทำครั้งเดียว)

> ⚠️ **สำคัญมาก**
>
> * ถ้า keystore หาย = update แอปต่อไม่ได้
> * ห้ามใช้ debug keystore เด็ดขาด

### 📍 ตำแหน่งที่แนะนำ

สร้างโฟลเดอร์นอก repo เช่น:

```bash
~/keystores/
```

### 🔧 คำสั่งสร้าง keystore

```bash
keytool -genkeypair \
  -alias pos-release \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -keystore pos-release.jks
```

ระบบจะถาม:

| คำถาม             | แนะนำ                  |
| ----------------- | ---------------------- |
| Keystore password | ตั้งยาก ๆ              |
| Key password      | ใช้เหมือน keystore ได้ |
| First / Last name | ชื่อบริษัทหรือโปรเจกต์ |
| Organization      | ชื่อบริษัท             |
| Country code      | TH                     |

เมื่อเสร็จจะได้ไฟล์:

```
pos-release.jks
```

👉 **เก็บไฟล์นี้ไว้ดี ๆ** (backup อย่างน้อย 2 ที่)

---

## STEP 2️⃣ ตรวจสอบ keystore (optional แต่แนะนำ)

```bash
keytool -list -v -keystore pos-release.jks
```

ดูให้แน่ใจว่า:

* alias = `pos-release`
* Algorithm = RSA
* Validity = หลายปี

---

## STEP 3️⃣ สร้างไฟล์ `key.properties`

📍 ตำแหน่ง:

```
android/key.properties
```

> ❌ **ห้าม commit ลง git**

### ตัวอย่าง `key.properties`

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=pos-release
storeFile=/Users/yourname/keystores/pos-release.jks
```

📌 `storeFile` ต้องเป็น **absolute path**

---

## STEP 4️⃣ ผูก keystore กับ Gradle (Flutter)

### 4.1 โหลด `key.properties`

เปิดไฟล์:

```
android/app/build.gradle
```

เพิ่มด้านบน (ก่อน `android {}`):

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

---

### 4.2 สร้าง `signingConfigs`

ใน `android {}`:

```gradle
signingConfigs {
    release {
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
    }
}
```

---

### 4.3 ผูกกับ buildTypes

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

> ❗ อย่าใช้ `signingConfigs.debug` กับ release

---

## STEP 5️⃣ Build Release เพื่อทดสอบ Signing

### 🔹 Build APK (เหมาะกับ POS / sideload)

```bash
flutter build apk \
  --release \
  --flavor secure \
  --dart-define=SECURE_BUILD=true
```

ถ้า sign สำเร็จ จะได้ไฟล์:

```
build/app/outputs/flutter-apk/app-secure-release.apk
```

---

### 🔹 ตรวจว่า APK ถูก sign จริงไหม

```bash
apksigner verify --verbose app-secure-release.apk
```

ต้องเห็น:

```
Verified using v1/v2/v3 scheme
```

---

## STEP 6️⃣ สิ่งที่ “ต้องทำเพิ่ม” สำหรับ RASP (สำคัญมาก)

### 🔑 ดึง SHA-256 ของ release cert (ใช้กับ freerasp)

```bash
keytool -list -v -keystore pos-release.jks
```

เอาค่า:

```
SHA256: XX:XX:XX:...
```

แปลงเป็น **Base64** แล้วใส่ใน:

```dart
AndroidConfig(
  packageName: 'com.chongdev.pos_android',
  signingCertHashes: [
    'BASE64_SHA256_CERT',
  ],
)
```

❌ ถ้าใส่ debug cert → release app จะ block ตัวเองทันที

---

## 🔐 Checklist (เช็กก่อนใช้งานจริง)

* [ ] ใช้ **secure flavor**
* [ ] ใช้ **--dart-define=SECURE_BUILD=true**
* [ ] ใช้ **release keystore**
* [ ] `isProd: true` ใน RASP
* [ ] `android:debuggable="false"`
* [ ] keystore backup แล้ว

---
