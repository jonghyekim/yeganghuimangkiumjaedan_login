import 'package:flutter/material.dart';
import '../models/flavor_model.dart';
import '../services/flavor_service.dart';
import '../services/tts_service.dart';
import '../theme/accessible_theme.dart';
import '../utils/korean_number.dart';
import '../widgets/menu_card.dart';
import 'flavor_detail_screen.dart';
import 'qr_scanner_screen.dart';

/// 메뉴 선택 화면
/// 스와이프로 아이템 간 이동, 탭으로 선택
/// TTS: 한자어 수사 사용 (일번, 이번, 삼번...)
/// Menu selection screen with swipe navigation
class MenuSelectionScreen extends StatefulWidget {
  /// 이전 화면에서 돌아왔을 때 재안내 여부
  final bool announceOnReturn;

  const MenuSelectionScreen({
    super.key,
    this.announceOnReturn = false,
  });

  @override
  State<MenuSelectionScreen> createState() => _MenuSelectionScreenState();
}

class _MenuSelectionScreenState extends State<MenuSelectionScreen> {
  final FlavorService _flavorService = FlavorService();
  final TtsService _ttsService = TtsService();
  final PageController _pageController = PageController(viewportFraction: 0.9);

  List<FlavorModel> _flavors = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initTtsAndLoadFlavors();
  }

  Future<void> _initTtsAndLoadFlavors() async {
    await _ttsService.init();
    await _loadFlavors();
  }

  Future<void> _loadFlavors() async {
    try {
      final flavors = await _flavorService.loadFlavors();
      setState(() {
        _flavors = flavors;
        _isLoading = false;
      });

      // 페이지 로드 완료 안내
      await Future.delayed(const Duration(milliseconds: 500));

      // 돌아온 경우: 페이지명 + 현재 아이템 / 처음 진입: 전체 안내
      if (widget.announceOnReturn) {
        final koreanOrdinal = KoreanNumber.toOrdinal(1);
        await _ttsService.stopAndSpeak(
          '메뉴 선택 화면으로 돌아갑니다. $koreanOrdinal ${_flavors[0].name}',
        );
      } else {
        await _announceMenuSelection();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      await _ttsService.speak('메뉴를 불러오는 데 실패했습니다.');
    }
  }

  /// 메뉴 선택 화면 안내 (진입 시 사용)
  /// stopAndSpeakSequence로 이전 TTS 완전히 중지 후 시작
  Future<void> _announceMenuSelection() async {
    if (_flavors.isEmpty) return;

    final koreanOrdinal = KoreanNumber.toOrdinal(1);
    await _ttsService.stopAndSpeakSequence([
      '메뉴 선택 화면입니다.',
      '총 ${_flavors.length}개의 메뉴가 있습니다.',
      '현재 선택된 항목은 $koreanOrdinal ${_flavors[0].name}입니다. 좌우 스와이프로 메뉴를 이동할 수 있습니다.',
    ]);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // 현재 아이템 음성 안내 - 한자어 수사 사용 (일번, 이번, 삼번...)
    final flavor = _flavors[index];
    final koreanOrdinal = KoreanNumber.toOrdinal(index + 1);
    _ttsService.speakWithoutWait('$koreanOrdinal ${flavor.name}');
  }

  void _onMenuTap(FlavorModel flavor) {
    // 선택 시 TTS 없음 - 다음 화면에서 안내
    // "선택됨" TTS 제거하여 중복 방지
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlavorDetailScreen(flavor: flavor),
      ),
    ).then((_) {
      // 상세 화면에서 돌아왔을 때 재안내
      _announceReturnToMenuSelection();
    });
  }

  Future<void> _openQrScanner() async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (!mounted || scanned == null) return;
    await _handleDeepLink(scanned);
  }

  Future<void> _handleDeepLink(String rawValue) async {
    final uri = Uri.tryParse(rawValue.trim());
    if (uri == null) {
      await _showDeepLinkError('유효하지 않은 QR 코드입니다.');
      return;
    }

    final String? section = _extractSection(uri);
    final String? id = _extractId(uri);

    switch (section) {
      case 'menu':
        await _ttsService.stopAndSpeak('메뉴 화면으로 이동합니다.');
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
        break;
      case 'flavor':
        await _goToFlavorById(id);
        break;
      default:
        await _showDeepLinkError('지원하지 않는 QR 링크입니다.');
    }
  }

  String? _extractSection(Uri uri) {
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.isNotEmpty) return uri.host;
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }

  String? _extractId(Uri uri) {
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (uri.pathSegments.length > 1) return uri.pathSegments[1];
    }

    if (uri.host.isNotEmpty && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    if (uri.pathSegments.length > 1) return uri.pathSegments[1];

    return uri.queryParameters['id'];
  }

  Future<void> _goToFlavorById(String? id) async {
    if (id == null || id.isEmpty) {
      await _showDeepLinkError('QR 코드에 메뉴 정보가 없습니다.');
      return;
    }

    if (_flavors.isEmpty) {
      await _showDeepLinkError('메뉴 데이터를 불러오지 못했습니다.');
      return;
    }

    FlavorModel? flavor;
    try {
      flavor = _flavors.firstWhere((f) => f.id == id);
    } catch (_) {
      flavor = null;
    }

    if (flavor == null) {
      await _showDeepLinkError('해당 메뉴를 찾을 수 없습니다.');
      return;
    }

    final targetFlavor = flavor;

    await _ttsService.stopAndSpeak('${flavor.name} 상세 화면으로 이동합니다.');

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlavorDetailScreen(flavor: targetFlavor),
      ),
    ).then((_) => _announceReturnToMenuSelection());
  }

  Future<void> _showDeepLinkError(String message) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    await _ttsService.speak(message);
  }

  /// 이전 화면에서 돌아왔을 때 재안내
  /// 패턴: "페이지명으로 돌아갑니다. N번 아이템명"
  Future<void> _announceReturnToMenuSelection() async {
    if (_flavors.isEmpty) return;

    final koreanOrdinal = KoreanNumber.toOrdinal(_currentIndex + 1);
    final currentFlavor = _flavors[_currentIndex];

    await _ttsService.stopAndSpeak(
      '메뉴 선택 화면으로 돌아갑니다. $koreanOrdinal ${currentFlavor.name}',
    );
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _ttsService.speakWithoutWait('첫 번째 메뉴입니다.');
    }
  }

  void _goToNext() {
    if (_currentIndex < _flavors.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _ttsService.speakWithoutWait('마지막 메뉴입니다.');
    }
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
        title: Semantics(
          header: true,
          child: const Text('메뉴 선택'),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'QR 스캔',
            child: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _isLoading ? null : _openQrScanner,
            ),
          ),
          // 현재 위치 표시
          if (_flavors.isNotEmpty)
            Semantics(
              label: '${KoreanNumber.toOrdinalPosition(_currentIndex + 1)} / 총 ${_flavors.length}개',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    '${_currentIndex + 1}/${_flavors.length}',
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Semantics(
        label: '메뉴를 불러오는 중입니다. 잠시만 기다려주세요.',
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 4),
              SizedBox(height: 24),
              Text('메뉴를 불러오는 중...', style: AccessibleTheme.bodyStyle),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return SafeArea(
      child: Column(
        children: [
          // 안내 텍스트
          _buildGuideText(),

          // 카드 스와이프 영역
          Expanded(child: _buildCardArea()),

          // 네비게이션 버튼
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildGuideText() {
    return Semantics(
      label: '좌우로 스와이프하여 메뉴를 탐색하세요',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AccessibleTheme.primaryColor.withValues(alpha: 0.1),
        child: const Text(
          '좌우로 스와이프하여 메뉴를 탐색하세요',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AccessibleTheme.textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCardArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: _flavors.length,
          itemBuilder: (context, index) {
            final flavor = _flavors[index];
            return AnimatedScale(
              scale: _currentIndex == index ? 1.0 : 0.92,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                child: MenuCard(
                  flavor: flavor,
                  itemNumber: index + 1,
                  isSelected: _currentIndex == index,
                  onTap: () => _onMenuTap(flavor),
                  maxHeight: constraints.maxHeight - 32,
                ),
              ),
            );
          },
        );
      },
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
              semanticLabel: '이전 메뉴로 이동',
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
              onPressed:
                  _currentIndex < _flavors.length - 1 ? _goToNext : null,
              semanticLabel: '다음 메뉴로 이동',
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
    final currentName =
        _flavors.isNotEmpty ? _flavors[_currentIndex].name : '';

    return Semantics(
      button: true,
      label: '$currentName 선택하기',
      child: SizedBox(
        height: 64,
        child: ElevatedButton(
          onPressed: () {
            if (_flavors.isNotEmpty) {
              _onMenuTap(_flavors[_currentIndex]);
            }
          },
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

  Widget _buildErrorView() {
    return Semantics(
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AccessibleTheme.basePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AccessibleTheme.errorColor,
              ),
              const SizedBox(height: 24),
              Text(
                '오류가 발생했습니다',
                style: AccessibleTheme.titleStyle.copyWith(
                  color: AccessibleTheme.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: AccessibleTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 64,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _loadFlavors();
                  },
                  icon: const Icon(Icons.refresh, size: 28),
                  label: const Text(
                    '다시 시도',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
