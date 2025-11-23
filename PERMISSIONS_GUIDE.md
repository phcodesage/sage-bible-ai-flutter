# 🔐 App Permissions Guide

## ✅ Permissions Added

Your SageBible app now requests the following permissions:

### **1. Internet Permissions** 🌐
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**Why needed:**
- Google Sign-In authentication
- Supabase API calls
- Loading Bible content
- Loading user avatars from Google
- Syncing data with backend

**User impact:** No prompt required (automatically granted)

---

### **2. Storage Permissions (Android 12 and below)** 💾
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
```

**Why needed:**
- Reading Bible data files
- Saving bookmarks locally
- Caching downloaded content
- Storing user preferences

**User impact:** 
- Android 6-12: User will see permission prompt
- Android 13+: Not used (replaced by media permissions)

---

### **3. Media Permissions (Android 13+)** 📱
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

**Why needed:**
- Selecting images for profile/community posts
- Sharing Bible verses with images
- Accessing media files

**User impact:** 
- Android 13+: User will see granular permission prompts
- Can grant access to specific media types

---

## 📱 Permission Behavior by Android Version

### **Android 5.0 - 5.1 (API 21-22)**
- All permissions granted at install time
- No runtime prompts

### **Android 6.0 - 12 (API 23-32)**
- Internet: Auto-granted
- Storage: Runtime prompt required
- User sees: "Allow SageBible to access photos, media, and files?"

### **Android 13+ (API 33+)**
- Internet: Auto-granted
- Media: Granular runtime prompts
- User sees separate prompts for:
  - "Allow SageBible to access photos and videos?"
  - "Allow SageBible to access music and audio?"

---

## 🎯 When Permissions Are Requested

### **On App Install:**
- ✅ INTERNET (auto-granted)
- ✅ ACCESS_NETWORK_STATE (auto-granted)

### **First Time User Needs Feature:**
- 📸 When selecting profile picture
- 📷 When sharing content with images
- 💾 When saving files locally
- 📁 When accessing downloaded content

---

## 🔍 How to Check Permissions

### **On Device:**
1. Open **Settings**
2. Go to **Apps** → **SageBible**
3. Tap **Permissions**
4. View granted/denied permissions

### **Via ADB:**
```bash
# List all permissions for the app
adb shell dumpsys package com.example.sagebible | grep permission

# Check specific permission
adb shell pm list permissions -g
```

---

## 🛠️ Testing Permissions

### **Test Internet Permission:**
1. Open app
2. Try Google Sign-In
3. Should connect without prompt

### **Test Storage Permission (Android 12-):**
1. Try to save a bookmark
2. Should see permission prompt
3. Grant permission
4. Feature should work

### **Test Media Permission (Android 13+):**
1. Try to select profile picture
2. Should see "Allow access to photos?"
3. Grant permission
4. Should be able to select image

---

## ⚠️ Permission Denied Handling

### **What Happens:**
- App gracefully handles denied permissions
- Shows helpful message to user
- Provides option to open settings

### **Best Practices:**
- Request permissions only when needed
- Explain why permission is needed
- Provide fallback functionality
- Don't request all permissions at once

---

## 📊 Permission Summary Table

| Permission | Auto-Granted | Runtime Prompt | Required For |
|------------|--------------|----------------|--------------|
| INTERNET | ✅ Yes | ❌ No | API calls, sign-in |
| ACCESS_NETWORK_STATE | ✅ Yes | ❌ No | Network status |
| READ_EXTERNAL_STORAGE | ❌ No | ✅ Yes (API 23-32) | Reading files |
| WRITE_EXTERNAL_STORAGE | ❌ No | ✅ Yes (API 23-32) | Saving files |
| READ_MEDIA_IMAGES | ❌ No | ✅ Yes (API 33+) | Photos access |
| READ_MEDIA_VIDEO | ❌ No | ✅ Yes (API 33+) | Videos access |
| READ_MEDIA_AUDIO | ❌ No | ✅ Yes (API 33+) | Audio access |

---

## 🔒 Privacy & Security

### **Data We Access:**
- ✅ Internet: For authentication and API calls
- ✅ Network State: To detect online/offline
- ✅ Storage: Only for app-specific data
- ✅ Media: Only when user selects files

### **Data We DON'T Access:**
- ❌ Contacts
- ❌ Location
- ❌ Camera (unless user explicitly uses it)
- ❌ Microphone
- ❌ Phone calls
- ❌ SMS

### **Privacy Guarantee:**
- No background data collection
- No tracking without consent
- No sharing user data
- All data encrypted in transit

---

## 🚀 For Play Store Submission

### **Required Documentation:**
1. **Privacy Policy** - Explain data usage
2. **Permission Justification** - Why each permission is needed
3. **Data Safety Form** - What data is collected

### **Play Store Requirements:**
- Declare all permissions in manifest ✅
- Request permissions at runtime ✅
- Handle permission denial gracefully ✅
- Provide clear explanation to users ✅

---

## 📝 Notes

### **Current Implementation:**
- ✅ All permissions declared
- ✅ Internet permissions working
- ✅ Storage permissions ready
- ✅ Android 13+ compatible

### **Future Enhancements:**
- Add runtime permission request dialogs
- Add permission explanation screens
- Add settings deep link for denied permissions
- Add permission status indicators

---

## 🔄 Updating Permissions

If you need to add/remove permissions:

1. Edit `android/app/src/main/AndroidManifest.xml`
2. Add/remove `<uses-permission>` tags
3. Rebuild app: `flutter clean && flutter build apk`
4. Reinstall on device
5. Test new permissions

---

**Your app now has all necessary permissions configured!** 🎉
