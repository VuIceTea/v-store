import 'package:flutter/material.dart';
import 'package:v_store/widgets/app_bottom_navigation.dart';

class ProductBottomNavigation extends StatelessWidget {
  final int? currentTabIndex;

  const ProductBottomNavigation({super.key, this.currentTabIndex});

  @override
  Widget build(BuildContext context) {
    return AppBottomNavigation(
      showBackToMain: true,
      currentIndex: currentTabIndex ?? 0,
    );
  }
}
