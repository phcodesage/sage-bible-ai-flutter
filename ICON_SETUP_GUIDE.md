# 🎨 App Icon Setup Guide

## 📍 Step 1: Place Your Icon

Save your icon file as:
```
assets/icon.png
```

**Requirements:**
- ✅ Size: **1024x1024 pixels** (recommended)
- ✅ Format: **PNG** with transparency
- ✅ Minimum: 512x512 pixels

---

## 🚀 Step 2: Install Dependencies

Run this command:
```bash
flutter pub get
```

---

## ⚙️ Step 3: Generate Icons

Run this command to generate icons for all platforms:
```bash
flutter pub run flutter_launcher_icons
```

This will automatically create:
- ✅ **Android** icons (all sizes)
- ✅ **iOS** icons (all sizes)
- ✅ **Web** icons (favicon, etc.)
- ✅ **Windows** icons
- ✅ **macOS** icons
- ✅ **Android Adaptive Icons** (Android 8.0+)

---

## 📱 What Gets Generated

### **Android:**
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Adaptive icons with your blue-gray background

### **iOS:**
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- All required sizes for iPhone and iPad

### **Web:**
- `web/icons/Icon-*.png`
- `web/favicon.png`

### **Windows:**
- `windows/runner/resources/app_icon.ico`

### **macOS:**
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## 🎨 Icon Configuration Details

Your icon is configured with:
- **Background Color:** `#5B7C99` (your blue-gray)
- **Adaptive Icons:** Enabled for Android 8.0+
- **All Platforms:** Enabled

---

## ✅ Verification

After generating, verify the icons:

### **Android:**
```bash
# Check if icons exist
ls android/app/src/main/res/mipmap-hdpi/
```

### **iOS:**
```bash
# Check if icons exist
ls ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

### **Test on Device:**
```bash
# Run on Android
flutter run

# Check the app icon on your device home screen
```

---

## 🔄 Updating Icons

If you change your icon:
1. Replace `assets/icon.png` with new icon
2. Run: `flutter pub run flutter_launcher_icons`
3. Rebuild your app: `flutter run`

---

## 🎯 Adaptive Icons (Android)

Your app uses adaptive icons with:
- **Foreground:** Your icon image
- **Background:** Solid blue-gray color (#5B7C99)

This creates a modern look on Android 8.0+ devices with:
- Circular icons (Pixel devices)
- Rounded square icons (Samsung devices)
- Squircle icons (OnePlus devices)

---

## 💡 Tips

### **For Best Results:**
- ✅ Use a **square** icon design (not circular)
- ✅ Keep important elements **centered**
- ✅ Avoid text (hard to read at small sizes)
- ✅ Use **high contrast** colors
- ✅ Test on multiple devices

### **Icon Design Guidelines:**
- **Safe zone:** Keep important content within 80% of canvas
- **Padding:** Leave 10% padding on all sides
- **Simplicity:** Simple designs work best at small sizes

---

## 🐛 Troubleshooting

### **Icons not updating?**
```bash
# Clean build
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
flutter run
```

### **Android icons not showing?**
- Uninstall the app completely
- Reinstall: `flutter run`
- Clear launcher cache (device settings)

### **iOS icons not showing?**
- Clean Xcode build folder
- Delete app from device
- Rebuild: `flutter run`

---

## 📚 Resources

- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)

---

**Your icon setup is ready! Just place your icon and run the commands above.** 🎉
