# SageBible Architecture Documentation

## Overview

SageBible is built with a clean, scalable architecture following Flutter best practices. The app uses **Riverpod** for state management, **GoRouter** for navigation, and follows a **feature-first** folder structure.

## Project Structure

```
lib/
├── core/                          # Core functionality shared across features
│   ├── constants/                 # App-wide constants
│   │   └── app_constants.dart     # Constants for keys, durations, spacing
│   ├── models/                    # Shared data models
│   │   └── user_model.dart        # User data model
│   ├── router/                    # Navigation configuration
│   │   └── app_router.dart        # GoRouter setup with auth guards
│   ├── services/                  # Core services
│   │   └── storage_service.dart   # Local storage wrapper (SharedPreferences)
│   └── theme/                     # App theming
│       └── app_theme.dart         # Theme configuration with calming palette
│
├── features/                      # Feature modules (feature-first architecture)
│   ├── auth/                      # Authentication feature
│   │   ├── providers/             # Riverpod providers for auth state
│   │   │   └── auth_provider.dart # Auth state management
│   │   ├── screens/               # Auth UI screens
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── services/              # Auth business logic
│   │   │   └── auth_service.dart  # Authentication operations
│   │   └── widgets/               # Reusable auth widgets
│   │       └── auth_text_field.dart
│   │
│   ├── splash/                    # Splash screen feature
│   │   └── screens/
│   │       └── splash_screen.dart # Animated splash with auth check
│   │
│   └── home/                      # Home feature
│       └── screens/
│           └── home_screen.dart   # Main home screen after login
│
└── main.dart                      # App entry point

assets/
├── images/                        # Image assets (logos, illustrations)
└── icons/                         # Icon assets
```

## Architecture Patterns

### 1. Feature-First Structure

Each feature is self-contained with its own:
- **Screens**: UI components
- **Providers**: State management
- **Services**: Business logic
- **Widgets**: Reusable UI components
- **Models**: Feature-specific data models (if needed)

### 2. State Management (Riverpod)

**Why Riverpod?**
- Type-safe and compile-time safe
- No BuildContext needed for providers
- Better testability
- Excellent DevTools support
- Modern and actively maintained

**Provider Types Used:**
- `Provider`: For immutable services (StorageService, AuthService)
- `StateNotifierProvider`: For mutable state (AuthNotifier)

**Example:**
```dart
// Define provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Use in widget
final authState = ref.watch(authProvider);

// Call methods
await ref.read(authProvider.notifier).login(email, password);
```

### 3. Navigation (GoRouter)

**Why GoRouter?**
- Official Flutter navigation solution
- Declarative routing
- Deep linking support
- Type-safe navigation
- Easy authentication guards

**Route Structure:**
- `/` - Splash screen (initial route)
- `/login` - Login screen
- `/register` - Register screen
- `/home` - Home screen (protected)

**Authentication Guards:**
The router automatically redirects based on auth state:
- Authenticated users → `/home`
- Unauthenticated users → `/login`
- Loading state → `/` (splash)

### 4. Dependency Injection

Riverpod handles dependency injection:
```dart
// Service providers
final storageServiceProvider = Provider<StorageService>((ref) {...});
final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthService(storage);
});
```

## Design System

### Color Palette

Calming, spiritual colors appropriate for a Bible app:

- **Primary**: `#5B7C99` - Soft blue-gray (trust, peace)
- **Secondary**: `#8B9D83` - Sage green (growth, nature)
- **Accent**: `#D4A574` - Warm gold (wisdom, divine)
- **Background**: `#FAF9F6` - Off-white (clean, spacious)
- **Surface**: `#FFFFFF` - Pure white
- **Error**: `#B85C5C` - Muted red

### Typography

- **Headings**: Merriweather (classic, readable, serif)
- **Body**: Lato (clean, modern, sans-serif)

### Spacing System

- Small: 8px
- Medium: 16px
- Large: 24px
- XLarge: 32px

### Border Radius

- Small: 8px
- Medium: 12px
- Large: 16px
- XLarge: 24px

## Data Flow

### Authentication Flow

