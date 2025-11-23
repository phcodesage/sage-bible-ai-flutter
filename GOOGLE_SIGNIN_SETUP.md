# Google Sign-In Setup Guide for Supabase

This guide will walk you through setting up Google Sign-In for your SageBible app with Supabase.

## 📋 Overview

You need to:
1. Create a Google Cloud Project
2. Configure OAuth consent screen
3. Create OAuth credentials
4. Configure Supabase with Google credentials
5. Test the integration

---

## 🚀 Step 1: Create Google Cloud Project

1. **Go to Google Cloud Console**: https://console.cloud.google.com/

2. **Create a new project** (or select existing):
   - Click the project dropdown at the top
   - Click **"New Project"**
   - Name: `SageBible` (or your preferred name)
   - Click **"Create"**
   - Wait for the project to be created

3. **Select your project**:
   - Make sure your new project is selected in the dropdown

---

## 🔐 Step 2: Configure OAuth Consent Screen

1. **Navigate to OAuth consent screen**:
   - In the left sidebar, go to: **APIs & Services** → **OAuth consent screen**
   - Or use this direct link: https://console.cloud.google.com/apis/credentials/consent

2. **Choose User Type**:
   - Select **"External"** (unless you have a Google Workspace)
   - Click **"Create"**

3. **Fill in App Information**:
   
   **App information:**
   - **App name**: `SageBible`
   - **User support email**: Your email address
   - **App logo**: (Optional) Upload your app icon

   **App domain:**
   - **Application home page**: (Optional) Your website
   - **Application privacy policy link**: (Optional)
   - **Application terms of service link**: (Optional)

   **Authorized domains:**
   - Add: `supabase.co`
   - Click **"Add Domain"**

   **Developer contact information:**
   - **Email addresses**: Your email address

4. **Click "Save and Continue"**

5. **Scopes** (Step 2):
   - Click **"Add or Remove Scopes"**
   - Select these scopes:
     - `./auth/userinfo.email`
     - `./auth/userinfo.profile`
     - `openid`
   - Click **"Update"**
   - Click **"Save and Continue"**

6. **Test users** (Step 3):
   - Click **"Add Users"**
   - Add your email address (for testing)
   - Click **"Add"**
   - Click **"Save and Continue"**

7. **Summary** (Step 4):
   - Review your settings
   - Click **"Back to Dashboard"**

---

## 🔑 Step 3: Create OAuth 2.0 Credentials

1. **Navigate to Credentials**:
   - In the left sidebar: **APIs & Services** → **Credentials**
   - Or: https://console.cloud.google.com/apis/credentials

2. **Create OAuth Client ID**:
   - Click **"+ Create Credentials"** at the top
   - Select **"OAuth client ID"**

3. **Configure the OAuth client**:
   
   **Application type**: Select **"Web application"**
   
   **Name**: `SageBible Web Client`

   **Authorized JavaScript origins**:
   - Click **"+ Add URI"**
   - Add: `https://idoosepbgjnfgufcvsfm.supabase.co`
   
   **Authorized redirect URIs**:
   - Click **"+ Add URI"**
   - Add: `https://idoosepbgjnfgufcvsfm.supabase.co/auth/v1/callback`
   
   ⚠️ **IMPORTANT**: Replace `idoosepbgjnfgufcvsfm` with your actual Supabase project reference ID

4. **Click "Create"**

5. **Save your credentials**:
   - A popup will show your **Client ID** and **Client Secret**
   - **Copy both** - you'll need them for Supabase
   - You can also download the JSON file
   - Click **"OK"**

---

## 🔧 Step 4: Configure Supabase

1. **Go to your Supabase Dashboard**:
   - https://idoosepbgjnfgufcvsfm.supabase.co

2. **Navigate to Authentication**:
   - Click **"Authentication"** in the left sidebar
   - Click **"Providers"**

3. **Enable Google Provider**:
   - Find **"Google"** in the list
   - Toggle it **ON** (enable)

4. **Configure Google Settings**:
   
   **Client ID (for OAuth)**:
   - Paste the **Client ID** from Google Cloud Console
   
   **Client Secret (for OAuth)**:
   - Paste the **Client Secret** from Google Cloud Console

   **Authorized Client IDs**:
   - Leave empty for now (used for native apps)

5. **Click "Save"**

---

## 📱 Step 5: Configure Android (Optional - for production)

If you want Google Sign-In to work on Android devices:

1. **Get SHA-1 fingerprint**:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 fingerprint from the debug keystore

2. **Add Android OAuth Client**:
   - Go back to Google Cloud Console → Credentials
   - Click **"+ Create Credentials"** → **"OAuth client ID"**
   - **Application type**: Android
   - **Name**: `SageBible Android`
   - **Package name**: `com.example.sagebible` (from your AndroidManifest.xml)
   - **SHA-1 certificate fingerprint**: Paste the SHA-1 from step 1
   - Click **"Create"**

