import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/tasks/screens/tasks_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';

/// Floating Glass-Pill Bottom Navigation Shell with Native iOS Spring Motion & Real-Time Swipe Tracking
class MainNavShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavShell({super.key, required this.navigationShell});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late final PageController _pageController;
  double _pageOffset = 0.0;
  int _lastHapticIndex = 0;
  int? _pressedIndex;

  static const _tabCount = 4;
  static const _animationDuration = Duration(milliseconds: 320);
  static const _animationCurve = Curves.easeOutCubic;

  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.navigationShell.currentIndex;
    _lastHapticIndex = initialIndex;
    _pageOffset = initialIndex.toDouble();
    _pageController = PageController(initialPage: initialIndex);

    _pageController.addListener(_handlePageScroll);
  }

  void _handlePageScroll() {
    if (_pageController.hasClients && _pageController.page != null) {
      final page = _pageController.page!;
      setState(() {
        _pageOffset = page;
      });

      // Trigger light haptic tick when crossing integer tab threshold
      final roundedIndex = page.round().clamp(0, _tabCount - 1);
      if (roundedIndex != _lastHapticIndex &&
          (page - roundedIndex).abs() < 0.15) {
        _lastHapticIndex = roundedIndex;
        HapticFeedback.selectionClick();
      }
    }
  }

  @override
  void didUpdateWidget(covariant MainNavShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetIndex = widget.navigationShell.currentIndex;
    if (_pageController.hasClients &&
        _pageController.page?.round() != targetIndex) {
      _pageController.animateToPage(
        targetIndex,
        duration: _animationDuration,
        curve: _animationCurve,
      );
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    _lastHapticIndex = index;

    // Immediate tactile feedback
    setState(() {
      _pressedIndex = index;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() {
          _pressedIndex = null;
        });
      }
    });

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: _animationDuration,
        curve: _animationCurve,
      );
    }
  }

  void _onPageChanged(int index) {
    widget.navigationShell.goBranch(index, initialLocation: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Content gracefully flows behind floating pill
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // Native iOS overscroll bounce
        onPageChanged: _onPageChanged,
        children: const [
          HomeScreen(),
          WalletScreen(),
          TasksScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: ClipRect(
        // Instagram / native iOS tab bar: translucent blur, hairline top
        // edge, no floating box. Content scrolls underneath (extendBody).
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              border: Border(
                top: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.9),
                  width: 0.5,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              children: [
                _buildTabItem(
                  index: 0,
                  label: 'Home',
                  materialIcon: Icons.home_outlined,
                  materialActiveIcon: Icons.home_rounded,
                  cupertinoIcon: CupertinoIcons.house,
                  cupertinoActiveIcon: CupertinoIcons.house_fill,
                ),
                _buildTabItem(
                  index: 1,
                  label: 'Wallet',
                  materialIcon: Icons.account_balance_wallet_outlined,
                  materialActiveIcon: Icons.account_balance_wallet_rounded,
                  cupertinoIcon: CupertinoIcons.creditcard,
                  cupertinoActiveIcon: CupertinoIcons.creditcard_fill,
                ),
                _buildTabItem(
                  index: 2,
                  label: 'Quiz',
                  materialIcon: Icons.task_alt_rounded,
                  materialActiveIcon: Icons.verified_rounded,
                  cupertinoIcon: CupertinoIcons.checkmark_seal,
                  cupertinoActiveIcon: CupertinoIcons.checkmark_seal_fill,
                ),
                _buildTabItem(
                  index: 3,
                  label: 'Profile',
                  materialIcon: Icons.person_outline_rounded,
                  materialActiveIcon: Icons.person_rounded,
                  cupertinoIcon: CupertinoIcons.person_crop_circle,
                  cupertinoActiveIcon: CupertinoIcons.person_crop_circle_fill,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData materialIcon,
    required IconData materialActiveIcon,
    required IconData cupertinoIcon,
    required IconData cupertinoActiveIcon,
  }) {
    // Continuous interpolation between inactive and active during swipes
    final distance = (index - _pageOffset).abs();
    final activeFactor = (1.0 - distance).clamp(0.0, 1.0);

    const activeColor = AppColors.primary; // black
    const inactiveColor = Color(0xFFA1A1AA); // zinc-400

    final currentColor = Color.lerp(inactiveColor, activeColor, activeFactor)!;

    final icon = _isIOS
        ? (activeFactor > 0.5 ? cupertinoActiveIcon : cupertinoIcon)
        : (activeFactor > 0.5 ? materialActiveIcon : materialIcon);

    final isBeingPressed = _pressedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedScale(
            scale: isBeingPressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 26, color: currentColor),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: activeFactor > 0.5
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: currentColor,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
