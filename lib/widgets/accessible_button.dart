import 'package:flutter/material.dart';
import '../theme/accessible_theme.dart';
import '../services/tts_service.dart';

/// 접근성을 고려한 큰 버튼 위젯
/// Accessible large button widget
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;
  final String? semanticLabel;
  final bool speakOnFocus;

  const AccessibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.semanticLabel,
    this.speakOnFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AccessibleTheme.buttonColor,
              foregroundColor: AccessibleTheme.buttonTextColor,
              minimumSize: const Size(
                double.infinity,
                AccessibleTheme.buttonHeight,
              ),
              padding: AccessibleTheme.buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AccessibleTheme.borderRadius,
                ),
              ),
            ),
            child: _buildButtonContent(AccessibleTheme.buttonTextColor),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AccessibleTheme.primaryColor,
              minimumSize: const Size(
                double.infinity,
                AccessibleTheme.buttonHeight,
              ),
              padding: AccessibleTheme.buttonPadding,
              side: const BorderSide(
                color: AccessibleTheme.primaryColor,
                width: AccessibleTheme.borderWidth,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AccessibleTheme.borderRadius,
                ),
              ),
            ),
            child: _buildButtonContent(AccessibleTheme.primaryColor),
          );

    return Semantics(
      button: true,
      label: semanticLabel ?? text,
      hint: '버튼을 두 번 탭하여 선택하세요',
      child: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus && speakOnFocus) {
            TtsService().speak(semanticLabel ?? text);
          }
        },
        child: button,
      ),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AccessibleTheme.iconSize, color: color),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              text,
              style: AccessibleTheme.buttonStyle.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AccessibleTheme.buttonStyle.copyWith(color: color),
      textAlign: TextAlign.center,
    );
  }
}
