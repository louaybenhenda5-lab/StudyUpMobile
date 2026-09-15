import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Floating circular radial menu replacing the bottom navigation bar.
///
/// Full-screen layer: the main trigger sits bottom-right (with SafeArea)
/// and four icon nodes fan out on a circular arc upward-left. Nodes are
/// spaced so they never overlap; each has a distinct icon + color, a
/// Tooltip, and semantics. The shell keeps the selected index as the
/// source of truth.
///
/// When closed, the main button shows the icon of the currently displayed
/// page; when open it shows a close icon.
class TeacherRadialMenu extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final ValueNotifier<bool>? closeSignal;
  final ValueChanged<bool>? onOpenChanged;

  const TeacherRadialMenu({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    this.closeSignal,
    this.onOpenChanged,
  });

  @override
  State<TeacherRadialMenu> createState() => TeacherRadialMenuState();
}

class TeacherRadialMenuState extends State<TeacherRadialMenu>
    with SingleTickerProviderStateMixin {
  static const _items = [
    _RadialNavItem(
        label: 'Schedule',
        icon: Icons.calendar_today_rounded,
        color: Color(0xFF6C5DD3)),
    _RadialNavItem(
        label: 'Classes',
        icon: Icons.menu_book_rounded,
        color: Color(0xFF5BC0BE)),
    _RadialNavItem(
        label: 'Stats',
        icon: Icons.bar_chart_rounded,
        color: Color(0xFFE17055)),
    _RadialNavItem(
        label: 'Profile',
        icon: Icons.person_rounded,
        color: Color(0xFF6C5CE7)),
  ];

  static const double _fabSize = 56;
  static const double _nodeSize = 50;
  static const double _margin = 16;

  /// Fixed fan radius kept tight so nodes sit closer to the main button
  /// while the leftmost node stays on-screen down to 320px widths.
  static const double _radius = 105;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _open = false;

  bool get isOpen => _open;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    widget.closeSignal?.addListener(_handleCloseSignal);
  }

  @override
  void didUpdateWidget(TeacherRadialMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.closeSignal != widget.closeSignal) {
      oldWidget.closeSignal?.removeListener(_handleCloseSignal);
      widget.closeSignal?.addListener(_handleCloseSignal);
    }
  }

  @override
  void dispose() {
    widget.closeSignal?.removeListener(_handleCloseSignal);
    _controller.dispose();
    super.dispose();
  }

  void _handleCloseSignal() {
    if (widget.closeSignal?.value == true && _open) {
      close();
      widget.closeSignal?.value = false;
    }
  }

  void open() {
    if (_open || _controller.isAnimating) return;
    setState(() => _open = true);
    _controller.forward();
    widget.onOpenChanged?.call(true);
  }

  void close() {
    if (!_open || _controller.isAnimating) return;
    _controller.reverse().then((_) {
      if (!mounted) return;
      setState(() => _open = false);
      widget.onOpenChanged?.call(false);
    });
  }

  void toggle() {
    if (_open) {
      close();
    } else {
      open();
    }
  }

  /// Fan angles in degrees (screen coords, y grows downward): 175° spreads
  /// near-left slightly down, 275° near-up slightly right — the whole arc
  /// stays on-screen above the bottom-right FAB.
  double _angleFor(int index, int count) {
    if (count <= 1) return 225 * math.pi / 180;
    return (175 + (100 * index / (count - 1))) * math.pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = _margin + MediaQuery.viewPaddingOf(context).bottom;
    final activeItem = _items[widget.currentIndex.clamp(0, _items.length - 1)];

    return SizedBox.expand(
      child: Stack(
        children: [
          // Outside-tap catcher + fan nodes. The catcher sits below the
          // nodes so node taps never compete with it in the gesture arena.
          IgnorePointer(
            ignoring: !_open,
            child: AnimatedBuilder(
              animation: _fade,
              builder: (context, _) {
                if (_fade.value == 0 && !_open) {
                  return const SizedBox.expand();
                }
                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: close,
                        behavior: HitTestBehavior.opaque,
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    for (var i = 0; i < _items.length; i++)
                      _buildNode(context, colors, bottomInset, i),
                  ],
                );
              },
            ),
          ),
          // Main trigger FAB, bottom-right for one-handed use.
          Positioned(
            right: _margin,
            bottom: bottomInset,
            child: FloatingActionButton(
              heroTag: 'teacher_radial_main',
              onPressed: toggle,
              tooltip: _open ? 'Close menu' : 'Open menu',
              elevation: 6,
              backgroundColor: Colors.transparent,
              child: Container(
                width: _fabSize,
                height: _fabSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: colors.buttonGradient),
                ),
                child: AnimatedRotation(
                  turns: _open ? 0.125 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    ),
                    child: Icon(
                      _open ? Icons.close_rounded : activeItem.icon,
                      key: ValueKey(
                          _open ? 'close' : 'nav-${activeItem.label}'),
                      color: Colors.white,
                      size: 28,
                      semanticLabel: _open
                          ? 'Close navigation menu'
                          : 'Open navigation menu, currently on ${activeItem.label}',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(
      BuildContext context, AppColors colors, double bottomInset, int index) {
    final item = _items[index];
    final isActive = widget.currentIndex == index;
    final angle = _angleFor(index, _items.length);
    // Offset from FAB center; nodes stay up-left of the trigger.
    final offset = Offset(
        math.cos(angle) * _radius, math.sin(angle) * _radius);

    // Anchor the node circle's center on (FAB center + offset).
    const centerDelta = (_fabSize - _nodeSize) / 2;
    final right = _margin + centerDelta - offset.dx;
    final bottom = bottomInset + centerDelta - offset.dy;

    final interval = Interval(0.06 * index, 1.0, curve: Curves.easeOutCubic);
    final curved = CurvedAnimation(parent: _controller, curve: interval);

    return Positioned(
      right: right,
      bottom: bottom,
      child: Opacity(
        opacity: _fade.value,
        child: Transform.scale(
          scale: 0.4 + 0.6 * curved.value,
          child: Semantics(
            button: true,
            label: 'Go to ${item.label}',
            selected: isActive,
            child: GestureDetector(
              onTap: () {
                if (_controller.isAnimating) return;
                widget.onSelect(index);
              },
              behavior: HitTestBehavior.opaque,
              child: Tooltip(
                message: item.label,
                child: Container(
                  width: _nodeSize,
                  height: _nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? item.color.withValues(alpha: 0.2)
                        : colors.cardBackground,
                    border: Border.all(
                      color: isActive ? item.color : colors.inputBorder,
                      width: isActive ? 2.5 : 1,
                    ),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialNavItem {
  final String label;
  final IconData icon;
  final Color color;

  const _RadialNavItem(
      {required this.label, required this.icon, required this.color});
}
