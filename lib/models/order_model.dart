import 'flavor_model.dart';

/// 사이즈 옵션 열거형
/// Size option enumeration with prices
enum SizeOption {
  singleRegular('싱글레귤러', 'Single Regular', 1, 3900, false),
  singleKing('싱글킹', 'Single King', 1, 4700, false),
  doubleJunior('더블주니어', 'Double Junior', 2, 5100, false),
  tripleJunior('트리플주니어', 'Triple Junior', 3, 7200, false),
  doubleRegular('더블레귤러', 'Double Regular', 2, 7300, false),
  pint('파인트', 'Pint', 0, 9800, true),
  quart('쿼터', 'Quart', 0, 18500, true),
  family('패밀리', 'Family', 0, 26000, true),
  halfGallon('하프갤론', 'Half Gallon', 0, 31500, true);

  final String koreanName;
  final String englishName;
  final int scoop;
  final int price;
  final bool isContainer; // true for pint and above (container images)

  const SizeOption(this.koreanName, this.englishName, this.scoop, this.price, this.isContainer);

  String get displayName => koreanName;

  /// 가격을 포맷팅된 문자열로 반환 (예: "3,900원")
  String get formattedPrice {
    final priceStr = price.toString();
    if (price >= 10000) {
      return '${priceStr.substring(0, priceStr.length - 3)},${priceStr.substring(priceStr.length - 3)}원';
    } else if (price >= 1000) {
      return '${priceStr.substring(0, priceStr.length - 3)},${priceStr.substring(priceStr.length - 3)}원';
    }
    return '$price원';
  }

  /// TTS용 가격 (쉼표 없이)
  String get ttsPrice => '$price원';

  String get accessibilityLabel => isContainer
      ? '$koreanName, $formattedPrice'
      : '$koreanName, $scoop스쿱, $formattedPrice';
}

/// 주문 데이터 모델
/// Order data model
class OrderModel {
  final FlavorModel flavor;
  final SizeOption size;

  const OrderModel({
    required this.flavor,
    required this.size,
  });

  String get summary => '${flavor.name}, ${size.displayName}';

  String get accessibilitySummary =>
    '선택하신 맛은 ${flavor.name}이고, 사이즈는 ${size.displayName}, 가격은 ${size.formattedPrice}입니다.';
}
