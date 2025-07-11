import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_store/services/auth_service.dart';
import 'package:v_store/screens/signin.dart';
import 'package:v_store/screens/user_profile.dart';
import 'package:v_store/widgets/slide_right_route.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
            ),
          ),
          child: Column(
            children: [
              StreamBuilder<User?>(
                stream: AuthService.authStateChanges,
                builder: (context, snapshot) {
                  final User? user = snapshot.data;
                  final bool isLoggedIn = user != null;

                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.transparent),
                    accountName: Text(
                      isLoggedIn ? (user.displayName ?? 'Người dùng') : 'Khách',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    accountEmail: Text(
                      isLoggedIn ? (user.email ?? '') : 'Chưa đăng nhập',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    currentAccountPicture: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: isLoggedIn && user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : AssetImage('assets/images/homeImgs/default_avt.png')
                                as ImageProvider,
                      child:
                          isLoggedIn &&
                              user.photoURL == null &&
                              (user.displayName?.isEmpty ?? true)
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.home,
                      title: 'Trang chủ',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/home');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.category,
                      title: 'Danh mục',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/wishlist');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.shopping_cart,
                      title: 'Giỏ hàng',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/cart');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.favorite,
                      title: 'Yêu thích',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/wishlist');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.person,
                      title: 'Hồ sơ',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          SlideRightRoute(
                            page: const UserProfileScreen(showBackButton: true),
                          ),
                        );
                      },
                    ),
                    Divider(color: Colors.grey[300]),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings,
                      title: 'Cài đặt',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.support,
                      title: 'Hỗ trợ',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/support');
                      },
                    ),
                    StreamBuilder<User?>(
                      stream: AuthService.authStateChanges,
                      builder: (context, snapshot) {
                        final bool isLoggedIn = snapshot.data != null;
                        return _buildDrawerItem(
                          context,
                          icon: isLoggedIn ? Icons.logout : Icons.login,
                          title: isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
                          onTap: () {
                            Navigator.pop(context);
                            if (isLoggedIn) {
                              AuthService.signOut();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã đăng xuất thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                SlideRightRoute(page: SignInScreen()),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'V-Store © 2025',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
    );
  }
}
