# SageBible Quick Start Guide

## 🎯 What You Have

A production-ready Flutter app scaffold with:

✅ **Authentication Flow** (Login/Register/Logout)  
✅ **Splash Screen** with animations  
✅ **State Management** (Riverpod)  
✅ **Navigation** (GoRouter with auth guards)  
✅ **Beautiful Theme** (Calming colors for Bible app)  
✅ **Clean Architecture** (Feature-first structure)  

## 🚀 Run the App

```bash
# Install dependencies (already done)
flutter pub get

# Run on your device/emulator
flutter run
```

## 📱 Test the App

1. **Splash Screen** → Shows animated logo for 2 seconds
2. **Login Screen** → Enter any email (with @) and password (6+ chars)
3. **Home Screen** → See welcome message and placeholder content
4. **Logout** → Click logout icon in app bar

**Note**: Authentication is mocked - any valid email/password works!

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/app_constants.dart      # App-wide constants
│   ├── models/user_model.dart            # User data model
│   ├── router/app_router.dart            # Navigation setup
│   ├── services/storage_service.dart     # Local storage
│   └── theme/app_theme.dart              # Theme & colors
│
├── features/
│   ├── auth/
│   │   ├── providers/auth_provider.dart  # Auth state management
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── services/auth_service.dart    # Auth logic
│   │   └── widgets/auth_text_field.dart
│   │
│   ├── splash/
│   │   └── screens/splash_screen.dart    # Animated splash
│   │
│   └── home/
│       └── screens/home_screen.dart      # Main home screen
│
└── main.dart                              # App entry point
```

## 🎨 Customize Theme

Edit `lib/core/theme/app_theme.dart`:

```dart
// Change colors
static const Color primaryColor = Color(0xFF5B7C99);    // Your color
static const Color secondaryColor = Color(0xFF8B9D83);  // Your color
static const Color accentColor = Color(0xFFD4A574);     // Your color
```

## 🔄 How State Management Works

### Reading State
```dart
// In any widget
final authState = ref.watch(authProvider);
final user = authState.user;
final isLoading = authState.isLoading;
```

### Updating State
```dart
// Call methods
await ref.read(authProvider.notifier).login(email, password);
await ref.read(authProvider.notifier).logout();
```

## 🧭 How Navigation Works

GoRouter automatically handles navigation based on auth state:

- **Not logged in** → `/login`
- **Logged in** → `/home`
- **Loading** → `/` (splash)

### Manual Navigation
```dart
// Go to route
context.go('/home');

// Push route
context.push('/register');

// Pop route
context.pop();
```

## ➕ Add New Features

### 1. Create Feature Folder

```
lib/features/bible/
├── providers/
├── screens/
├── services/
└── widgets/
```

### 2. Create Screen

```dart
// lib/features/bible/screens/bible_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BibleScreen extends ConsumerWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible')),
      body: Center(child: Text('Bible Content')),
    );
  }
}
```

### 3. Add Route

In `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/bible',
  name: 'bible',
  builder: (context, state) => const BibleScreen(),
),
```

### 4. Navigate to It

```dart
context.push('/bible');
```

## 🔌 Connect to Real Backend

### Update AuthService

Edit `lib/features/auth/services/auth_service.dart`:

```dart
Future<UserModel> login(String email, String password) async {
  // Replace mock with real API call
  final response = await http.post(
    Uri.parse('https://your-api.com/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final user = UserModel.fromJson(data['user']);
    
    // Save token
    await _storageService.setString('auth_token', data['token']);
    
    // Save user data
    await _storageService.setBool(AppConstants.keyIsLoggedIn, true);
    await _storageService.setString(AppConstants.keyUserId, user.id);
    // ... etc
    
    return user;
  } else {
    throw Exception('Login failed');
  }
}
```

## 📦 Add New Dependencies

1. Add to `pubspec.yaml`:
```yaml
dependencies:
  your_package: ^1.0.0
```

2. Install:
```bash
flutter pub get
```

3. Import and use:
```dart
import 'package:your_package/your_package.dart';
```

## 🎯 Common Tasks

### Change App Name
- Edit `pubspec.yaml` → `name: your_app_name`
- Edit `android/app/src/main/AndroidManifest.xml` → `android:label`
- Edit `ios/Runner/Info.plist` → `CFBundleName`

### Add App Icon
```bash
# Add flutter_launcher_icons to dev_dependencies
flutter pub get
flutter pub run flutter_launcher_icons
```

### Add Splash Screen
```bash
# Add flutter_native_splash to dev_dependencies
flutter pub get
flutter pub run flutter_native_splash:create
```

### Format Code
```bash
flutter format .
```

### Analyze Code
```bash
flutter analyze
```

## 🐛 Common Issues

### Hot Reload Not Working
```bash
flutter clean
flutter pub get
flutter run
```

### Build Errors
```bash
# Android
cd android && ./gradlew clean && cd ..

# iOS
cd ios && pod deintegrate && pod install && cd ..

# Then
flutter clean && flutter pub get
```

### Google Fonts Not Loading
- Check internet connection
- Or use local fonts (see SETUP.md)

## 📚 Learn More

- **Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md)
- **Setup**: See [SETUP.md](SETUP.md)
- **Flutter Docs**: https://docs.flutter.dev
- **Riverpod Docs**: https://riverpod.dev
- **GoRouter Docs**: https://pub.dev/packages/go_router

## 🎓 Key Concepts

### Riverpod Providers
- `Provider` - Immutable data
- `StateProvider` - Simple mutable state
- `StateNotifierProvider` - Complex mutable state (we use this)
- `FutureProvider` - Async data
- `StreamProvider` - Stream data

### Widget Types
- `StatelessWidget` - No state
- `StatefulWidget` - Local state
- `ConsumerWidget` - Riverpod state (we use this)
- `ConsumerStatefulWidget` - Both local and Riverpod state

### Navigation
- `context.go()` - Replace current route
- `context.push()` - Push new route
- `context.pop()` - Go back
- `context.replace()` - Replace with new route

## 🚀 Next Steps

1. **Run the app** and test the flow
2. **Customize the theme** to match your brand
3. **Add your logo** to assets
4. **Connect to your backend** API
5. **Add Bible content** (API or local database)
6. **Implement reading features**
7. **Add bookmarks and notes**
8. **Set up push notifications**
9. **Deploy to stores**

## 💡 Pro Tips

1. **Use Hot Reload** (r) for quick UI changes
2. **Use Hot Restart** (R) when changing state logic
3. **Check DevTools** for debugging (flutter pub global activate devtools)
4. **Use const constructors** for better performance
5. **Follow the existing patterns** for consistency
6. **Write tests** as you build features
7. **Keep features isolated** for better maintainability

## 🎉 You're Ready!

You now have a solid foundation for building SageBible. The architecture is scalable, the code is clean, and the UI is beautiful. Start building your features!

**Happy Coding! 🚀**
