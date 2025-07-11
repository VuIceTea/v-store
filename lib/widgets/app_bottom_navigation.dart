import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int? currentIndex;
  final Function(int)? onTap;
  final bool showBackToMain;

  const AppBottomNavigation({
    super.key,
    this.currentIndex,
    this.onTap,
    this.showBackToMain = true,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex ?? 0,
      selectedItemColor: const Color.fromRGBO(253, 110, 135, 1),
      unselectedItemColor: Colors.grey[600],
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Yêu thích',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
      ],
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else if (showBackToMain) {
          _defaultOnTap(context, index);
        }
      },
    );
  }

  void _defaultOnTap(BuildContext context, int index) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
      (route) => false,
      arguments: index,
    );
  }
}
