import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? leading;                 // custom leading (overrides back btn)
  final List<Widget>? actions;           // right side widgets
  final Color backgroundColor;
  final Color titleColor;
  final double height;
  final bool centerTitle;
  final bool showShadow;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.titleColor = Colors.white,
    this.height = 56,
    this.centerTitle = true,
    this.showShadow = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    // Shadow decoration if needed
    final BoxDecoration? deco = showShadow
        ? const BoxDecoration(
        boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black26)])
        : null;

    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: deco,
      child: Material(
        color: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Leading
                Align(
                  alignment: Alignment.centerLeft,
                  child: leading ??
                      IconButton(
                        onPressed: onBack ?? Get.back,
                        icon: const Icon(Icons.arrow_back_ios),
                        color: titleColor,
                        iconSize: 22,
                        splashRadius: 22,
                      ),
                ),

                // Title (perfectly centered regardless of leading/actions)
                if (centerTitle)
                  IgnorePointer(
                    ignoring: true, // taps pass through to buttons
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0), // space for back
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Actions (right)
                if (actions != null && actions!.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
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