3. **Update Supabase**:
   - Copy the Android Client ID
   - Go to Supabase → Authentication → Providers → Google
   - Add the Android Client ID to **"Authorized Client IDs"**
   - Click **"Save"**

---

## 🍎 Step 6: Configure iOS (Optional - for production)

If you want Google Sign-In to work on iOS devices:

1. **Add iOS OAuth Client**:
   - Go to Google Cloud Console → Credentials
   - Click **"+ Create Credentials"** → **"OAuth client ID"**
   - **Application type**: iOS
   - **Name**: `SageBible iOS`
   - **Bundle ID**: `com.example.sagebible` (from your Info.plist)
   - Click **"Create"**

2. **Update Supabase**:
   - Copy the iOS Client ID
   - Go to Supabase → Authentication → Providers → Google
   - Add the iOS Client ID to **"Authorized Client IDs"**
   - Click **"Save"**

3. **Update Info.plist**:
   - Add the reversed client ID as a URL scheme
   - Follow the google_sign_in package documentation

---

## ✅ Step 7: Test the Integration

1. **Run your Flutter app**:
   ```bash
   flutter run
   ```

2. **Test Google Sign-In**:
   - Tap **"Continue with Google"**
   - Select your Google account
   - Grant permissions
   - You should be signed in!

3. **Verify in Supabase**:
   - Go to Supabase Dashboard → **Authentication** → **Users**
   - You should see your user listed
   - Go to **Table Editor** → **profiles**
   - Your profile should be created automatically

---

## 🐛 Troubleshooting

### Error: "Access Denied"
- **Check redirect URI**: Make sure it matches exactly in Google Cloud Console
- **Check authorized origins**: Make sure Supabase URL is added
- **Check credentials**: Verify Client ID and Secret in Supabase

### Error: "Invalid Client"
- **Verify Client ID**: Make sure you copied it correctly to Supabase
- **Check OAuth consent screen**: Make sure it's configured and published

### Error: "Redirect URI Mismatch"
- **Format**: Must be `https://YOUR-PROJECT.supabase.co/auth/v1/callback`
- **No trailing slash**: Don't add `/` at the end
- **Exact match**: Must match exactly what's in Google Cloud Console

### Google Sign-In popup doesn't appear
- **Check browser**: Make sure popups are not blocked
- **Check console**: Look for errors in browser developer tools
- **Try incognito**: Test in incognito/private mode

### User created but profile not created
- **Check migration**: Make sure you ran the SQL migration
- **Check trigger**: Verify the `on_auth_user_created` trigger exists
- **Check logs**: Look at Supabase logs for errors

---

## 📊 Verify Setup Checklist

- [ ] Google Cloud Project created
- [ ] OAuth consent screen configured
- [ ] OAuth 2.0 credentials created (Web application)
- [ ] Client ID and Secret copied
- [ ] Supabase Google provider enabled
- [ ] Client ID pasted in Supabase
- [ ] Client Secret pasted in Supabase
- [ ] Redirect URI matches: `https://YOUR-PROJECT.supabase.co/auth/v1/callback`
- [ ] Authorized origin matches: `https://YOUR-PROJECT.supabase.co`
- [ ] Test user added to OAuth consent screen
- [ ] SQL migration run in Supabase
- [ ] Tested sign-in in app

---

## 🔒 Security Notes

### Client Secret
- ✅ Safe to use in Supabase (server-side)
- ❌ Never commit to version control
- ❌ Never expose in client-side code

### Scopes
- Only request necessary scopes (email, profile)
- Users see what data you're requesting
- Minimal scopes = better user trust

### Testing
- Use test users during development
- Publish OAuth consent screen for production
- Review Google's verification requirements for production

---

## 📚 Useful Links

- **Google Cloud Console**: https://console.cloud.google.com/
- **Supabase Auth Docs**: https://supabase.com/docs/guides/auth/social-login/auth-google
- **Google Sign-In Docs**: https://developers.google.com/identity/sign-in/web
- **OAuth 2.0 Playground**: https://developers.google.com/oauthplayground/

---

## 🎯 Quick Reference

### Your Credentials Location:

**Google Cloud Console**:
- Project: `SageBible`
- Credentials: https://console.cloud.google.com/apis/credentials

**Supabase Dashboard**:
- Project: https://idoosepbgjnfgufcvsfm.supabase.co
- Auth Settings: Authentication → Providers → Google

### Important URLs:

**Redirect URI**:
```
https://idoosepbgjnfgufcvsfm.supabase.co/auth/v1/callback
```

**Authorized Origin**:
```
https://idoosepbgjnfgufcvsfm.supabase.co
```

---

## ✨ Next Steps

Once Google Sign-In is working:

1. ✅ Users can sign in with one tap
2. ✅ Profiles are created automatically
3. ✅ Data syncs across devices
4. ✅ Ready for production!

**Happy coding! 🚀**
