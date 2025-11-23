## Native Google Sign-In Setup (Android & iOS)

Your app now supports **native Google Sign-In** that works without a browser! This provides a better user experience on mobile devices.

## 🎯 How It Works

### **Web** (Browser-based):
- Opens browser popup
- Uses OAuth redirect flow
- Works on any device with a browser

### **Mobile** (Native):
- Uses native Google Sign-In UI
- No browser needed ✅
- Works on devices without Chrome
- Better UX with native dialogs
- Faster and more secure

---

## 📋 Setup Steps

### Step 1: Get Your Web Client ID

1. Go to **Google Cloud Console**: https://console.cloud.google.com/apis/credentials

2. Find your **Web application** OAuth client (the one you created earlier)

3. Copy the **Client ID** - it looks like:
   ```
   123456789-abcdefghijk.apps.googleusercontent.com
   ```

4. **Paste it in your app**:
   - Open: `lib/core/config/google_config.dart`
   - Replace `YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com` with your actual Web Client ID

   ```dart
   static const String webClientId = '123456789-abcdefghijk.apps.googleusercontent.com';
   ```

---

### Step 2: Configure Android

#### 2.1 Get SHA-1 Fingerprint

```bash
cd android
./gradlew signingReport
```

Copy the **SHA-1** from the **debug** keystore. It looks like:
```
SHA1: 12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78
```

#### 2.2 Create Android OAuth Client

1. Go to **Google Cloud Console** → **Credentials**
2. Click **"+ Create Credentials"** → **"OAuth client ID"**
3. **Application type**: Android
4. **Name**: `SageBible Android`
5. **Package name**: `com.example.sagebible` (check your `AndroidManifest.xml`)
6. **SHA-1 certificate fingerprint**: Paste the SHA-1 from step 2.1
7. Click **"Create"**

#### 2.3 Add Android Client ID to Supabase

1. Copy the **Android Client ID** (looks like: `xxxxx.apps.googleusercontent.com`)
2. Go to **Supabase Dashboard** → **Authentication** → **Providers** → **Google**
3. In **"Authorized Client IDs"** field, add your Android Client ID
4. Click **"Save"**

---

### Step 3: Configure iOS (Optional)

#### 3.1 Get Bundle ID

Check your `ios/Runner/Info.plist` for the Bundle Identifier:
```xml
<key>CFBundleIdentifier</key>
<string>com.example.sagebible</string>
```

#### 3.2 Create iOS OAuth Client

1. Go to **Google Cloud Console** → **Credentials**
2. Click **"+ Create Credentials"** → **"OAuth client ID"**
3. **Application type**: iOS
4. **Name**: `SageBible iOS`
5. **Bundle ID**: `com.example.sagebible` (from step 3.1)
6. Click **"Create"**

#### 3.3 Add iOS Client ID to Supabase

1. Copy the **iOS Client ID**
2. Go to **Supabase Dashboard** → **Authentication** → **Providers** → **Google**
3. In **"Authorized Client IDs"** field, add your iOS Client ID (comma-separated if you have multiple)
4. Click **"Save"**

#### 3.4 Update Info.plist

Add the reversed client ID as a URL scheme:

1. Open `ios/Runner/Info.plist`
2. Add this (replace with your iOS Client ID reversed):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reverse of iOS Client ID -->
            <string>com.googleusercontent.apps.123456789-abcdefghijk</string>
        </array>
    </dict>
