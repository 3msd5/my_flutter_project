import 'package:flutter/material.dart';
import 'package:filmdeneme/theme/app_theme.dart';

class CustomToggleButtons extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final Function(int) onSelected;
  final IconData? leftIcon;
  final IconData? rightIcon;

  const CustomToggleButtons({
    Key? key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.leftIcon,
    this.rightIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          options.length,
          (index) => GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? AppTheme.accentColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index == 0 && leftIcon != null) ...[
                    Icon(
                      leftIcon,
                      size: 18,
                      color: selectedIndex == index
                          ? Colors.white
                          : AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (index == 1 && rightIcon != null) ...[
                    Icon(
                      rightIcon,
                      size: 18,
                      color: selectedIndex == index
                          ? Colors.white
                          : AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    options[index],
                    style: TextStyle(
                      color: selectedIndex == index
                          ? Colors.white
                          : AppTheme.secondaryTextColor,
                      fontWeight: selectedIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
