# 📦 Building Release APK/App Bundle

## 🚀 Quick Build Commands

### **Android APK (Recommended for Testing)**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### **Android App Bundle (For Play Store)**
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### **Split APKs by ABI (Smaller file sizes)**
```bash
flutter build apk --split-per-abi --release
```
Output: 
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit Intel)

---

## 📱 Installation Methods

### **Method 1: Direct Install via USB**
```bash
# Build and install in one command
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

### **Method 2: Share APK File**
1. Build: `flutter build apk --release`
2. Find APK: `build/app/outputs/flutter-apk/app-release.apk`
3. Copy to your phone
4. Open and install (enable "Install from Unknown Sources")

### **Method 3: Upload to Drive/Dropbox**
1. Build APK
2. Upload `app-release.apk` to cloud storage
3. Download on phone and install

---

## 🔐 App Signing (Required for Play Store)

### **Generate Keystore (One-time setup)**
```bash
keytool -genkey -v -keystore C:\Users\devart\sagebible-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sagebible
```

You'll be asked:
- Password (remember this!)
- Name, Organization, City, State, Country
- Alias password (can be same as keystore password)

### **Configure Signing**

Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=sagebible
storeFile=C:\\Users\\devart\\sagebible-key.jks
```

Update `android/app/build.gradle.kts`:
```kotlin
// Add before android block
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // ... existing config ...
        }
    }
}
```

---

## 📊 Build Sizes

### **Typical Sizes:**
- **APK (all ABIs):** ~50-80 MB
- **APK (split per ABI):** ~20-30 MB each
- **App Bundle:** ~40-60 MB (Play Store optimizes this)

### **Reduce Size:**
```bash
# Enable code shrinking and obfuscation
flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info
```

---

## ✅ Pre-Release Checklist

Before building release:

### **1. Update Version**
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+build_number
```

### **2. Update App Name**
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="SageBible"
    ...>
```

### **3. Check Permissions**
Review `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<!-- Add only permissions you need -->
```

### **4. Test Release Build**
```bash
flutter build apk --release
flutter install
# Test all features!
```

### **5. Check App Icon**
- ✅ Icon generated for all sizes
- ✅ Looks good on device
- ✅ Adaptive icon works (Android 8+)

### **6. Check Splash Screen**
- ✅ Native splash shows your icon
- ✅ Flutter splash animates correctly
- ✅ Dark mode works

---

## 🎯 Build for Different Environments

### **Debug Build (Development)**
```bash
flutter build apk --debug
```

### **Profile Build (Performance Testing)**
```bash
flutter build apk --profile
```

### **Release Build (Production)**
```bash
flutter build apk --release
```

---

## 📤 Publishing to Google Play Store

### **1. Create App Bundle**
```bash
flutter build appbundle --release
```

### **2. Prepare Store Listing**
- App name: SageBible
- Short description: Your Daily Spiritual Companion
- Full description: (Write detailed description)
- Screenshots: (Take from your device)
- Feature graphic: 1024x500 px
- App icon: Already generated!

### **3. Upload to Play Console**
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Upload `app-release.aab`
4. Fill in store listing
5. Set content rating
6. Set pricing (Free)
7. Submit for review

---

## 🐛 Troubleshooting

### **Build fails?**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### **Signing errors?**
- Check `key.properties` file exists
- Verify keystore path is correct
- Ensure passwords are correct

### **APK too large?**
```bash
# Use split APKs
flutter build apk --split-per-abi --release

# Or use app bundle for Play Store
flutter build appbundle --release
```

### **App crashes on release?**
- Check for missing permissions
- Test with `--profile` build first
- Check logs: `adb logcat`

---

## 📱 Testing Release Build

### **Install on Device:**
```bash
# Via USB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or manually:
# 1. Copy APK to phone
# 2. Open file manager
# 3. Tap APK
# 4. Install
```

### **Test Checklist:**
- [ ] App icon shows correctly
- [ ] Splash screen works
- [ ] Google Sign-In works
- [ ] Guest mode works
- [ ] All screens load
- [ ] Dark mode works
- [ ] Navigation works
- [ ] No crashes

---

## 🎉 Quick Start

**To build and test right now:**

```bash
# 1. Build release APK
flutter build apk --release

# 2. Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# 3. Test the app!
```

**APK Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📚 Resources

- [Flutter Build Docs](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [App Signing Guide](https://developer.android.com/studio/publish/app-signing)

---

**Ready to build? Run the command below!** 🚀
