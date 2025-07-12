<div align="center">
  <h1>🛍️ V-Store - Modern E-commerce Platform</h1>
  <p><em>A comprehensive Flutter-based e-commerce solution with real-time backend integration</em></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
</div>

## 📋 Overview

**V-Store** là một ứng dụng thương mại điện tử toàn diện được phát triển bằng Flutter, mang đến trải nghiệm mua sắm hiện đại và mượt mà cho người dùng. Ứng dụng tích hợp đầy đủ các tính năng cần thiết cho một nền tảng e-commerce chuyên nghiệp, từ quản lý sản phẩm đến xử lý thanh toán.

### 🎯 Mục tiêu dự án
- Tạo ra một nền tảng mua sắm trực tuyến hiện đại và dễ sử dụng
- Đảm bảo hiệu suất cao và trải nghiệm người dùng mượt mà
- Tích hợp các phương thức thanh toán phổ biến tại Việt Nam
- Cung cấp hệ thống quản lý đơn hàng và theo dõi chi tiết
- Hỗ trợ đa nền tảng (iOS, Android, Web)

## ✨ Tính năng chính

### 🛒 **Quản lý Sản phẩm**
- 📦 Duyệt sản phẩm theo danh mục với giao diện trực quan
- 🔍 Tìm kiếm thông minh với bộ lọc nâng cao
- 📊 Sắp xếp theo giá, đánh giá, độ phổ biến
- ⭐ Hệ thống đánh giá và nhận xét chi tiết
- 📱 Hiển thị responsive trên mọi thiết bị

### 👤 **Quản lý Người dùng**
- 🔐 Xác thực đa lớp (Email, OTP, Social Login)
- 👥 Quản lý hồ sơ cá nhân hoàn chỉnh
- � Quản lý địa chỉ giao hàng multiple
- ❤️ Danh sách yêu thích và wishlist
- 🔔 Thông báo và cập nhật realtime

### 🛍️ **Trải nghiệm Mua sắm**
- 🛒 Giỏ hàng thông minh với tính năng lưu trữ
- 💳 Tích hợp đa phương thức thanh toán (VNPay, Banking)
- 📦 Theo dõi đơn hàng realtime
- 📋 Lịch sử mua hàng chi tiết
- 🚚 Tính toán phí ship tự động

### 🎨 **Giao diện & UX**
- 🌓 Dark/Light mode support
- 🎯 Material Design 3.0
- 📱 Responsive design cho mọi screen size
- ⚡ Smooth animations và transitions
- � Hỗ trợ đa ngôn ngữ (VI/EN)

## 🛠️ Công nghệ & Kiến trúc

### **Frontend Framework**
- **Flutter 3.24+** - Cross-platform UI toolkit cho hiệu suất native
- **Dart 3.5+** - Ngôn ngữ lập trình hiện đại, type-safe
- **Material Design 3** - Design system của Google

### **Backend & Database**
- **Firebase Firestore** - NoSQL realtime database
- **Firebase Authentication** - Quản lý xác thực người dùng
- **Firebase Storage** - Lưu trữ hình ảnh và files
- **Firebase Cloud Functions** - Serverless backend logic
- **Firebase Analytics** - Theo dõi và phân tích người dùng

### **State Management & Architecture**
- **Provider Pattern** - Quản lý state hiệu quả
- **Repository Pattern** - Tách biệt business logic
- **Service Layer** - Xử lý API calls và data operations
- **MVVM Architecture** - Model-View-ViewModel pattern

### **Payment Integration**
- **VNPay Gateway** - Cổng thanh toán phổ biến tại VN
- **Bank Transfer** - Chuyển khoản ngân hàng
- **E-wallet Integration** - Tích hợp ví điện tử

### **Development Tools**
- **VS Code / Android Studio** - IDE development
- **Git Version Control** - Quản lý source code
- **Firebase CLI** - Command line tools
- **FlutterFire** - Official Flutter plugins for Firebase

### **Testing & Quality**
- **Unit Testing** - Kiểm thử đơn vị
- **Widget Testing** - Kiểm thử giao diện
- **Integration Testing** - Kiểm thử tích hợp
- **Code Analysis** - Lint rules và best practices

## 📱 Giao diện Ứng dụng

### 🔐 Xác thực & Onboarding
<div align="center">
  <img src="assets/screenshots/on_boarding1.png" width="200" alt="Onboarding 1"/>
  <img src="assets/screenshots/on_boarding2.png" width="200" alt="Onboarding 2"/>
  <img src="assets/screenshots/on_boarding3.png" width="200" alt="Onboarding 3"/>
  <img src="assets/screenshots/get_started.png" width="200" alt="Get Started"/>
