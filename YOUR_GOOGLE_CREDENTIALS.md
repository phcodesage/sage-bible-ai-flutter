# Your Google Sign-In Credentials

## 📱 Package Name
```
com.example.sagebible
```

## 🔑 SHA-1 Fingerprint (Debug)
```
C0:19:5F:FD:95:F1:5A:50:3F:4F:09:65:21:FF:BB:63:91:8A:62:2A
```

---

## 🚀 Next Steps

### Step 1: Create Android OAuth Client in Google Cloud Console

1. Go to: https://console.cloud.google.com/apis/credentials

2. Click **"+ Create Credentials"** → **"OAuth client ID"**

3. Fill in:
   - **Application type**: Android
   - **Name**: `SageBible Android`
   - **Package name**: `com.example.sagebible`
   - **SHA-1 certificate fingerprint**: `C0:19:5F:FD:95:F1:5A:50:3F:4F:09:65:21:FF:BB:63:91:8A:62:2A`

4. Click **"Create"**

5. **Copy the Client ID** (it will look like: `xxxxx-xxxxx.apps.googleusercontent.com`)

---

### Step 2: Add Android Client ID to Supabase

1. Go to: https://idoosepbgjnfgufcvsfm.supabase.co

2. Navigate to: **Authentication** → **Providers** → **Google**

3. In the **"Authorized Client IDs"** field, add your Android Client ID

4. Click **"Save"**

---

### Step 3: Add Web Client ID to Your App

1. In Google Cloud Console, find your **Web application** OAuth client

2. Copy the **Web Client ID**

3. Open: `lib/core/config/google_config.dart`

4. Replace:
   ```dart
   static const String webClientId = 'YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com';
   ```
   
   With your actual Web Client ID:
   ```dart
   static const String webClientId = 'xxxxx-xxxxx.apps.googleusercontent.com';
   ```

---

## ✅ Verification Checklist

- [ ] Android OAuth client created in Google Cloud Console
- [ ] Package name: `com.example.sagebible`
- [ ] SHA-1: `C0:19:5F:FD:95:F1:5A:50:3F:4F:09:65:21:FF:BB:63:91:8A:62:2A`
- [ ] Android Client ID copied
- [ ] Android Client ID added to Supabase "Authorized Client IDs"
- [ ] Web Client ID added to `lib/core/config/google_config.dart`
- [ ] Tested on Android device/emulator

---

## 📝 Example Configuration

### In Google Cloud Console:

**Web OAuth Client**:
- Client ID: `123456789-web.apps.googleusercontent.com`
- Client Secret: `GOCSPX-xxxxxxxxxxxxx`

**Android OAuth Client**:
- Client ID: `123456789-android.apps.googleusercontent.com`
- Package name: `com.example.sagebible`
- SHA-1: `C0:19:5F:FD:95:F1:5A:50:3F:4F:09:65:21:FF:BB:63:91:8A:62:2A`

### In Supabase (Authentication → Providers → Google):

**Client ID (for OAuth)**:
```
123456789-web.apps.googleusercontent.com
```

**Client Secret (for OAuth)**:
```
GOCSPX-xxxxxxxxxxxxx
```

**Authorized Client IDs**:
```
123456789-android.apps.googleusercontent.com
```

### In Your App (`lib/core/config/google_config.dart`):

```dart
static const String webClientId = '123456789-web.apps.googleusercontent.com';
```

---

## 🧪 Testing

After setup:

1. Run the app:
   ```bash
   flutter run
   ```

2. Tap **"Continue with Google"**

3. Native Google account picker should appear

4. Select your account

5. You should be signed in! ✅

---

## 🔗 Quick Links

- **Google Cloud Console**: https://console.cloud.google.com/apis/credentials
- **Supabase Dashboard**: https://idoosepbgjnfgufcvsfm.supabase.co
- **Your Package**: `com.example.sagebible`

---

**You're all set! Follow the steps above to complete the setup.** 🎉
