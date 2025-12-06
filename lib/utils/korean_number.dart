/// 한국어 숫자 변환 유틸리티
/// TTS에서 "일번", "이번", "삼번" 형태로 읽기 위한 변환
class KoreanNumber {
  /// 숫자를 한국어 순서수로 변환 (1 → "일", 2 → "이", 3 → "삼")
  static String toKorean(int number) {
    const koreanNumbers = [
      '', // 0 (사용하지 않음)
      '일', // 1
      '이', // 2
      '삼', // 3
      '사', // 4
      '오', // 5
      '육', // 6
      '칠', // 7
      '팔', // 8
      '구', // 9
      '십', // 10
      '십일', // 11
      '십이', // 12
      '십삼', // 13
      '십사', // 14
      '십오', // 15
      '십육', // 16
      '십칠', // 17
      '십팔', // 18
      '십구', // 19
      '이십', // 20
    ];

    if (number > 0 && number < koreanNumbers.length) {
      return koreanNumbers[number];
    }

    // 20 이상의 숫자 처리
    if (number >= 20 && number < 100) {
      final tens = number ~/ 10;
      final ones = number % 10;
      final tensStr = tens == 1 ? '십' : '${koreanNumbers[tens]}십';
      final onesStr = ones == 0 ? '' : koreanNumbers[ones];
      return '$tensStr$onesStr';
    }

    // 100 이상은 숫자 그대로 반환
    return number.toString();
  }

  /// 숫자를 "N번" 형태의 TTS 문자열로 변환 (1 → "일번", 2 → "이번")
  static String toOrdinal(int number) {
    return '${toKorean(number)}번';
  }

  /// 숫자를 "N번째" 형태의 TTS 문자열로 변환 (1 → "일번째", 2 → "이번째")
  static String toOrdinalPosition(int number) {
    return '${toKorean(number)}번째';
  }
}
