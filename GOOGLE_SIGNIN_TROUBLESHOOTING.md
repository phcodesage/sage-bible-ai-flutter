# Google Sign-In Troubleshooting

## ✅ Updated Implementation

I've updated the Google Sign-In to use **Supabase's native OAuth flow** instead of the `google_sign_in` package. This is the correct approach for Supabase integration.

## 🔧 What Changed

### Before (❌ Old Method):
- Used `google_sign_in` package
- Required manual token exchange
- More complex setup

### After (✅ New Method):
- Uses Supabase's `signInWithOAuth()`
- Handles everything automatically
- Simpler and more reliable

## 📝 Setup Requirements

For Google Sign-In to work, you MUST complete these steps:

### 1. Google Cloud Console Setup
- [ ] Create a Google Cloud Project
- [ ] Configure OAuth consent screen
- [ ] Create OAuth 2.0 Web credentials
- [ ] Add redirect URI: `https://idoosepbgjnfgufcvsfm.supabase.co/auth/v1/callback`
- [ ] Add authorized origin: `https://idoosepbgjnfgufcvsfm.supabase.co`

### 2. Supabase Configuration
- [ ] Enable Google provider in Supabase
- [ ] Add Google Client ID
- [ ] Add Google Client Secret
- [ ] Save settings

## 🐛 Common Issues & Solutions

### Issue 1: "Login Failed" with no details
**Cause**: Google OAuth not configured in Supabase

**Solution**:
1. Go to Supabase Dashboard → Authentication → Providers
2. Enable Google
3. Add your Client ID and Client Secret from Google Cloud Console
4. Click Save

### Issue 2: Redirect URI Mismatch
**Error**: `redirect_uri_mismatch`

**Solution**:
1. In Google Cloud Console → Credentials → Your OAuth Client
2. Add this EXACT redirect URI:
   ```
   https://idoosepbgjnfgufcvsfm.supabase.co/auth/v1/callback
   ```
3. No trailing slash!
4. Must match exactly

### Issue 3: "Access Denied" or "Invalid Client"
**Cause**: Wrong Client ID or Secret in Supabase

**Solution**:
1. Double-check your Client ID in Google Cloud Console
2. Copy it again
3. Paste it in Supabase → Authentication → Providers → Google
4. Do the same for Client Secret
5. Save

### Issue 4: OAuth consent screen not configured
**Error**: `invalid_request` or `consent_required`

**Solution**:
1. Go to Google Cloud Console → APIs & Services → OAuth consent screen
2. Complete all required fields
3. Add test users (your email)
4. Save

### Issue 5: Popup blocked
**Cause**: Browser blocking the OAuth popup

**Solution**:
1. Allow popups for your app
2. Try in a different browser
3. Check browser console for errors

## 🧪 Testing Steps

### Test 1: Basic OAuth Flow
1. Run the app: `flutter run`
2. Tap "Continue with Google"
3. A browser window should open
4. Select your Google account
5. Grant permissions
6. Should redirect back and sign you in

### Test 2: Verify in Supabase
1. After signing in, go to Supabase Dashboard
2. Authentication → Users
3. You should see your user listed
4. Table Editor → profiles
5. Your profile should exist

### Test 3: Check Logs
1. Supabase Dashboard → Logs → Auth Logs
2. Look for any errors
3. Check for successful sign-in events

## 📱 Platform-Specific Notes

### Web (Current)
- ✅ Works with Supabase OAuth
- Opens in browser popup
- Redirects back to app

### Android (Future)
- Needs additional OAuth client (Android type)
- Requires SHA-1 fingerprint
- Add to "Authorized Client IDs" in Supabase

### iOS (Future)
- Needs additional OAuth client (iOS type)
- Requires Bundle ID
- Add to "Authorized Client IDs" in Supabase

## 🔍 Debug Checklist

If Google Sign-In still doesn't work, check:

- [ ] Supabase is initialized in `main.dart`
- [ ] Supabase URL and anon key are correct in `supabase_config.dart`
- [ ] Google provider is enabled in Supabase
- [ ] Client ID is correct in Supabase
- [ ] Client Secret is correct in Supabase
- [ ] Redirect URI matches exactly in Google Cloud Console
- [ ] Authorized origin is added in Google Cloud Console
- [ ] OAuth consent screen is configured
- [ ] Test user is added (your email)
- [ ] Browser allows popups
- [ ] No errors in browser console
- [ ] No errors in Supabase logs

## 🚀 Quick Test

Run this to test:

```bash
flutter run
```

Then:
1. Tap "Continue with Google"
2. Watch the console for errors
3. Check browser developer tools (F12) for errors
4. Check Supabase logs for errors

## 📊 Expected Behavior

### Success Flow:
1. User taps "Continue with Google"
2. Browser popup opens with Google sign-in
3. User selects account and grants permissions
4. Popup closes
5. User is redirected to home screen
6. User appears in Supabase → Authentication → Users
7. Profile created in Supabase → profiles table

### Error Flow:
1. User taps "Continue with Google"
2. Error message appears
3. Check the error message
4. Follow troubleshooting steps above

## 💡 Tips

1. **Use incognito mode** for testing to avoid cached credentials
2. **Check Supabase logs** - they show detailed error messages
3. **Test with your own email** added as a test user
4. **Clear browser cache** if you're getting weird errors
5. **Restart the app** after making configuration changes

## 📞 Still Having Issues?

If you're still stuck:

1. **Check the error message** - what exactly does it say?
2. **Check Supabase logs** - Authentication → Logs
3. **Check browser console** - Press F12 and look for errors
4. **Verify all credentials** - Double-check everything matches
5. **Try a different browser** - Sometimes browser extensions interfere

## ✨ Once It Works

After successful Google Sign-In:
- ✅ Users can sign in with one tap
- ✅ No password needed
- ✅ Secure OAuth 2.0 flow
- ✅ Automatic profile creation
- ✅ Cloud sync enabled
- ✅ Ready for production!

---

**The implementation is now correct. Just complete the Google Cloud Console and Supabase setup!** 🎉
