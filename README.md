# Service Booking & Management Mobile Application (Flutter)

A cross-platform Flutter mobile application designed for discovering, booking, and managing home, wellness, and technical services with AI-assisted recommendations.

---

## 📱 Features

### 1. Authentication
- User registration (name, email, password, phone) with validation.
- Secure login and session persistence (`SharedPreferencesHelper`).
- Quick demo credential prefill for evaluator convenience (`testuser@example.com` / `password123`).
- Logout with confirmation dialog.

### 2. Home & Discovery
- Interactive service exploration with categorized chips (`All`, `Home Cleaning`, `Spa & Wellness`, `Appliance Repair`, etc.).
- Real-time search bar with instant query filtering.
- Featured & Popular services carousel banner with rating badges.
- Dynamic service listing with price, duration, and rating stats.

### 3. Service Details
- Complete service information, description, and pricing breakdown.
- Estimated duration and certification badges.
- Available days of the week and standard time slots.
- Sticky "Book Appointment" CTA.

### 4. Appointment Booking
- 14-day interactive timeline date picker.
- Real-time slot availability check via backend API (`/api/appointments/availability`).
- Intelligent conflict prevention: previously booked time slots are visually struck through and disabled.
- Optional customer notes/instructions field.
- Interactive booking confirmation modal dialog with instant redirection to "My Bookings".

### 5. My Bookings Management
- Tabbed view: `All`, `Upcoming`, `Completed`, `Cancelled`.
- Color-coded status badges:
  - 🟢 **Confirmed**: Green
  - 🟡 **Pending**: Amber
  - 🔵 **Completed**: Blue
  - 🔴 **Cancelled**: Red
- Full booking details: date, time slot, service category, price, and customer notes.
- "Cancel Booking" action with confirmation dialog.

### 6. AI Service Assistant (Google Gemini Powered)
- Interactive conversational AI assistant (**ServiceBot**).
- Answers questions about available services, pricing, and scheduling policies.
- Delivers tailored service recommendations rendered as directly tappable service cards.
- Quick prompt chips for fast 1-tap inquiries.
- Secure backend proxy: **Zero API key exposure** inside the mobile app.

### 7. User Profile
- View personal customer profile details and avatar.
- Edit profile information (name and phone number) with instant cloud sync.
- Change password dialog with confirmation validation.
- Help & Support and Terms & Privacy references.

---

## 🏗️ Architecture & Best Practices

- **State Management**: **GetX** reactive state management (`Rx`, `Obx`, `GetxController`).
- **HTTP Client**: Built with **`flutter_api_craft`** (v0.0.6) for consistent, reusable API interactions across screens.
- **Controller Separation**: Each screen/feature owns its isolated controller (e.g. `LogInController`, `HomeController`, `AppointmentBookingController`, `MyBookingsController`, `AiAssistantController`, `ProfileController`), preventing giant centralized God-classes.
- **Modular Widgets**: Screens are broken down into small, single-responsibility widgets located in feature-specific `widgets/` folders.
- **Design System**: Blue Material 3 design system with custom `AppColors`, typography, elevation, and responsive cards.

---

## 📁 Project Directory Structure

```
lib/
├── app.dart                                # MaterialApp configuration & Blue theme
├── main.dart                               # Flutter app entry point
├── core/
│   ├── const/
│   │   └── app_colors.dart                 # Blue color palette & gradients
│   ├── network_caller/
│   │   └── endpoints.dart                  # Base URL & API endpoints
│   ├── services/
│   │   └── shared_preferences_helper.dart  # Session persistence
│   └── global_widegts/
│       ├── app_button.dart                 # Reusable primary button
│       ├── custom_text_field.dart          # Form input field with icons & eye toggle
│       └── empty_screen_widget.dart        # Empty state placeholder
└── feature/
    ├── splash/
    │   └── splash_screen.dart              # Animated splash & auto session redirect
    ├── auth/
    │   ├── login/
    │   │   ├── controller/login_controller.dart
    │   │   ├── screen/login_screen.dart
    │   │   └── widgets/auth_header.dart
    │   └── signup/
    │       ├── controller/signup_controller.dart
    │       └── screen/signup_screen.dart
    ├── navigation/
    │   ├── controller/bottom_navbar_controller.dart
    │   └── screen/main_navigation_screen.dart
    ├── home_screen/
    │   ├── controllers/home_controller.dart
    │   ├── model/service_model.dart
    │   ├── screens/home_screen.dart
    │   └── widgets/
    │       ├── category_selector.dart
    │       ├── featured_banner.dart
    │       ├── search_filter_bar.dart
    │       └── service_card.dart
    ├── service_details/
    │   ├── controllers/service_details_controller.dart
    │   ├── screens/service_details_screen.dart
    │   └── widgets/
    │       ├── book_bottom_bar.dart
    │       └── service_info_header.dart
    ├── appointment/
    │   ├── controllers/appointment_booking_controller.dart
    │   ├── screens/appointment_booking_screen.dart
    │   └── widgets/
    │       ├── date_picker_timeline.dart
    │       └── time_slot_selector.dart
    ├── my_bookings/
    │   ├── controllers/my_bookings_controller.dart
    │   ├── model/booking_model.dart
    │   ├── screens/my_bookings_screen.dart
    │   └── widgets/
    │       ├── booking_card.dart
    │       ├── booking_filter_tabs.dart
    │       └── booking_status_chip.dart
    ├── profile/
    │   ├── controllers/profile_controller.dart
    │   ├── screens/
    │   │   ├── profile_screen.dart
    │   │   └── edit_profile_screen.dart
    │   └── widgets/
    │       ├── change_password_dialog.dart
    │       ├── profile_header.dart
    │       └── profile_menu_item.dart
    └── ai_assistant/
        ├── controllers/ai_assistant_controller.dart
        ├── model/ai_message_model.dart
        ├── screens/ai_assistant_screen.dart
        └── widgets/
            ├── ai_chat_bubble.dart
            └── ai_service_card.dart
```

---

## 🚀 Running the Application

### 1. Prerequisites
- Flutter SDK (3.13.0+)
- Android Studio / VS Code with Flutter extension
- Android device or emulator running Android 8.0+

### 2. Configure Backend URL
In `lib/core/network_caller/endpoints.dart`:
- Android Emulator automatically points to `http://10.0.2.2:8000/api`
- Physical Android device over WiFi: update to your computer's local IP (e.g. `http://192.168.1.15:8000/api`)

### 3. Run the App
```bash
flutter pub get
flutter run
```

### 4. Build Android APK
```bash
flutter build apk --release
```
The resulting APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`
