import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:v_store/screens/forgot_password.dart';
import 'package:v_store/screens/get_started.dart';
import 'package:v_store/screens/product_detail.dart';
import 'package:v_store/screens/signin.dart';
import 'package:v_store/screens/onboarding_screen.dart';
import 'package:v_store/screens/signup.dart';
import 'package:v_store/screens/main_screen.dart';
import 'package:v_store/screens/user_profile.dart';
import 'package:v_store/screens/cart.dart' as cart_page;
import 'package:v_store/screens/checkout.dart';
import 'package:v_store/screens/search.dart' as search_page;
import 'package:v_store/screens/payment_method_screen.dart';
import 'package:v_store/screens/order_history_screen.dart';
import 'package:v_store/screens/order_detail_screen.dart';
import 'package:v_store/screens/order_tracking_screen.dart';
import 'package:v_store/screens/return_refund_screen.dart';
import 'package:v_store/screens/otp_verification_screen.dart';
import 'package:v_store/services/cart_service.dart';
import 'package:v_store/providers/category_notifier.dart';
import 'package:v_store/models/product.dart';
import 'package:v_store/models/cart_item.dart';
import 'package:v_store/widgets/auth_wrapper.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartService()..initializeCart(),
        ),
        ChangeNotifierProvider(create: (context) => CategoryNotifier()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'V-Store',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
        home: SplashScreen(nextScreen: const AuthWrapper()),
        routes: {
          '/get-started': (context) => const GetStarted(),
          '/main': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as int?;
            return MainScreen(initialTab: args);
          },
          '/home': (context) => const MainScreen(initialTab: 0),
          '/onboarding': (context) => const OnboardingScreen(),
          '/sign-up': (context) => const SignUpScreen(),
          '/sign-in': (context) => const SignInScreen(),
          '/signin': (context) => const SignInScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/wishlist': (context) => const MainScreen(initialTab: 1),
          '/search': (context) => const search_page.SearchScreen(),
          '/user-profile': (context) =>
              const UserProfileScreen(showBackButton: true),
          '/cart': (context) => const cart_page.CartPageScreen(),
          '/order-history': (context) => const OrderHistoryScreen(),
          '/order-tracking': (context) => const OrderTrackingScreen(),
          '/return-refund': (context) => const ReturnRefundScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-details') {
            final args = settings.arguments;
            if (args is Product) {
              return MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: args),
              );
            } else if (args is Map<String, dynamic>) {
              final product = args['product'] as Product?;
              final currentTabIndex = args['currentTabIndex'] as int?;
              if (product != null) {
                return MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: product,
                    currentTabIndex: currentTabIndex,
                  ),
                );
              }
            }
          } else if (settings.name == '/checkout') {
            final directPurchaseItems = settings.arguments as List<CartItem>?;
            return MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                directPurchaseItems: directPurchaseItems,
                isFromCart: false,
              ),
            );
          } else if (settings.name == '/payment-method') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => PaymentMethodScreen(
                  totalAmount: args['totalAmount'] ?? 0.0,
                  orderId: args['orderId'] ?? '',
                  onPaymentSuccess: args['onPaymentSuccess'],
                ),
              );
            }
          } else if (settings.name == '/order-detail') {
            final orderId = settings.arguments as String?;
            if (orderId != null) {
              return MaterialPageRoute(
                builder: (context) => OrderDetailScreen(orderId: orderId),
              );
            }
          } else if (settings.name == '/otp-verification') {
            final email = settings.arguments as String?;
            if (email != null) {
              return MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(email: email),
              );
            }
          }
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const MainScreen(initialTab: 0),
          );
        },
      ),
    );
  }
}
