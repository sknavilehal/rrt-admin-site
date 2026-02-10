# RRT Admin Site - Code Organization

## Architecture Overview

This Flutter application follows a **layered architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                      Presentation Layer                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Screens    │  │   Widgets    │  │    Main      │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                     Business Logic Layer                │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │ AuthService  │  │  ApiService  │                    │
│  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                        Data Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │    Models    │  │   Firebase   │  │   HTTP API   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Directory Structure

### 📁 `config/`
**Purpose**: Application-wide configuration and constants

- `constants.dart`: Centralized constants (API URLs, districts, app info, roles)

**Usage**: Import when you need app-level configuration
```dart
import 'package:rrt_admin_site/config/constants.dart';
```

---

### 📁 `models/`
**Purpose**: Data models and entity classes

- `user_profile.dart`: Authenticated user profile model
- `admin.dart`: Admin user model

**Key Features**:
- JSON serialization (fromJson/toJson)
- Type-safe data structures
- Business logic properties (e.g., `isSuperAdmin`)

**Usage**: Import when working with user or admin data
```dart
import 'package:rrt_admin_site/models/user_profile.dart';
import 'package:rrt_admin_site/models/admin.dart';
```

---

### 📁 `services/`
**Purpose**: Business logic and external service integration

#### `auth_service.dart`
- Firebase Authentication wrapper
- Sign in/sign out operations
- Token management
- Auth state stream

#### `api_service.dart`
- HTTP API calls to backend
- User profile operations
- Admin CRUD operations
- Centralized error handling

**Key Benefits**:
- Testable (can be mocked)
- Reusable across screens
- Single source of truth for API logic

**Usage**: Inject services into screens
```dart
final authService = AuthService();
final apiService = ApiService(authService);
```

---

### 📁 `screens/`
**Purpose**: Full-page UI components organized by feature

#### `auth/`
- `login_screen.dart`: Login form and authentication UI

#### `main/`
- `main_screen.dart`: App shell with header, navigation, and content area

#### `monitor/`
- `sos_monitor_screen.dart`: SOS alerts dashboard with filtering

#### `admin/`
- `manage_admins_screen.dart`: Admin management interface (Super Admin only)

**Organization Pattern**: Feature-based folders for easy navigation

---

### 📁 `widgets/`
**Purpose**: Reusable UI components

- `auth_wrapper.dart`: Determines which screen to show based on auth state
- `sos_alerts_table.dart`: Table displaying SOS alerts with real-time updates

**Key Characteristics**:
- Stateless or Stateful widgets
- Reusable across multiple screens
- Self-contained functionality

---

### 📄 `main.dart`
**Purpose**: Application entry point

**Responsibilities**:
- Initialize Firebase
- Configure app theme
- Create service instances
- Set up root widget

---

## Data Flow

### Authentication Flow
```
User Input → LoginScreen → AuthService → Firebase Auth
                                ↓
                         Auth State Change
                                ↓
                          AuthWrapper
                                ↓
                    ┌──────────┴──────────┐
                    ▼                     ▼
            LoginScreen            MainScreen
```

### API Data Flow
```
Screen → ApiService → HTTP Request → Backend API
                          ↓
                    HTTP Response
                          ↓
                   JSON Parsing
                          ↓
                  Model (fromJson)
                          ↓
                    Screen Update
```

### Real-time Data Flow (Firestore)
```
SOSMonitorScreen → Firestore Query → Stream
                                       ↓
                              StreamBuilder
                                       ↓
                            SOSAlertsTable
                                       ↓
                                 UI Update
```

---

## Best Practices

### 1. **Imports**
- Use relative imports within the lib folder
- Group imports: Flutter → External packages → Internal

### 2. **State Management**
- StatefulWidget for screen-level state
- StreamBuilder for real-time Firestore data
- Future builders for async operations

### 3. **Error Handling**
- Try-catch blocks in service methods
- User-friendly error messages via SnackBar
- Mounted checks before showing dialogs/snackbars

### 4. **Code Style**
- Extract complex widgets into private methods
- Use meaningful variable names
- Add comments for complex logic
- Keep files under 500 lines

### 5. **Testing Strategy**
- **Unit Tests**: Services and models
- **Widget Tests**: Individual widgets and screens
- **Integration Tests**: Full user flows

---

## Adding New Features

### Step 1: Create Model (if needed)
```dart
// lib/models/new_feature.dart
class NewFeature {
  final String id;
  // ... properties
  
  factory NewFeature.fromJson(Map<String, dynamic> json) {
    // ... implementation
  }
}
```

### Step 2: Add Service Methods (if needed)
```dart
// lib/services/api_service.dart
Future<NewFeature> getNewFeature() async {
  final headers = await _getHeaders();
  final response = await http.get(
    Uri.parse('${AppConstants.apiBaseUrl}/new-feature'),
    headers: headers,
  );
  // ... handle response
}
```

### Step 3: Create Screen
```dart
// lib/screens/feature/new_feature_screen.dart
class NewFeatureScreen extends StatefulWidget {
  final ApiService apiService;
  
  const NewFeatureScreen({required this.apiService});
  
  @override
  State<NewFeatureScreen> createState() => _NewFeatureScreenState();
}
```

### Step 4: Add Navigation
```dart
// lib/screens/main/main_screen.dart
// Add new tab/button and update navigation logic
```

---

## Common Patterns

### Pattern 1: Service Injection
```dart
class MyScreen extends StatefulWidget {
  final AuthService authService;
  final ApiService apiService;
  
  const MyScreen({
    required this.authService,
    required this.apiService,
  });
}
```

### Pattern 2: Async Data Loading
```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    final data = await apiService.getData();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    // Show error
  }
}
```

### Pattern 3: StreamBuilder for Firestore
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('collection')
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasError) return ErrorWidget();
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingWidget();
    }
    return DataWidget(snapshot.data);
  },
)
```

---

## Performance Tips

1. **Use const constructors** where possible
2. **Extract widgets** instead of rebuilding large widget trees
3. **Implement proper keys** for list items
4. **Use StreamBuilder** for real-time data
5. **Dispose controllers** in dispose() method
6. **Use cached network images** for images
7. **Implement pagination** for large lists

---

## Troubleshooting

### Issue: "Cannot find module"
**Solution**: Check import paths are correct and use relative imports

### Issue: "BuildContext across async gaps"
**Solution**: Store ScaffoldMessenger/Navigator before async call
```dart
final messenger = ScaffoldMessenger.of(context);
await someAsyncOperation();
messenger.showSnackBar(...);
```

### Issue: "Mounted check not working"
**Solution**: Always check `mounted` before calling setState after async
```dart
if (mounted) {
  setState(() {
    // update state
  });
}
```

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
