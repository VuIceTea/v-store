import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_store/screens/home.dart';
import 'package:v_store/screens/wishlist.dart';
import 'package:v_store/screens/search.dart' as search_page;
import 'package:v_store/screens/user_profile.dart';
import 'package:v_store/widgets/app_bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  final int? initialTab;

  const MainScreen({super.key, this.initialTab});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      _selectedIndex = widget.initialTab!;
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const WishlistProduct(),
    const search_page.SearchScreen(),
    const UserProfileScreen(showBackButton: false),
  ];

  void _onItemTapped(int index) {
    if (index == 3 && FirebaseAuth.instance.currentUser == null) {
      Navigator.pushNamed(context, '/sign-in');
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showBackToMain: false,
      ),
    );
  }
}