</div>

<div align="center">
  <img src="assets/screenshots/sign_in.png" width="200" alt="Đăng nhập"/>
  <img src="assets/screenshots/sign_up.png" width="200" alt="Đăng ký"/>
  <img src="assets/screenshots/create_account.png" width="200" alt="Tạo tài khoản"/>
  <img src="assets/screenshots/forgot_password.png" width="200" alt="Quên mật khẩu"/>
</div>

<div align="center">
  <img src="assets/screenshots/authent_otp.png" width="200" alt="Xác thực OTP"/>
</div>

### 🏠 Trang chủ & Điều hướng
<div align="center">
  <img src="assets/screenshots/homw.png" width="200" alt="Trang chủ"/>
  <img src="assets/screenshots/home2.png" width="200" alt="Trang chủ 2"/>
  <img src="assets/screenshots/home3.png" width="200" alt="Trang chủ 3"/>
  <img src="assets/screenshots/drawer.png" width="200" alt="Menu điều hướng"/>
</div>

### 🛍️ Duyệt sản phẩm & Tìm kiếm
<div align="center">
  <img src="assets/screenshots/search.png" width="200" alt="Tìm kiếm"/>
  <img src="assets/screenshots/pro_fill.png" width="200" alt="Bộ lọc sản phẩm"/>
  <img src="assets/screenshots/pro_sort.png" width="200" alt="Sắp xếp sản phẩm"/>
  <img src="assets/screenshots/pro2.png" width="200" alt="Danh sách sản phẩm"/>
</div>

### 📦 Chi tiết sản phẩm
<div align="center">
  <img src="assets/screenshots/prode.png" width="200" alt="Chi tiết sản phẩm"/>
  <img src="assets/screenshots/prode3.png" width="200" alt="Chi tiết sản phẩm 3"/>
</div>

### 🛒 Giỏ hàng & Thanh toán
<div align="center">
  <img src="assets/screenshots/cart.png" width="200" alt="Giỏ hàng"/>
  <img src="assets/screenshots/cart3.png" width="200" alt="Xem giỏ hàng"/>
  <img src="assets/screenshots/checkout.png" width="200" alt="Thanh toán"/>
</div>

### 👤 Hồ sơ & Cài đặt
<div align="center">
  <img src="assets/screenshots/user_profile.png" width="200" alt="Hồ sơ người dùng"/>
  <img src="assets/screenshots/address.png" width="200" alt="Quản lý địa chỉ"/>
  <img src="assets/screenshots/favo.png" width="200" alt="Yêu thích"/>
</div>

### 📋 Quản lý đơn hàng
<div align="center">
  <img src="assets/screenshots/order_his.png" width="200" alt="Lịch sử đơn hàng"/>
  <img src="assets/screenshots/order_detail.png" width="200" alt="Chi tiết đơn hàng"/>
</div>

## 🚀 Bắt đầu

### 📋 Yêu cầu hệ thống

- **Flutter SDK** `>=3.24.0`
- **Dart SDK** `>=3.5.0`
- **Android Studio** hoặc **VS Code** với Flutter extension
- **Xcode** (cho iOS development)
- **Firebase Account** cho backend services
- **Git** cho version control

### 🛠️ Cài đặt & Chạy dự án

#### 1️⃣ Clone repository
```bash
git clone https://github.com/VuIceTea/v-store.git
cd v-store
```

#### 2️⃣ Cài đặt dependencies
```bash
# Cài đặt Flutter packages
flutter pub get

# Tạo generated files (nếu cần)
flutter packages pub run build_runner build
```

#### 3️⃣ Cấu hình Firebase
```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Đăng nhập Firebase
firebase login

# Cấu hình FlutterFire
dart pub global activate flutterfire_cli
flutterfire configure
```

**Thêm file cấu hình:**
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)
- Cập nhật Firebase Security Rules trong Firestore

#### 4️⃣ Cấu hình thanh toán (VNPay)
```dart
// Tạo file lib/config/vnpay_config.dart
class VNPayConfig {
  static const String merchantId = 'YOUR_MERCHANT_ID';
  static const String secretKey = 'YOUR_SECRET_KEY';
  // ... other configs
}
```

#### 5️⃣ Chạy ứng dụng
```bash
# Debug mode
flutter run

# Release mode  
flutter run --release

# Chạy trên web
flutter run -d chrome

# Build APK
flutter build apk --release
```

