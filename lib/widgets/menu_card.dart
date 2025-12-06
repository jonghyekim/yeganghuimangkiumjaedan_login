import 'package:flutter/material.dart';
import '../models/flavor_model.dart';
import '../theme/accessible_theme.dart';
import '../utils/korean_number.dart';

/// 메뉴 카드 위젯 (메뉴 선택 화면용)
/// 고대비, 큰 텍스트, 넓은 터치 영역 제공
/// 이름만 표시, 설명은 상세 화면에서 표시
/// TTS: 한자어 수사 사용 (일번, 이번, 삼번...)
class MenuCard extends StatelessWidget {
  final FlavorModel flavor;
  final int itemNumber;
  final bool isSelected;
  final VoidCallback onTap;
  final double? maxHeight;

  const MenuCard({
    super.key,
    required this.flavor,
    required this.itemNumber,
    required this.onTap,
    this.isSelected = false,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    // TTS용 한자어 수사 (일번, 이번, 삼번...)
    final koreanOrdinal = KoreanNumber.toOrdinal(itemNumber);

    return Semantics(
      label: '$koreanOrdinal, ${flavor.name}',
      hint: '두 번 탭하여 선택하세요',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? double.infinity,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              AccessibleTheme.borderRadius - AccessibleTheme.borderWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 순번 배지 (화면에는 숫자로 표시)
                _buildNumberBadge(),

                // 이미지 영역 (Flexible로 overflow 방지)
                Flexible(
                  flex: 3,
                  child: _buildImage(),
                ),

                // 이름 영역
                _buildNameSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected
          ? AccessibleTheme.primaryColor
          : AccessibleTheme.secondaryColor,
      child: Text(
        '$itemNumber번', // 화면에는 숫자로 표시 (1번, 2번, 3번...)
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Image.network(
          flavor.imageUrl,
          fit: BoxFit.contain,
          semanticLabel: '${flavor.name} 이미지',
          errorBuilder: (context, error, stackTrace) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: const Icon(
                Icons.icecream,
                size: 80,
                color: AccessibleTheme.primaryColor,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 3,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isSelected
            ? AccessibleTheme.primaryColor.withValues(alpha: 0.15)
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: AccessibleTheme.cardBorderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Text(
        flavor.name,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isSelected
              ? AccessibleTheme.primaryColor
              : AccessibleTheme.textColor,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
