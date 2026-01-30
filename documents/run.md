flutter build apk \                                                               
--flavor secure \
-t lib/main.dart \
--dart-define=SECURE_BUILD=true \
--release

## To run the app with the 'dev' flavor
flutter run --flavor dev -t lib/main.dart


flutter run --flavor secure -t lib/main.dart