import 'package:flutter/material.dart';

/// 시각 장애인을 위한 접근성 테마 (배스킨라빈스 소프트 핑크 스타일)
/// Accessibility theme for visually impaired users (Baskin Robbins Soft Pink Style)
/// 부드럽고 현대적인 BR 컬러 팔레트 적용
class AccessibleTheme {
  // ============================================
  // 색상 (배스킨라빈스 소프트 핑크 테마 - 고대비 유지)
  // Colors (Baskin Robbins Soft Pink Theme - High Contrast)
  // ============================================

  /// 기본 배경색 (밝은 크림)
  static const Color backgroundColor = Color(0xFFFFF8F3); // Light Cream

  /// 기본 텍스트 색상 (진한 회색 - 가독성)
  static const Color textColor = Color(0xFF4A4A4A); // Dark Text

  /// 주요 강조 색상 (소프트 악센트 핑크)
  static const Color primaryColor = Color(0xFFF48FB1); // Accent Pink

  /// 보조 강조 색상 (BR 네이비)
  static const Color secondaryColor = Color(0xFF2E3192); // BR Navy Accent

  /// 성공 색상 (민트 그린 - BR 스타일)
  static const Color successColor = Color(0xFF00897B); // Teal

  /// 경고 색상 (진한 빨강)
  static const Color errorColor = Color(0xFFD32F2F); // Red

  /// 카드 배경색 (흰색)
  static const Color cardColor = Color(0xFFFFFFFF); // White

  /// 카드 테두리 색상 (소프트 핑크)
  static const Color cardBorderColor = Color(0xFFF8CDE0); // Soft Pink

  /// 버튼 배경색 (악센트 핑크)
  static const Color buttonColor = Color(0xFFF48FB1); // Accent Pink

  /// 버튼 텍스트 색상
  static const Color buttonTextColor = Color(0xFFFFFFFF); // White

  /// 악센트 색상 (BR 네이비)
  static const Color accentColor = Color(0xFF2E3192); // BR Navy

  /// 헤더 배경색 (소프트 핑크)
  static const Color headerColor = Color(0xFFF48FB1); // Accent Pink

  /// 선택된 항목 배경색 (연한 소프트 핑크)
  static const Color selectedColor = Color(0xFFFCE4EC); // Pink 50

  /// 비활성화 색상
  static const Color disabledColor = Color(0xFFBDBDBD); // Grey 400

  // ============================================
  // 글꼴 크기 (매우 크게)
  // Font Sizes (Very Large)
  // ============================================

  /// 제목 글꼴 크기
  static const double titleFontSize = 32.0;

  /// 부제목 글꼴 크기
  static const double subtitleFontSize = 28.0;

  /// 본문 글꼴 크기
  static const double bodyFontSize = 24.0;

  /// 버튼 글꼴 크기
  static const double buttonFontSize = 28.0;

  /// 라벨 글꼴 크기
  static const double labelFontSize = 22.0;

  // ============================================
  // 간격 (넉넉하게)
  // Spacing (Generous)
  // ============================================

  /// 기본 패딩
  static const double basePadding = 24.0;

  /// 카드 패딩
  static const double cardPadding = 32.0;

  /// 버튼 패딩
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 24.0,
  );

  /// 카드 간격
  static const double cardSpacing = 20.0;

  // ============================================
  // 크기 (터치하기 쉽게)
  // Sizes (Easy to Touch)
  // ============================================

  /// 최소 터치 영역 (iOS/Android 권장: 44-48px)
  static const double minTouchTarget = 64.0;

  /// 버튼 높이
  static const double buttonHeight = 80.0;

  /// 카드 최소 높이
  static const double cardMinHeight = 180.0;

  /// 아이콘 크기
  static const double iconSize = 48.0;

  /// 테두리 두께
  static const double borderWidth = 3.0;

  /// 테두리 반경
  static const double borderRadius = 16.0;

  // ============================================
  // 텍스트 스타일
  // Text Styles
  // ============================================

  static const TextStyle titleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
    color: textColor,
    height: 1.3,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: subtitleFontSize,
    fontWeight: FontWeight.w600,
    color: textColor,
    height: 1.4,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: bodyFontSize,
    fontWeight: FontWeight.normal,
    color: textColor,
    height: 1.5,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: buttonFontSize,
    fontWeight: FontWeight.bold,
    color: buttonTextColor,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: labelFontSize,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  // ============================================
  // 테마 데이터
  // Theme Data
  // ============================================

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: buttonTextColor,
        secondary: secondaryColor,
        onSecondary: buttonTextColor,
        error: errorColor,
        onError: buttonTextColor,
        surface: backgroundColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: buttonTextColor,
        titleTextStyle: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: buttonTextColor,
        ),
        iconTheme: IconThemeData(
          size: iconSize,
          color: buttonTextColor,
        ),
        toolbarHeight: 80,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          minimumSize: const Size(double.infinity, buttonHeight),
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: buttonStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, buttonHeight),
          padding: buttonPadding,
          side: const BorderSide(color: primaryColor, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: buttonStyle.copyWith(color: primaryColor),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: cardBorderColor, width: borderWidth),
        ),
        margin: const EdgeInsets.all(cardSpacing / 2),
      ),
      textTheme: const TextTheme(
        displayLarge: titleStyle,
        displayMedium: subtitleStyle,
        bodyLarge: bodyStyle,
        labelLarge: buttonStyle,
      ),
      fontFamilyFallback: const ['Noto Sans KR', 'Malgun Gothic'],
      // 추가 핑크 테마 설정
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: buttonTextColor,
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
      ),
    );
  }
}
