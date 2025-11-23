# SageBible Supabase Setup Guide

This guide will help you connect your SageBible app to Supabase and set up the complete database schema.

## 📋 Prerequisites

- A Supabase account (sign up at [supabase.com](https://supabase.com))
- Flutter development environment set up

## 🚀 Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click **"New Project"**
3. Fill in the project details:
   - **Name**: SageBible (or your preferred name)
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose the closest region to your users
4. Click **"Create new project"**
5. Wait for the project to be provisioned (takes ~2 minutes)

## 🔑 Step 2: Get Your API Credentials

1. In your Supabase project dashboard, go to **Settings** (gear icon) → **API**
2. You'll need two values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon/public key** (under "Project API keys")

## ⚙️ Step 3: Configure Your Flutter App

1. Open `lib/core/config/supabase_config.dart`
2. Replace the placeholder values with your actual credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

**⚠️ IMPORTANT**: Never commit real credentials to public repositories!

## 🗄️ Step 4: Run the Database Migration

1. In your Supabase dashboard, go to **SQL Editor**
2. Click **"New query"**
3. Open the file `supabase_migration.sql` in your project root
4. Copy the entire contents of the file
5. Paste it into the SQL Editor
6. Click **"Run"** (or press Ctrl+Enter)
7. Wait for the migration to complete

### What This Migration Creates:

#### Tables:
- ✅ **profiles** - Extended user profile information with avatars
- ✅ **bookmarks** - User's bookmarked Bible verses
- ✅ **highlights** - Highlighted verses with colors (yellow, green, blue, pink, purple)
- ✅ **notes** - Personal notes on verses
- ✅ **search_history** - User's search queries
- ✅ **community_posts** - User posts about Bible verses (like Facebook)
- ✅ **post_reactions** - Reactions to posts (like, love, pray, amen)
- ✅ **comments** - Comments on posts with nested replies support
- ✅ **comment_reactions** - Likes on comments
- ✅ **post_shares** - Track when users share posts

#### Features:
- ✅ **Row Level Security (RLS)** - Users can only access their own data
- ✅ **Automatic Timestamps** - Created/updated timestamps auto-managed
- ✅ **Automatic Profile Creation** - Profile created on user signup
- ✅ **Engagement Counters** - Likes, comments, shares counted automatically
- ✅ **Storage Buckets** - For avatars and post images
- ✅ **Full-Text Search** - Optimized search for posts and comments
- ✅ **Indexes** - For fast queries

## 📦 Step 5: Install Dependencies

Run the following command in your project directory:

```bash
flutter pub get
```

This will install:
- `supabase_flutter` - Supabase SDK
- `google_sign_in` - Google authentication
- `font_awesome_flutter` - Icons including Google icon

## 🔐 Step 6: Configure Authentication

### Email Authentication (Already Configured)

Email/password authentication is enabled by default in Supabase.

### Google Sign-In (Optional but Recommended)

1. In Supabase dashboard, go to **Authentication** → **Providers**
2. Find **Google** and click to configure
3. You'll need to:
   - Create a Google Cloud Project
   - Enable Google+ API
   - Create OAuth 2.0 credentials
   - Add authorized redirect URIs
4. Follow [Supabase's Google Auth Guide](https://supabase.com/docs/guides/auth/social-login/auth-google)

## 🎨 Step 7: Configure Storage

The migration automatically creates two storage buckets:

1. **avatars** - For user profile pictures
2. **post-images** - For images in community posts

Both buckets are configured with:
- Public read access
- Authenticated write access
- User-specific update/delete permissions

## ✅ Step 8: Verify Setup

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Try creating an account:
   - Go to the Sign Up screen
   - Enter name, email, and password
   - Click "Create Account"

3. Check Supabase:
   - Go to **Authentication** → **Users** - You should see your new user
   - Go to **Table Editor** → **profiles** - You should see a profile created

## 🧪 Testing the Database

### Test Bookmarks:
1. Sign in to your app
2. Navigate to a Bible chapter
3. Tap a verse and bookmark it
4. Check Supabase **Table Editor** → **bookmarks**

### Test Community Posts:
1. Navigate to the Community section (when implemented)
2. Create a post with a Bible verse
3. Check Supabase **Table Editor** → **community_posts**

## 🔒 Security Notes

### Row Level Security (RLS)

All tables have RLS enabled with policies that:
- Users can only read/write their own data (bookmarks, notes, etc.)
- Community posts are publicly readable but only editable by owners
- Reactions and comments follow similar patterns

### API Keys

- **anon key** - Safe to use in client apps (has RLS restrictions)
- **service_role key** - NEVER use in client apps (bypasses RLS)

## 📊 Database Schema Overview

```
auth.users (Supabase managed)
    ↓
profiles (auto-created on signup)
    ├── bookmarks
    ├── highlights
    ├── notes
    ├── search_history
    └── community_posts
            ├── post_reactions
            ├── comments
            │   └── comment_reactions
            └── post_shares
```

## 🐛 Troubleshooting

### "Supabase has not been initialized" Error
- Make sure you've updated `supabase_config.dart` with your credentials
- Verify the credentials are correct
- Check that `main.dart` calls `SupabaseService.initialize()`

### Authentication Errors
- Check Supabase dashboard → **Authentication** → **Configuration**
- Verify email confirmation is disabled for testing (or handle email confirmation)
- Check error messages in Supabase logs

### Database Errors
- Verify the migration ran successfully
- Check Supabase dashboard → **Database** → **Logs**
- Ensure RLS policies are correct

### Google Sign-In Issues
- Verify Google OAuth is configured in Supabase
- Check that redirect URIs are correct
- Ensure Google Sign-In is enabled in your Google Cloud project

## 📚 Next Steps

Now that Supabase is connected, you can:

1. ✅ Use email/password authentication
2. ✅ Use Google Sign-In
3. ✅ Store user bookmarks in the cloud
4. ✅ Sync highlights and notes across devices
5. ✅ Build the community feature with posts, reactions, and comments
6. ✅ Upload and display user avatars
7. ✅ Track search history

## 🔗 Useful Links

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)

## 💡 Tips

1. **Development**: Use Supabase's free tier for development
2. **Production**: Upgrade to Pro for better performance and support
3. **Backups**: Supabase Pro includes daily backups
4. **Monitoring**: Use Supabase dashboard to monitor API usage
5. **Logs**: Check logs regularly for errors and performance issues

---

**Need Help?** Check the Supabase Discord or documentation!
