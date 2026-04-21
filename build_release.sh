#!/bin/bash
# Script de build para release com obfuscação Dart
# Uso: bash build_release.sh [android|ios|all]

SYMBOLS_DIR="build/symbols"
mkdir -p "$SYMBOLS_DIR"

TARGET=${1:-all}

if [ "$TARGET" = "android" ] || [ "$TARGET" = "all" ]; then
  echo "Building Android release..."
  flutter build apk \
    --release \
    --obfuscate \
    --split-debug-info="$SYMBOLS_DIR/android"
  echo "APK gerado em build/app/outputs/flutter-apk/"
fi

if [ "$TARGET" = "ios" ] || [ "$TARGET" = "all" ]; then
  echo "Building iOS release..."
  flutter build ios \
    --release \
    --obfuscate \
    --split-debug-info="$SYMBOLS_DIR/ios"
  echo "IPA gerado em build/ios/archive/"
fi

echo ""
echo "IMPORTANTE: Guarde a pasta '$SYMBOLS_DIR' para poder ler stacktraces de crashes em producao."
