
## รันตามลำดับนี้
```bash
flutter clean
rm -rf android/.gradle
rm -rf ~/.gradle/caches
flutter pub get
flutter run
```


### คำแนะนำ
- production app
- มี plugin native เยอะ
- มี payment / camera / printer
```ini
--dart-define=SECURE_BUILD=true
```
เปิดเฉพาะ build สำหรับ release