</array>
```

---

## 🔧 Configuration Summary

You'll have **3 OAuth clients** in Google Cloud Console:

1. **Web application** - For web and as serverClientId for mobile
   - Used for: Web OAuth flow
   - Used for: Mobile native sign-in (serverClientId)

2. **Android** - For native Android sign-in
   - Package name + SHA-1 fingerprint
   - Add to Supabase "Authorized Client IDs"

3. **iOS** - For native iOS sign-in
   - Bundle ID
   - Add to Supabase "Authorized Client IDs"
   - Add reversed client ID to Info.plist

---

## ✅ Verification Checklist

### Web Client ID:
- [ ] Created in Google Cloud Console
- [ ] Added to `lib/core/config/google_config.dart`
- [ ] Used in Supabase Google provider settings

### Android:
- [ ] SHA-1 fingerprint obtained
- [ ] Android OAuth client created
- [ ] Android Client ID added to Supabase "Authorized Client IDs"
- [ ] Package name matches AndroidManifest.xml

### iOS (if targeting iOS):
- [ ] Bundle ID obtained
- [ ] iOS OAuth client created
- [ ] iOS Client ID added to Supabase "Authorized Client IDs"
- [ ] Reversed client ID added to Info.plist

### Supabase:
- [ ] Google provider enabled
- [ ] Web Client ID and Secret configured
- [ ] Android Client ID in "Authorized Client IDs"
- [ ] iOS Client ID in "Authorized Client IDs" (if applicable)

---

## 🧪 Testing

### Test on Android:
1. Run: `flutter run`
2. Tap "Continue with Google"
3. Native Google account picker appears ✅
4. Select account
5. Grant permissions
6. Signed in!

### Test on Web:
1. Run: `flutter run -d chrome`
2. Tap "Continue with Google"
3. Browser popup opens
4. Select account
5. Signed in!

---

## 🎯 Platform Detection

The app automatically detects the platform:

```dart
// Web → Uses OAuth (browser popup)
if (kIsWeb) {
  return await _signInWithGoogleWeb();
}

// Android/iOS → Uses native Google Sign-In
else {
  return await _signInWithGoogleNative();
}
```

---

## 🐛 Troubleshooting

### Android: "Developer Error" or "Sign-in failed"

**Cause**: SHA-1 fingerprint mismatch or Android Client ID not in Supabase

**Solution**:
1. Verify SHA-1 matches in Google Cloud Console
2. Check package name matches exactly
3. Ensure Android Client ID is in Supabase "Authorized Client IDs"
4. Try uninstalling and reinstalling the app

### Android: "Sign-in cancelled"

**Cause**: Google Play Services not installed or outdated

**Solution**:
1. Update Google Play Services on the device
2. Test on a real device (not all emulators have Play Services)

### iOS: "Sign-in failed"

**Cause**: Bundle ID mismatch or missing URL scheme

**Solution**:
1. Verify Bundle ID matches in Google Cloud Console
2. Check reversed client ID in Info.plist
3. Ensure iOS Client ID is in Supabase "Authorized Client IDs"

### Web: Still works but mobile doesn't

**Cause**: Missing Android/iOS OAuth clients or not added to Supabase

**Solution**:
1. Create platform-specific OAuth clients
2. Add their Client IDs to Supabase "Authorized Client IDs"

---

## 📱 Example: Complete Supabase Configuration

In Supabase → Authentication → Providers → Google:

**Client ID (for OAuth)**:
```
123456789-web.apps.googleusercontent.com
```

**Client Secret (for OAuth)**:
```
GOCSPX-xxxxxxxxxxxxxxxxxxxxx
```

**Authorized Client IDs**:
```
123456789-android.apps.googleusercontent.com,123456789-ios.apps.googleusercontent.com
```

---

## 🎉 Benefits of Native Sign-In

✅ **Works without browser** - No Chrome needed!
✅ **Better UX** - Native Google account picker
✅ **Faster** - No redirect delays
✅ **More secure** - Uses device's Google account
✅ **Offline accounts** - Can use cached Google accounts
✅ **Professional** - Looks like native apps

---

## 📚 Next Steps

1. **Add Web Client ID** to `google_config.dart`
2. **Create Android OAuth client** (if targeting Android)
3. **Create iOS OAuth client** (if targeting iOS)
4. **Add Client IDs to Supabase**
5. **Test on real devices**
6. **Deploy to production!**

---

## 🔗 Useful Links

- **Google Sign-In Flutter**: https://pub.dev/packages/google_sign_in
- **Supabase Auth**: https://supabase.com/docs/guides/auth/social-login/auth-google
- **Google Cloud Console**: https://console.cloud.google.com/apis/credentials

---

**Your app now has professional-grade Google Sign-In! 🚀**
