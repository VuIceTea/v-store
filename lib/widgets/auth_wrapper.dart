import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_store/screens/get_started.dart';
import 'package:v_store/screens/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Đang kiểm tra đăng nhập...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('Auth error: ${snapshot.error}');
          return const GetStarted();
        }

        if (snapshot.hasData && snapshot.data != null) {
          print('User đã đăng nhập: ${snapshot.data!.email}');
          return const MainScreen();
        }

        print('User chưa đăng nhập, chuyển đến GetStarted');
        return const GetStarted();
      },
    );
  }
}
