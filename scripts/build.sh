#!/bin/bash

case "$1" in
  dev)
    flutter build apk --flavor dev --release
    ;;
  staging)
    flutter build apk --flavor staging --release
    ;;
  secure)
    flutter build apk \
      --dart-define=SECURE_BUILD=true \
      --flavor secure \
      --release
    ;;
  *)
    echo "Usage: ./build.sh [dev|staging|secure]"
    exit 1
    ;;
esac
