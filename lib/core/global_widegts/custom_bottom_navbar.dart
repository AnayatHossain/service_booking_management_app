import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';

class NavItemData {
  final String? activeSvg;
  final String? inactiveSvg;
  final IconData? icon;
  final String label;
  final int badgeCount;

  const NavItemData({
    this.activeSvg,
    this.inactiveSvg,
    this.icon,
    required this.label,
    this.badgeCount = 0,
  });
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final List<NavItemData> items;
  final Color? activeColor;
  final Gradient? activeGradient;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
    this.activeColor,
    this.activeGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(
              items.length,
              (i) => _buildNavItem(context, i, items[i]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int count, bool isDark) {
    if (count <= 0) return const SizedBox.shrink();

    final String text = count > 99 ? '99+' : count.toString();
    final bool isWide = text.length > 1;

    return Container(
      constraints: BoxConstraints(
        minWidth: isWide ? (count > 99 ? 22 : 19) : 18,
        minHeight: 18,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 4.5 : 2,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.6),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: count > 99 ? 8.5 : (isWide ? 9.5 : 10),
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: count > 99 ? -0.5 : 0,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, NavItemData item) {
    final bool isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = activeColor ?? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8));
    final unselectedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);

    // Active icon is larger and colored in royal blue theme color
    final double iconSize = isSelected ? 26.0 : 22.0;

    Widget iconWidget;
    if (isSelected && item.activeSvg != null) {
      iconWidget = SvgPicture.asset(
        item.activeSvg!,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
      );
    } else if (!isSelected && item.inactiveSvg != null) {
      iconWidget = SvgPicture.asset(
        item.inactiveSvg!,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
      );
    } else if (item.icon != null) {
      iconWidget = Icon(
        item.icon,
        size: iconSize,
        color: isSelected ? selectedColor : unselectedColor,
      );
    } else {
      iconWidget = SizedBox(width: iconSize, height: iconSize);
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onItemTapped(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean icon with badge, no background pill
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 32,
                    child: Center(
                      child: AnimatedScale(
                        scale: isSelected ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: iconWidget,
                      ),
                    ),
                  ),
                  if (item.badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: _buildBadge(item.badgeCount, isDark),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              // Text label
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? selectedColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
