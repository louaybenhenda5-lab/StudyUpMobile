import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/teacher_radial_menu.dart';
import 'teacher_classes_screen.dart';
import 'schedule_page.dart';
import 'teacher_profile_page.dart';
import 'teacher_stats_screen.dart';

/// Post-login tab container for Schedule / Classes / Stats / Profile.
///
/// Schedule is the default/initial main page.
///
/// The shell owns the single shared [TeacherRadialMenu]; tab pages must not
/// include their own navigation.
class TeacherTabsScreen extends StatefulWidget {
  final int initialIndex;

  const TeacherTabsScreen({super.key, this.initialIndex = 0});

  @override
  State<TeacherTabsScreen> createState() => _TeacherTabsScreenState();
}

class _TeacherTabsScreenState extends State<TeacherTabsScreen> {
  late int _selectedIndex = widget.initialIndex.clamp(0, 3);
  final _menuKey = GlobalKey<TeacherRadialMenuState>();
  final _closeSignal = ValueNotifier<bool>(false);
  bool _menuOpen = false;

  void _onItemSelected(int index) {
    // Close the radial menu after selection, then switch tabs.
    _closeSignal.value = true;
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  void _onMenuOpenChanged(bool open) {
    if (mounted) setState(() => _menuOpen = open);
  }

  @override
  void dispose() {
    _closeSignal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return PopScope(
      canPop: !_menuOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _menuOpen) _closeSignal.value = true;
      },
      child: Scaffold(
        backgroundColor: colors.headerBackground,
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: [
                const SchedulePage(),
                const TeacherClassesScreen(),
                const TeacherStatsScreen(),
                const TeacherProfilePage(),
              ],
            ),
            // Blur + dim veil — visual only. Outside-taps are owned by the
            // radial menu layer above, so there is no gesture competition.
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _menuOpen ? 1.0 : 0.0,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: colors.textPrimary.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
            // Full-screen radial menu on top (FAB bottom-right inside it).
            TeacherRadialMenu(
              key: _menuKey,
              currentIndex: _selectedIndex,
              onSelect: _onItemSelected,
              closeSignal: _closeSignal,
              onOpenChanged: _onMenuOpenChanged,
            ),
          ],
        ),
      ),
    );
  }
}
