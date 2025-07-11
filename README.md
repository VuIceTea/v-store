# V-Store - Flutter E-commerce App

A modern Flutter e-commerce application with Firebase backend.

## Features

- 🛍️ Product browsing and search
- 🛒 Shopping cart functionality
- 👤 User authentication and profiles
- 📱 Responsive design for mobile and web
- 💳 Multiple payment methods (VNPay, Bank transfer)
- 📦 Order tracking and history
- ⭐ Product reviews and ratings
- 🎯 Category-based product filtering

## Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

- Flutter SDK
- Firebase account
- Android Studio / VS Code

### Installation

1. Clone the repository
```bash
git clone https://github.com/VuIceTea/v-store.git
cd v-store
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Update Firebase configuration

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Business logic
├── widgets/        # Reusable widgets
├── utils/          # Utility functions
└── config/         # Configuration files
```

## Technologies Used

- Flutter & Dart
- Firebase (Firestore, Auth, Storage)
- Provider (State Management)
- VNPay Payment Gateway

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