1. **App Start** → Splash Screen
2. **Splash Screen** → Check auth status via `AuthNotifier.checkAuthStatus()`
3. **Auth Check** → Read from StorageService
4. **Navigation** → GoRouter redirects based on auth state
5. **Login/Register** → Update auth state via `AuthNotifier`
6. **State Change** → GoRouter automatically navigates

```
User Action → AuthNotifier → AuthService → StorageService
                    ↓
              AuthState Update
                    ↓
              GoRouter Redirect
                    ↓
              Navigate to Screen
```

## Services

### StorageService

Singleton wrapper around SharedPreferences for local data persistence.

**Methods:**
- `setString()`, `getString()`
- `setBool()`, `getBool()`
- `setInt()`, `getInt()`
- `remove()`, `clear()`

### AuthService

Handles authentication operations. Currently uses local storage for demo purposes.

**Production Integration:**
Replace the mock implementation with real API calls:
```dart
Future<UserModel> login(String email, String password) async {
  // Replace with actual API call
  final response = await http.post(
    Uri.parse('$apiUrl/auth/login'),
    body: {'email': email, 'password': password},
  );
  // Parse response and return UserModel
}
```

## State Management Details

### AuthState

```dart
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
}
```

### AuthNotifier Methods

- `checkAuthStatus()` - Check if user is logged in
- `login(email, password)` - Login user
- `register(name, email, password)` - Register new user
- `logout()` - Logout current user
- `clearError()` - Clear error message

## Best Practices Implemented

1. **Separation of Concerns**: UI, business logic, and data layers are separate
2. **Single Responsibility**: Each class has one clear purpose
3. **Dependency Injection**: Services are injected via Riverpod
4. **Immutable State**: State objects are immutable with `copyWith()`
5. **Error Handling**: Try-catch blocks with user-friendly error messages
6. **Type Safety**: Strong typing throughout the codebase
7. **Documentation**: Comprehensive comments explaining each component
8. **Consistent Naming**: Clear, descriptive names following Dart conventions

## Testing Strategy

### Unit Tests
- Test services (AuthService, StorageService)
- Test state management (AuthNotifier)
- Test models (UserModel)

### Widget Tests
- Test individual screens
- Test custom widgets
- Test form validation

### Integration Tests
- Test complete authentication flow
- Test navigation between screens

## Scalability Considerations

### Adding New Features

1. Create new feature folder under `features/`
2. Add screens, providers, services as needed
3. Register routes in `app_router.dart`
4. Update navigation logic if needed

### Adding API Integration

1. Create `api_service.dart` in `core/services/`
2. Add HTTP client (dio, http)
3. Update `AuthService` to use API calls
4. Add error handling and retry logic
5. Implement token refresh mechanism

### Adding Database

1. Add local database package (sqflite, hive, isar)
2. Create database service in `core/services/`
3. Create repository layer for data access
4. Update providers to use repositories

### Adding More State Management

For complex features, consider:
- `AsyncNotifierProvider` for async operations
- `FutureProvider` for one-time async data
- `StreamProvider` for real-time data

## Performance Optimizations

1. **Lazy Loading**: Providers are created only when needed
2. **Efficient Rebuilds**: Riverpod only rebuilds affected widgets
3. **Image Optimization**: Use cached_network_image for remote images
4. **List Optimization**: Use ListView.builder for long lists
5. **Code Splitting**: Feature-first structure enables code splitting

## Security Considerations

1. **Secure Storage**: For production, use flutter_secure_storage for tokens
2. **API Keys**: Store in environment variables, not in code
3. **Input Validation**: Validate all user inputs
4. **HTTPS Only**: Enforce HTTPS for all API calls
5. **Token Expiry**: Implement token refresh mechanism

## Next Steps

1. **Add Bible Content**: Integrate Bible API or local database
2. **Reading Plans**: Create reading plan feature
3. **Bookmarks & Notes**: Add user annotations
4. **Search**: Implement full-text search
5. **Offline Support**: Cache content for offline reading
6. **Push Notifications**: Daily verse notifications
7. **Social Features**: Share verses, community discussions
8. **Analytics**: Track user engagement
9. **Crash Reporting**: Integrate Sentry or Firebase Crashlytics
10. **A/B Testing**: Experiment with features
