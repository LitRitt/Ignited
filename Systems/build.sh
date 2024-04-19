#!/bin/bash

# Fail if error occurs
set -e

SCHEME="Systems"
BUILD_DIR=".build"

CONFIG_FOLDER="${CONFIGURATION}-${PLATFORM_NAME}"
OUTPUT_DIR="$BUILD_DIR/Build/Products/$CONFIG_FOLDER"

xcodebuild -workspace Systems.xcworkspace -scheme $SCHEME -configuration ${CONFIGURATION} -destination "generic/platform=$PLATFORM_DISPLAY_NAME" -derivedDataPath $BUILD_DIR BITCODE_GENERATION_MODE=bitcode
        
cp -Rf "$OUTPUT_DIR/Systems.framework" "${BUILT_PRODUCTS_DIR}/"