### 🔧 Environment Setup

#### Development
```bash
flutter run --flavor dev --dart-define=ENV=development
```

#### Production  
```bash
flutter run --flavor prod --dart-define=ENV=production
```

## 📁 Cấu trúc dự án

```
v_store/
├── lib/
│   ├── 📱 screens/              # Các màn hình UI
│   │   ├── auth/               # Xác thực (Login, Register, OTP)
│   │   ├── home/               # Trang chủ và dashboard
│   │   ├── product/            # Sản phẩm (List, Detail, Search)
│   │   ├── cart/               # Giỏ hàng và checkout
│   │   ├── profile/            # Hồ sơ người dùng
│   │   └── order/              # Quản lý đơn hàng
│   │
│   ├── 🏗️ models/              # Data models
│   │   ├── user.dart           # User model
│   │   ├── product.dart        # Product model  
│   │   ├── cart.dart           # Cart model
│   │   └── order.dart          # Order model
│   │
│   ├── 🔧 services/            # Business logic services
│   │   ├── auth_service.dart   # Authentication service
│   │   ├── product_service.dart # Product management
│   │   ├── cart_service.dart   # Cart operations
│   │   ├── payment_service.dart # Payment processing
│   │   └── firebase_service.dart # Firebase integration
│   │
│   ├── 🎨 widgets/             # Reusable UI components
│   │   ├── common/             # Common widgets
│   │   ├── product/            # Product-specific widgets
│   │   └── forms/              # Form components
│   │
│   ├── 🛠️ utils/              # Utility functions
│   │   ├── constants.dart      # App constants
│   │   ├── helpers.dart        # Helper functions
│   │   ├── validators.dart     # Form validators
│   │   └── extensions.dart     # Dart extensions
│   │
│   ├── ⚙️ config/             # Configuration files
│   │   ├── app_config.dart     # App configuration
│   │   ├── theme.dart          # App theme
│   │   └── routes.dart         # Route definitions
│   │
│   └── 📡 providers/          # State management
│       ├── auth_provider.dart  # Authentication state
│       ├── cart_provider.dart  # Cart state
│       └── theme_provider.dart # Theme state
│
├── assets/
│   ├── images/                 # App images
│   ├── icons/                  # Custom icons
│   ├── fonts/                  # Custom fonts
│   └── screenshots/            # UI screenshots
│
├── test/                       # Unit & Widget tests
├── integration_test/           # Integration tests
├── android/                    # Android configuration
├── ios/                        # iOS configuration
└── web/                        # Web configuration
```

## 🤝 Đóng góp

Chúng tôi hoan nghênh mọi đóng góp để cải thiện V-Store! 

### 📝 Quy trình đóng góp

1. **Fork** repository này
2. **Clone** fork về máy local
3. Tạo **branch** mới cho feature: `git checkout -b feature/amazing-feature`
4. **Commit** changes: `git commit -m 'Add amazing feature'`
5. **Push** lên branch: `git push origin feature/amazing-feature`
6. Tạo **Pull Request**

### 🐛 Báo cáo lỗi

Nếu phát hiện lỗi, vui lòng tạo **Issue** với thông tin:
- Mô tả chi tiết lỗi
- Các bước để tái hiện
- Screenshots/videos nếu có
- Thông tin môi trường (OS, Flutter version, etc.)

### 💡 Đề xuất tính năng

Có ý tưởng mới? Tạo **Feature Request** với:
- Mô tả tính năng
- Lý do cần thiết
- Mockups/wireframes nếu có

## 📄 License

Dự án này được phân phối dưới **MIT License**. Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 👨‍💻 Tác giả

**Nguyễn Phi Vũ** - *Fullstack Developer*
- 🐙 GitHub: [@VuIceTea](https://github.com/VuIceTea)
- 📧 Email: vuicetea@gmail.com
- 💼 LinkedIn: [Nguyễn Phi Vũ](https://linkedin.com/in/vuicetea)

## 🙏 Cảm ơn

- [Flutter Team](https://flutter.dev) - Amazing cross-platform framework
- [Firebase](https://firebase.google.com) - Comprehensive backend solution
- [Material Design](https://material.io) - Beautiful design system
- [VNPay](https://vnpay.vn) - Payment gateway integration
- [Unsplash](https://unsplash.com) - Beautiful stock photos

---

<div align="center">
  <p><strong>⭐ Nếu dự án hữu ích, hãy cho chúng tôi một star! ⭐</strong></p>
  <p><em>Được phát triển với ❤️ bằng Flutter</em></p>
</div>


