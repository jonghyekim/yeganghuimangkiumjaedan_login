import 'package:flutter/material.dart';
import '../models/flavor_model.dart';
import '../theme/accessible_theme.dart';
import '../services/tts_service.dart';

/// 아이스크림 맛 카드 위젯
/// 고대비, 큰 텍스트, 넓은 터치 영역 제공
class FlavorCard extends StatelessWidget {
  final FlavorModel flavor;
  final bool isSelected;
  final VoidCallback onTap;
  final bool speakOnTap;

  const FlavorCard({
    super.key,
    required this.flavor,
    required this.onTap,
    this.isSelected = false,
    this.speakOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${flavor.name}, ${flavor.description}',
      hint: '두 번 탭하여 선택하세요',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () {
          if (speakOnTap) {
            TtsService().speak(flavor.name);
          }
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AccessibleTheme.basePadding,
            vertical: AccessibleTheme.cardSpacing / 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AccessibleTheme.primaryColor.withValues(alpha: 0.1)
                : AccessibleTheme.cardColor,
            borderRadius: BorderRadius.circular(AccessibleTheme.borderRadius),
            border: Border.all(
              color: isSelected
                  ? AccessibleTheme.primaryColor
                  : AccessibleTheme.cardBorderColor,
              width: isSelected
                  ? AccessibleTheme.borderWidth * 2
                  : AccessibleTheme.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AccessibleTheme.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 (선택적)
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AccessibleTheme.borderRadius / 2,
                  ),
                  child: Image.network(
                    flavor.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    semanticLabel: '${flavor.name} 이미지',
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: AccessibleTheme.cardColor,
                        child: const Center(
                          child: Icon(
                            Icons.icecream,
                            size: AccessibleTheme.iconSize * 2,
                            color: AccessibleTheme.primaryColor,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        color: AccessibleTheme.cardColor,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AccessibleTheme.cardSpacing),

                // 이름
                Text(
                  flavor.name,
                  style: AccessibleTheme.titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // 설명
                Text(
                  flavor.description,
                  style: AccessibleTheme.bodyStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // 선택됨 표시
                if (isSelected) ...[
                  const SizedBox(height: AccessibleTheme.cardSpacing),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AccessibleTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AccessibleTheme.buttonTextColor,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '선택됨',
                          style: TextStyle(
                            color: AccessibleTheme.buttonTextColor,
                            fontSize: AccessibleTheme.labelFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
