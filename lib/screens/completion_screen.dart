import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/tts_service.dart';
import '../theme/accessible_theme.dart';
import '../widgets/accessible_button.dart';
import 'menu_selection_screen.dart';

/// 주문 완료 화면
/// 간단한 확인 메시지와 메인 메뉴로 돌아가는 버튼
class CompletionScreen extends StatefulWidget {
  final OrderModel order;

  const CompletionScreen({
    super.key,
    required this.order,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
    _announceCompletion();
  }

  /// 화면 진입 시 안내
  /// stopAndSpeak으로 이전 TTS 완전히 중지 후 시작
  Future<void> _announceCompletion() async {
    await _ttsService.stopAndSpeak(
      '주문이 완료되었습니다. '
      '${widget.order.flavor.name}, ${widget.order.size.displayName}을 선택하셨습니다. '
      '이용해 주셔서 감사합니다. '
      '새로운 주문을 하시려면 "처음으로" 버튼을 눌러주세요.',
    );
  }

  /// 메뉴 선택 화면으로 돌아가기
  /// TTS 없음 - MenuSelectionScreen에서 stopAndSpeakSequence로 처리
  void _goToMain() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MenuSelectionScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccessibleTheme.successColor.withValues(alpha: 0.05),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AccessibleTheme.basePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 완료 아이콘 (애니메이션)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Semantics(
                  image: true,
                  label: '주문 완료',
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AccessibleTheme.successColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AccessibleTheme.successColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AccessibleTheme.cardSpacing * 2),

              // 완료 메시지
              Semantics(
                header: true,
                liveRegion: true,
                child: const Text(
                  '주문 완료!',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: AccessibleTheme.successColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AccessibleTheme.cardSpacing),

              // 감사 메시지
              const Text(
                '이용해 주셔서 감사합니다',
                style: AccessibleTheme.subtitleStyle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AccessibleTheme.cardSpacing * 2),

              // 주문 요약 카드
              Container(
                padding: const EdgeInsets.all(AccessibleTheme.cardPadding),
                decoration: BoxDecoration(
                  color: AccessibleTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(
                    AccessibleTheme.borderRadius,
                  ),
                  border: Border.all(
                    color: AccessibleTheme.successColor,
                    width: AccessibleTheme.borderWidth,
                  ),
                ),
                child: Semantics(
                  label: '주문 내역: ${widget.order.summary}',
                  child: Column(
                    children: [
                      const Text(
                        '주문 내역',
                        style: AccessibleTheme.labelStyle,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.order.flavor.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.icecream,
                                  size: 60,
                                  color: AccessibleTheme.primaryColor,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.order.flavor.name,
                                  style: AccessibleTheme.subtitleStyle,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.order.size.displayName,
                                  style: AccessibleTheme.bodyStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // 처음으로 버튼
              AccessibleButton(
                text: '처음으로',
                icon: Icons.home,
                onPressed: _goToMain,
                semanticLabel: '메뉴 선택 화면으로 돌아가기',
              ),

              const SizedBox(height: AccessibleTheme.basePadding),
            ],
          ),
        ),
      ),
    );
  }
}
