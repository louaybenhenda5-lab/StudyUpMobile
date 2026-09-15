import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  final List<NavItemData> _items = const [
    NavItemData(
      label: 'Home',
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
    ),
    NavItemData(
      label: 'Schedule',
      activeIcon: Icons.calendar_today_rounded,
      inactiveIcon: Icons.calendar_today_outlined,
    ),
    NavItemData(
      label: 'Classes',
      activeIcon: Icons.menu_book_rounded,
      inactiveIcon: Icons.menu_book_outlined,
    ),
    NavItemData(
      label: 'Stats',
      activeIcon: Icons.bar_chart_rounded,
      inactiveIcon: Icons.bar_chart_outlined,
    ),
    NavItemData(
      label: 'Profile',
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0066FF);
    final colors = Theme.of(context).extension<AppColors>()!;
    final inactiveColor = colors.subtitleText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      height: 80,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            // Animated Top Blue Indicator Line
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment(
                -1.0 + (widget.currentIndex * (2.0 / (_items.length - 1))),
                -1.0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / _items.length,
                child: Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Navigation Items
            Row(
              children: List.generate(_items.length, (index) {
                final isSelected = widget.currentIndex == index;
                final item = _items[index];

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 6),
                          // Glowing effect under the selected icon
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isSelected)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.35),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              Icon(
                                isSelected ? item.activeIcon : item.inactiveIcon,
                                color: isSelected ? primaryColor : inactiveColor,
                                size: 26,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? primaryColor : inactiveColor,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItemData {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const NavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}
