# SageBible Setup Guide

## Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio with Flutter plugins

## Installation

### 1. Clone and Install Dependencies

```bash
# Navigate to project directory
cd sagebible

# Get Flutter dependencies
flutter pub get

# Verify installation
flutter doctor
```

### 2. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run in debug mode with hot reload
flutter run --debug

# Run in release mode (optimized)
flutter run --release
```

## Native Splash Screen Setup

### Android Splash Screen

#### Option 1: Using flutter_native_splash (Recommended)

1. Add dependency to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_native_splash: ^2.3.10
```

2. Add configuration to `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#FAF9F6"  # Background color
  image: assets/images/splash_logo.png  # Your logo (must be 1152x1152px)
  android: true
  ios: true
  web: false
  
  android_12:
    image: assets/images/splash_logo.png
    color: "#FAF9F6"
```

3. Create splash logo:
   - Create a 1152x1152px PNG image
   - Save as `assets/images/splash_logo.png`

4. Generate splash screens:
```bash
flutter pub get
flutter pub run flutter_native_splash:create
```

#### Option 2: Manual Android Setup

1. Edit `android/app/src/main/res/values/styles.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

2. Edit `android/app/src/main/res/drawable/launch_background.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_color" />
    <item>
        <bitmap
            android:gravity="center"
            android:src="@drawable/splash_logo" />
    </item>
</layer-list>
```

3. Add color in `android/app/src/main/res/values/colors.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="splash_color">#FAF9F6</color>
</resources>
```

4. Add your logo as `android/app/src/main/res/drawable/splash_logo.png`

### iOS Splash Screen

#### Option 1: Using flutter_native_splash (Recommended)

Use the same configuration as Android above. The package handles iOS automatically.

#### Option 2: Manual iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode

2. Select `Runner` → `Runner` → `LaunchScreen.storyboard`

3. Design your splash screen in Interface Builder:
   - Set background color to `#FAF9F6`
   - Add UIImageView with your logo
   - Center it with constraints

4. Add logo to `ios/Runner/Assets.xcassets/LaunchImage.imageset/`

## App Icon Setup

### Using flutter_launcher_icons (Recommended)

1. Add dependency to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

2. Add configuration to `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"  # 1024x1024px PNG
  adaptive_icon_background: "#FAF9F6"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
```

3. Create app icons:
   - Main icon: 1024x1024px PNG
   - Android adaptive foreground: 1024x1024px PNG (with padding)

4. Generate icons:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## Google Fonts Setup

Google Fonts are already configured in the project. They will be downloaded automatically on first use.

**To use offline fonts:**

1. Download fonts from [Google Fonts](https://fonts.google.com/)
2. Add to `assets/fonts/` directory
3. Update `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: Merriweather
      fonts:
        - asset: assets/fonts/Merriweather-Regular.ttf
        - asset: assets/fonts/Merriweather-Bold.ttf
          weight: 700
    - family: Lato
      fonts:
        - asset: assets/fonts/Lato-Regular.ttf
        - asset: assets/fonts/Lato-Bold.ttf
          weight: 700
```

4. Update `app_theme.dart` to use local fonts:
```dart
TextStyle(
  fontFamily: 'Merriweather',
  // ... other properties
)
```

## Environment Configuration

### Development vs Production

Create environment-specific configuration files:

1. Create `lib/core/config/env_config.dart`:
```dart
class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
}
```

2. Run with environment variables:
```bash
# Development
flutter run --dart-define=API_BASE_URL=https://dev-api.example.com

# Production
flutter run --release --dart-define=API_BASE_URL=https://api.example.com --dart-define=PRODUCTION=true
```

## Firebase Setup (Optional)

If you want to add Firebase for authentication, analytics, or crashlytics:

### 1. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2. Configure Firebase

```bash
flutterfire configure
```

### 3. Add Firebase Dependencies

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
```

### 4. Initialize Firebase in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ... rest of initialization
}
```

## Building for Production

### Android APK

```bash
# Build APK
flutter build apk --release

# Build split APKs (smaller size)
flutter build apk --split-per-abi

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build iOS app
flutter build ios --release

# Then open in Xcode to archive and upload
open ios/Runner.xcworkspace
```

## Code Signing

### Android

1. Create keystore:
```bash
keytool -genkey -v -keystore ~/sagebible-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sagebible
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=sagebible
storeFile=<path-to-keystore>
```

3. Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### iOS

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Runner → Signing & Capabilities
3. Select your team
4. Xcode will handle provisioning profiles

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_service_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Integration Tests

```bash
# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Troubleshooting

### Common Issues

1. **Gradle build fails (Android)**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **CocoaPods issues (iOS)**
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter clean
   flutter pub get
   ```

3. **Google Fonts not loading**
   - Check internet connection
   - Or use local fonts (see Google Fonts Setup above)

4. **Hot reload not working**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Development Tips

### VS Code Extensions

- Flutter
- Dart
- Flutter Riverpod Snippets
- Error Lens
- GitLens

### Useful Commands

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Update dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated

# Generate code (if using build_runner)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hot Reload vs Hot Restart

- **Hot Reload** (r): Fast, preserves state
- **Hot Restart** (R): Slower, resets state
- **Full Restart** (q + flutter run): Complete rebuild

## Next Steps

1. Run the app: `flutter run`
2. Test authentication flow
3. Customize theme colors in `app_theme.dart`
4. Add your app logo to assets
5. Set up native splash screens
6. Configure app icons
7. Integrate with your backend API
8. Add more features!

## Support

For issues or questions:
- Check Flutter documentation: https://docs.flutter.dev
- Riverpod documentation: https://riverpod.dev
- GoRouter documentation: https://pub.dev/packages/go_router
