import 'package:flutter/material.dart';
import '../models/flavor_model.dart';
import '../services/tts_service.dart';
import '../theme/accessible_theme.dart';
import 'option_selection_screen.dart';

/// 메뉴 상세 화면
/// 선택한 메뉴의 상세 정보를 표시하고 TTS로 읽어줌
/// 설명은 이 화면에서만 음성으로 안내
/// 스와이프: 오른쪽 → 사이즈 선택, 왼쪽 → 메뉴 선택으로 돌아가기
class FlavorDetailScreen extends StatefulWidget {
  final FlavorModel flavor;

  const FlavorDetailScreen({
    super.key,
    required this.flavor,
  });

  @override
  State<FlavorDetailScreen> createState() => _FlavorDetailScreenState();
}

class _FlavorDetailScreenState extends State<FlavorDetailScreen> {
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _announceScreen();
  }

  /// 화면 진입 시 안내 (스와이프 기반 안내)
  /// stopAndSpeakSequence로 이전 TTS 완전히 중지 후 시작
  Future<void> _announceScreen() async {
    await _ttsService.stopAndSpeakSequence([
      '${widget.flavor.name} 상세 정보입니다.',
      widget.flavor.description,
      '오른쪽 스와이프는 사이즈 선택, 왼쪽 스와이프는 메뉴 선택입니다.',
    ]);
  }

  /// 사이즈 선택 화면으로 이동 (오른쪽 스와이프)
  /// TTS 없음 - OptionSelectionScreen에서 stopAndSpeakSequence로 처리
  void _goToSizeSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OptionSelectionScreen(flavor: widget.flavor),
      ),
    ).then((_) {
      // 사이즈 선택에서 돌아왔을 때 재안내
      _announceReturnToDetail();
    });
  }

  /// 메뉴 선택 화면으로 돌아가기 (왼쪽 스와이프)
  /// TTS 없음 - menu_selection_screen의 .then() 콜백에서 stopAndSpeak으로 처리
  void _goBack() {
    Navigator.pop(context);
  }

  /// 이전 화면에서 돌아왔을 때 재안내
  /// 패턴: "아이템명 상세 화면으로 돌아갑니다." + "설명"
  /// 인덱스 번호 없음, 설명만 포함
  Future<void> _announceReturnToDetail() async {
    await _ttsService.stopAndSpeakSequence([
      '${widget.flavor.name} 상세 화면으로 돌아갑니다.',
      widget.flavor.description,
    ]);
  }

  /// 수평 스와이프 제스처 처리
  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    // 오른쪽 스와이프 → 사이즈 선택 화면으로 이동
    if (details.primaryVelocity! < -200) {
      _goToSizeSelection();
    }
    // 왼쪽 스와이프 → 메뉴 선택 화면으로 돌아가기
    else if (details.primaryVelocity! > 200) {
      _goBack();
    }
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
          child: Text(
            widget.flavor.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: _handleHorizontalSwipe,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 스와이프 안내 텍스트
                        _buildSwipeGuide(),

                        const SizedBox(height: 16),

                        // 이미지
                        _buildImage(),

                        const SizedBox(height: 20),

                        // 이름
                        _buildName(),

                        const SizedBox(height: 16),

                        // 구분선
                        _buildDivider(),

                        const SizedBox(height: 16),

                        // 설명
                        _buildDescription(),

                        const SizedBox(height: 24),

                        // 버튼 영역
                        _buildButtons(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeGuide() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AccessibleTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.swipe, size: 24, color: AccessibleTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                '스와이프로 이동',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AccessibleTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_back, size: 18, color: AccessibleTheme.textColor),
                  SizedBox(width: 4),
                  Text('메뉴 선택', style: TextStyle(fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  Text('사이즈 선택', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 18, color: AccessibleTheme.textColor),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Semantics(
      image: true,
      label: '${widget.flavor.name} 아이스크림 이미지',
      child: Container(
        constraints: const BoxConstraints(maxHeight: 180),
        decoration: BoxDecoration(
          color: AccessibleTheme.cardColor,
          borderRadius: BorderRadius.circular(AccessibleTheme.borderRadius),
          border: Border.all(
            color: AccessibleTheme.cardBorderColor,
            width: AccessibleTheme.borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AccessibleTheme.borderRadius - AccessibleTheme.borderWidth,
          ),
          child: Image.network(
            widget.flavor.imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                color: AccessibleTheme.cardColor,
                child: const Center(
                  child: Icon(
                    Icons.icecream,
                    size: 80,
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
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildName() {
    return Semantics(
      header: true,
      child: Text(
        widget.flavor.name,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: AccessibleTheme.textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 3,
      color: AccessibleTheme.primaryColor,
      margin: const EdgeInsets.symmetric(horizontal: 40),
    );
  }

  Widget _buildDescription() {
    return Semantics(
      label: '설명: ${widget.flavor.description}',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AccessibleTheme.cardColor,
          borderRadius: BorderRadius.circular(AccessibleTheme.borderRadius),
          border: Border.all(
            color: AccessibleTheme.cardBorderColor,
            width: AccessibleTheme.borderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 24,
                  color: AccessibleTheme.primaryColor,
                ),
                SizedBox(width: 10),
                Text(
                  '설명',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AccessibleTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.flavor.description,
              style: const TextStyle(
                fontSize: 20,
                height: 1.5,
                color: AccessibleTheme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 선택 버튼 (오른쪽 스와이프와 동일 기능)
        Semantics(
          button: true,
          label: '${widget.flavor.name} 선택하기. 오른쪽 스와이프와 같습니다.',
          child: SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: _goToSizeSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AccessibleTheme.primaryColor,
                foregroundColor: Colors.white,
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
                    Icon(Icons.check_circle, size: 28),
                    SizedBox(width: 12),
                    Text(
                      '이 메뉴 선택하기',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 뒤로 가기 버튼 (왼쪽 스와이프와 동일 기능)
        Semantics(
          button: true,
          label: '메뉴 선택 화면으로 돌아가기. 왼쪽 스와이프와 같습니다.',
          child: SizedBox(
            height: 64,
            child: OutlinedButton(
              onPressed: _goBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AccessibleTheme.primaryColor,
                side: const BorderSide(
                  color: AccessibleTheme.primaryColor,
                  width: 3,
                ),
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
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 8),
                    Icon(Icons.list, size: 28),
                    SizedBox(width: 12),
                    Text(
                      '메뉴 선택으로',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
