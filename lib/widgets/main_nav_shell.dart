import 'dart:io' show Platform;
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

  const MainNavShell({
    super.key,
    required this.navigationShell,
  });

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
      if (roundedIndex != _lastHapticIndex && (page - roundedIndex).abs() < 0.15) {
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
    widget.navigationShell.goBranch(
      index,
      initialLocation: false,
    );
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
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F5), // Soft off-white / cream background
            borderRadius: BorderRadius.circular(999), // Fully rounded pill ends
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 8),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.5,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              const innerPadding = 6.0;
              final availableWidth = totalWidth - (innerPadding * 2);
              final tabWidth = availableWidth / _tabCount;

              // Constrained sliding pill width
              final activePillWidth = tabWidth * 0.88;
              final pillHorizontalOffset = innerPadding +
                  (_pageOffset * tabWidth) +
                  ((tabWidth - activePillWidth) / 2);

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Real-Time Sliding Active Pill Highlight
                  Positioned(
                    left: pillHorizontalOffset.clamp(
                      innerPadding,
                      totalWidth - innerPadding - activePillWidth,
                    ),
                    top: 8,
                    bottom: 8,
                    width: activePillWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // 4 Interactive Tab Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: innerPadding),
                    child: Row(
                      children: [
                        _buildTabItem(
                          index: 0,
                          label: 'Home',
                          tabWidth: tabWidth,
                          materialIcon: Icons.home_outlined,
                          materialActiveIcon: Icons.home_rounded,
                          cupertinoIcon: CupertinoIcons.house,
                          cupertinoActiveIcon: CupertinoIcons.house_fill,
                        ),
                        _buildTabItem(
                          index: 1,
                          label: 'Wallet',
                          tabWidth: tabWidth,
                          materialIcon: Icons.account_balance_wallet_outlined,
                          materialActiveIcon: Icons.account_balance_wallet_rounded,
                          cupertinoIcon: CupertinoIcons.creditcard,
                          cupertinoActiveIcon: CupertinoIcons.creditcard_fill,
                        ),
                        _buildTabItem(
                          index: 2,
                          label: 'Quiz',
                          tabWidth: tabWidth,
                          materialIcon: Icons.task_alt_rounded,
                          materialActiveIcon: Icons.verified_rounded,
                          cupertinoIcon: CupertinoIcons.checkmark_seal,
                          cupertinoActiveIcon: CupertinoIcons.checkmark_seal_fill,
                        ),
                        _buildTabItem(
                          index: 3,
                          label: 'Profile',
                          tabWidth: tabWidth,
                          materialIcon: Icons.person_outline_rounded,
                          materialActiveIcon: Icons.person_rounded,
                          cupertinoIcon: CupertinoIcons.person_crop_circle,
                          cupertinoActiveIcon: CupertinoIcons.person_crop_circle_fill,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required double tabWidth,
    required IconData materialIcon,
    required IconData materialActiveIcon,
    required IconData cupertinoIcon,
    required IconData cupertinoActiveIcon,
  }) {
    // Calculate continuous interpolation factor between 0.0 (inactive) and 1.0 (active)
    final distance = (index - _pageOffset).abs();
    final activeFactor = (1.0 - distance).clamp(0.0, 1.0);

    final activeColor = AppColors.primary;
    const inactiveColor = Color(0xFF475569); // Solid slate dark-grey

    // Smooth color cross-fade
    final currentColor = Color.lerp(inactiveColor, activeColor, activeFactor)!;

    final icon = _isIOS
        ? (activeFactor > 0.5 ? cupertinoActiveIcon : cupertinoIcon)
        : (activeFactor > 0.5 ? materialActiveIcon : materialIcon);

    final isBeingPressed = _pressedIndex == index;

    return SizedBox(
      width: tabWidth,
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedScale(
            scale: isBeingPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: currentColor,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
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
