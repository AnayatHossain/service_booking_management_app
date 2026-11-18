# Service Booking & Management Mobile Application (Flutter)

A cross-platform Flutter mobile application designed for discovering, booking, and managing home, wellness, and technical services with AI-assisted recommendations. Features a dual-role interface for **Customers (Normal Users)** and **Service Providers**.

---

## 📱 Key Features

### 1. Dual-Role Support
- **Customer (Normal User)**:
  - Explore service catalog with categories and featured carousel.
  - Search and filter services by price, rating, and category.
  - Book appointments with real-time slot availability and conflict prevention.
  - View booking history across `All`, `Pending`, `Confirmed`, `Completed`, and `Cancelled` tabs.
  - Submit, view, **edit**, and **delete** ratings & reviews for completed services.
  - Chat with the Gemini-powered AI ServiceBot.
  - Live notification bell with counter (`99+` badge support).
- **Service Provider**:
  - Analytics Dashboard: Services count, Bookings count, Pending count, Done count, and recent appointments.
  - Quick appointment lifecycle actions: `Confirm`, `Decline`, `Mark Completed`.
  - My Services management: Add, Edit, Delete services with instant image and title sync.
  - **HOT / Featured Service** switch to promote services on the customer Home Screen carousel.
  - Provider Search & Filter bar matching customer experience.

### 2. Architecture & State Management
- **State Management**: **BLoC Pattern** (`flutter_bloc`, `BlocBuilder`, `BlocProvider`) for scalable and reactive UI state handling.
- **Routing & Snackbars**: `get` for declarative route navigation and non-blocking notifications.
- **HTTP Client**: Built with **`flutter_api_craft`** (v0.0.7) ensuring standard, reusable API calls with explicit UTF-8 encoding.
- **Shimmer & Refresh**: `skeletonizer` for shimmer loading placeholders and `pull_to_refresh` (`SmartRefresher`) for pull-to-refresh interactions.
- **Session Persistence**: Secure persistent token and role storage with `shared_preferences`.

---

## 📁 Directory Structure

```
lib/
├── app.dart                                    # MaterialApp configuration & Blue Material 3 theme
├── main.dart                                   # Flutter app entry point
├── core/
│   ├── const/
│   │   ├── app_colors.dart                     # Blue color palette & gradients
│   │   └── app_svg_icons.dart                  # Vector SVG asset paths
│   ├── network_caller/
│   │   └── endpoints.dart                      # Base URL & API endpoints
│   ├── services/
│   │   └── shared_preferences_helper.dart      # Session and role persistence
│   └── global_widegts/
│       ├── app_button.dart                     # Reusable primary button
│       ├── custom_text_field.dart              # Form input field with icons & eye toggle
│       └── empty_screen_widget.dart            # Empty state placeholder
└── feature/
    ├── splash/                                 # Animated splash & session routing
    ├── auth/                                   # Login (with Remember Me) & Sign Up
    ├── users/
    │   ├── normal_user/
    │   │   ├── home_screen/                    # Carousel, category chips, search & filter
    │   │   ├── service_details/                # Full service overview & booking CTA
    │   │   ├── appointment_booking/            # 14-day timeline & conflict-free slot picker
    │   │   ├── my_bookings/                    # Tabbed bookings with ratings & reviews
    │   │   ├── ai_assistant/                   # Gemini AI ServiceBot with tappable cards
    │   │   ├── notifications/                  # Notifications history & badge counts
    │   │   └── profile/                        # Customer profile & password change
    │   └── service_provider/
    │       ├── dashboard/                      # Provider KPI metrics & recent actions
    │       ├── my_services/                    # Provider service CRUD, search, and HOT toggle
    │       ├── bookings/                       # Provider booking requests management
    │       └── profile/                        # Provider company profile
    └── navigation/                             # Role-aware bottom navigation bar
```

---

## 🚀 Installation & Setup

### 1. Prerequisites
- **Flutter SDK**: 3.13.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: 3.0 or higher
- **Android Studio** / **VS Code** with Flutter and Dart extensions
- Android device or emulator running Android 8.0+ (API 26+)

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Backend Configuration
The app automatically detects the host environment in `lib/core/network_caller/endpoints.dart`:
```dart
// Automatically selects 10.0.2.2 for Android emulator and 127.0.0.1 for desktop/web
static String get baseUrl {
  if (kIsWeb) return 'http://127.0.0.1:8000/api';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
  } catch (_) {}
  return 'http://127.0.0.1:8000/api';
}
```

#### Running on Android Emulator:
No changes needed. It automatically communicates with the host machine at `http://10.0.2.2:8000/api`.

#### Running on Physical Android Device via USB:
Execute the ADB reverse command in your terminal so requests to `localhost:8000` route through your computer:
```bash
adb reverse tcp:8000 tcp:8000
```
Then set `baseUrl` to `http://127.0.0.1:8000/api`.

#### Running on Physical Device via Wi-Fi:
Set `baseUrl` in `endpoints.dart` to your computer's local network IP:
```dart
return 'http://192.168.1.15:8000/api';
```

---

## 🏃 Execution Instructions

### 1. Start Connected Device / Emulator
Verify your device is detected:
```bash
flutter devices
```

### 2. Run the App in Debug Mode
```bash
flutter run
```

### 3. Build Release Android APK
```bash
flutter build apk --release
```
The resulting APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🔑 Demo Login Credentials

| Role | Email | Password |
|------|-------|----------|
| **Normal User (Customer)** | `testuser@example.com` | `password123` |
| **Service Provider** | `provider@example.com` | `password123` |
