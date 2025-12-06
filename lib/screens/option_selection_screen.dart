import 'package:flutter/material.dart';
import '../models/flavor_model.dart';
import '../models/order_model.dart';
import '../services/tts_service.dart';
import '../theme/accessible_theme.dart';
import '../utils/korean_number.dart';
import 'order_summary_screen.dart';

/// 사이즈 옵션 선택 화면
/// 스와이프로 옵션 변경, 탭으로 선택
/// 기본 선택: 파인트 (index 5, 화면 표시 6번)
/// TTS: 한자어 수사 사용 (일번, 이번, 삼번...) - 화면 표시와 동일한 인덱스
class OptionSelectionScreen extends StatefulWidget {
  final FlavorModel flavor;

  const OptionSelectionScreen({
    super.key,
    required this.flavor,
  });

  @override
  State<OptionSelectionScreen> createState() => _OptionSelectionScreenState();
}

class _OptionSelectionScreenState extends State<OptionSelectionScreen> {
  final TtsService _ttsService = TtsService();

  final List<SizeOption> _options = SizeOption.values;

  // 파인트의 인덱스 (기본 선택) - 0-based index 5 = 6번째 항목
  static const int _defaultIndex = 5; // SizeOption.pint

  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = _defaultIndex;
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: _defaultIndex,
    );
    _announceScreen();
  }

  /// 현재 사이즈 안내 메시지 생성 (화면 표시 인덱스 = TTS 인덱스)
  String _buildCurrentSizeAnnouncement() {
    final option = _options[_currentIndex];
    final displayNumber = _currentIndex + 1; // 1-based for display and TTS
    final koreanOrdinal = KoreanNumber.toOrdinal(displayNumber);
    return '$koreanOrdinal ${option.displayName} ${option.price}원. 사이즈 변경은 스와이프로 이동할 수 있습니다.';
  }

  /// 화면 진입 시 안내
  /// stopAndSpeakSequence로 이전 TTS 완전히 중지 후 시작
  Future<void> _announceScreen() async {
    await _ttsService.stopAndSpeakSequence([
      '사이즈 선택 화면입니다.',
      _buildCurrentSizeAnnouncement(),
    ]);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // TTS: 화면 표시 인덱스와 동일 (1-based), 한자어 수사 사용
    final option = _options[index];
    final displayNumber = index + 1;
    final koreanOrdinal = KoreanNumber.toOrdinal(displayNumber);
    _ttsService.speakWithoutWait('$koreanOrdinal ${option.displayName} ${option.price}원');
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _ttsService.speakWithoutWait('첫 번째 사이즈입니다.');
    }
  }

  void _goToNext() {
    if (_currentIndex < _options.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _ttsService.speakWithoutWait('마지막 사이즈입니다.');
    }
  }

  void _selectOption() {
    final selectedOption = _options[_currentIndex];
    // "선택됨" TTS 제거 - 다음 화면에서 안내

    final order = OrderModel(
      flavor: widget.flavor,
      size: selectedOption,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryScreen(order: order),
      ),
    ).then((_) {
      // 주문 요약에서 돌아왔을 때 재안내
      _announceReturnToSizeSelection();
    });
  }

  /// 메뉴 상세 화면으로 돌아가기
  /// TTS 없음 - flavor_detail_screen의 .then() 콜백에서 stopAndSpeak으로 처리
  void _goBack() {
    Navigator.pop(context);
  }

  /// 이전 화면에서 돌아왔을 때 재안내
  /// 패턴: "페이지명으로 돌아갑니다. N번 사이즈명 가격"
  Future<void> _announceReturnToSizeSelection() async {
    final option = _options[_currentIndex];
    final displayNumber = _currentIndex + 1;
    final koreanOrdinal = KoreanNumber.toOrdinal(displayNumber);

    await _ttsService.stopAndSpeak(
      '사이즈 선택 화면으로 돌아갑니다. $koreanOrdinal ${option.displayName} ${option.price}원',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: '뒤로 가기',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: _goBack,
          ),
        ),
        title: Semantics(
          header: true,
          child: const Text('사이즈 선택'),
        ),
        actions: [
          Semantics(
            label: '${KoreanNumber.toOrdinalPosition(_currentIndex + 1)} / 총 ${_options.length}개',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${_options.length}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 선택한 맛 표시
            _buildFlavorHeader(),

            // 안내 텍스트
            _buildGuideText(),

            // 옵션 카드 영역
            Expanded(child: _buildCardArea()),

            // 네비게이션 버튼
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlavorHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AccessibleTheme.primaryColor.withValues(alpha: 0.1),
      child: Semantics(
        label: '선택한 메뉴: ${widget.flavor.name}',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.icecream,
              size: 28,
              color: AccessibleTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                widget.flavor.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AccessibleTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        '좌우로 스와이프하여 사이즈를 선택하세요',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AccessibleTheme.textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCardArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: _options.length,
          itemBuilder: (context, index) {
            final option = _options[index];
            final isSelected = _currentIndex == index;

            return AnimatedScale(
              scale: isSelected ? 1.0 : 0.88,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: _buildOptionCard(option, index, isSelected, constraints.maxHeight - 24),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionCard(SizeOption option, int index, bool isSelected, double maxHeight) {
    // 화면 표시용 인덱스 (1-based)
    final displayNumber = index + 1;
    // TTS용 한자어 수사 (일번, 이번, 삼번...)
    final koreanOrdinal = KoreanNumber.toOrdinal(displayNumber);

    return Semantics(
      label: '$koreanOrdinal, ${option.displayName}, ${option.formattedPrice}',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () {
          if (isSelected) {
            _selectOption();
          } else {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: isSelected
                ? AccessibleTheme.primaryColor.withValues(alpha: 0.15)
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 순번 배지 (화면 표시: 1부터)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AccessibleTheme.primaryColor
                        : AccessibleTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$displayNumber번',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 아이콘 또는 이미지
                Flexible(
                  child: _buildSizeImage(option, isSelected),
                ),

                const SizedBox(height: 12),

                // 사이즈 이름
                Text(
                  option.displayName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AccessibleTheme.primaryColor
                        : AccessibleTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                // 영어 이름
                Text(
                  option.englishName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AccessibleTheme.primaryColor.withValues(alpha: 0.8)
                        : AccessibleTheme.textColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // 가격 (큰 글씨로 표시)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AccessibleTheme.primaryColor
                        : AccessibleTheme.cardBorderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    option.formattedPrice,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // 스쿱 수 표시 (컨테이너 타입이 아닌 경우만)
                if (!option.isContainer) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${option.scoop}스쿱',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AccessibleTheme.primaryColor
                          : AccessibleTheme.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],

                // 선택됨 표시
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.check_circle,
                    size: 28,
                    color: AccessibleTheme.primaryColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 사이즈에 따른 이미지/아이콘 빌드
  /// 파인트 이상은 컨테이너 이미지, 그 외는 스쿱 아이콘
  Widget _buildSizeImage(SizeOption option, bool isSelected) {
    if (option.isContainer) {
      // 파인트, 쿼터, 패밀리, 하프갤론은 컨테이너 이미지
      return _buildContainerImage(option, isSelected);
    } else {
      // 싱글, 더블 등은 스쿱 아이콘
      return _buildScoopIcon(option, isSelected);
    }
  }

  /// 컨테이너 타입 이미지 (파인트 이상)
  Widget _buildContainerImage(SizeOption option, bool isSelected) {
    // 컨테이너 크기에 따라 아이콘 크기 조절
    double iconSize;
    switch (option) {
      case SizeOption.pint:
        iconSize = 60;
        break;
      case SizeOption.quart:
        iconSize = 70;
        break;
      case SizeOption.family:
        iconSize = 80;
        break;
      case SizeOption.halfGallon:
        iconSize = 90;
        break;
      default:
        iconSize = 60;
    }

    return Container(
      constraints: BoxConstraints(maxHeight: iconSize + 20),
      child: Icon(
        Icons.takeout_dining, // 컨테이너 아이콘
        size: iconSize,
        color: isSelected
            ? AccessibleTheme.primaryColor
            : AccessibleTheme.textColor,
      ),
    );
  }

  /// 스쿱 타입 아이콘 (싱글~더블레귤러)
  Widget _buildScoopIcon(SizeOption option, bool isSelected) {
    final iconScale = 1.0 + (option.scoop * 0.15);
    const baseSize = 50.0;

    return Container(
      constraints: BoxConstraints(maxHeight: baseSize * iconScale + 10),
      child: Transform.scale(
        scale: iconScale,
        child: Icon(
          Icons.icecream,
          size: baseSize,
          color: isSelected
              ? AccessibleTheme.primaryColor
              : AccessibleTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    const buttonSpacing = 12.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // 이전 버튼
          Expanded(
            child: _buildNavButton(
              label: '이전',
              icon: Icons.arrow_back,
              onPressed: _currentIndex > 0 ? _goToPrevious : null,
              semanticLabel: '이전 사이즈로 이동',
              iconFirst: true,
            ),
          ),

          const SizedBox(width: buttonSpacing),

          // 선택 버튼
          Expanded(
            flex: 2,
            child: _buildSelectButton(),
          ),

          const SizedBox(width: buttonSpacing),

          // 다음 버튼
          Expanded(
            child: _buildNavButton(
              label: '다음',
              icon: Icons.arrow_forward,
              onPressed: _currentIndex < _options.length - 1 ? _goToNext : null,
              semanticLabel: '다음 사이즈로 이동',
              iconFirst: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required String semanticLabel,
    required bool iconFirst,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: onPressed != null,
      child: SizedBox(
        height: 64,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AccessibleTheme.secondaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: iconFirst
                  ? [
                      Icon(icon, size: 24),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  : [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(icon, size: 24),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectButton() {
    return Semantics(
      button: true,
      label: '${_options[_currentIndex].displayName} 선택하기',
      child: SizedBox(
        height: 64,
        child: ElevatedButton(
          onPressed: _selectOption,
          style: ElevatedButton.styleFrom(
            backgroundColor: AccessibleTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check, size: 24),
                SizedBox(width: 8),
                Text(
                  '선택하기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
