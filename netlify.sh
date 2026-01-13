#!/bin/bash

# Install Flutter SDK
echo "Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Configure Flutter for web
echo "Configuring Flutter for web..."
flutter config --enable-web

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build web app
echo "Building web app..."
flutter build web --release

echo "Build complete!"
