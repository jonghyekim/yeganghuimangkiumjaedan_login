import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/tts_service.dart';
import '../theme/accessible_theme.dart';
import '../widgets/accessible_button.dart';
import 'completion_screen.dart';
import 'menu_selection_screen.dart';

/// 주문 요약 화면
/// 선택한 맛과 사이즈를 확인
class OrderSummaryScreen extends StatefulWidget {
  final OrderModel order;

  const OrderSummaryScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _announceScreen();
  }

  /// 현재 주문 안내 메시지 생성
  String _buildOrderAnnouncement() {
    return '${widget.order.accessibilitySummary} 오른쪽 스와이프는 주문 확정, 왼쪽 스와이프는 사이즈 선택입니다.';
  }

  /// 화면 진입 시 안내
  /// stopAndSpeakSequence로 이전 TTS 완전히 중지 후 시작
  Future<void> _announceScreen() async {
    await _ttsService.stopAndSpeakSequence([
      '주문 요약 화면입니다.',
      _buildOrderAnnouncement(),
    ]);
  }

  /// 주문 확정 - CompletionScreen으로 이동
  /// TTS 없음 - CompletionScreen에서 stopAndSpeakSequence로 처리
  void _confirmOrder() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionScreen(order: widget.order),
      ),
      (route) => false,
    );
  }

  /// 사이즈 선택 화면으로 돌아가기
  /// TTS 없음 - option_selection_screen의 .then() 콜백에서 stopAndSpeak으로 처리
  void _goBack() {
    Navigator.pop(context);
  }

  /// 메뉴 선택 화면으로 돌아가기 (전체 주문 수정)
  /// TTS 없음 - MenuSelectionScreen에서 announceOnReturn + stopAndSpeak으로 처리
  void _modifyOrder() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MenuSelectionScreen(announceOnReturn: true),
      ),
      (route) => false,
    );
  }

  /// 수평 스와이프 제스처 처리
  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    // 오른쪽 스와이프 → 주문 확정
    if (details.primaryVelocity! < -200) {
      _confirmOrder();
    }
    // 왼쪽 스와이프 → 사이즈 선택으로 돌아가기
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
          child: const Text('주문 확인'),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: _handleHorizontalSwipe,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AccessibleTheme.basePadding),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 제목
              Semantics(
                header: true,
                child: const Text(
                  '주문 내역을 확인해주세요',
                  style: AccessibleTheme.titleStyle,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AccessibleTheme.cardSpacing * 2),

              // 주문 요약 카드
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AccessibleTheme.cardPadding),
                  decoration: BoxDecoration(
                    color: AccessibleTheme.cardColor,
                    borderRadius: BorderRadius.circular(
                      AccessibleTheme.borderRadius,
                    ),
                    border: Border.all(
                      color: AccessibleTheme.cardBorderColor,
                      width: AccessibleTheme.borderWidth,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 아이콘
                      const Icon(
                        Icons.shopping_cart,
                        size: AccessibleTheme.iconSize * 2,
                        color: AccessibleTheme.primaryColor,
                      ),

                      const SizedBox(height: AccessibleTheme.cardSpacing),

                      // 구분선
                      Container(
                        height: 3,
                        color: AccessibleTheme.primaryColor,
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                      ),

                      const SizedBox(height: AccessibleTheme.cardSpacing * 1.5),

                      // 맛 정보
                      Semantics(
                        label: '선택한 맛: ${widget.order.flavor.name}',
                        child: _buildOrderItem(
                          icon: Icons.icecream,
                          label: '맛',
                          value: widget.order.flavor.name,
                        ),
                      ),

                      const SizedBox(height: AccessibleTheme.cardSpacing),

                      // 사이즈 정보
                      Semantics(
                        label: '선택한 사이즈: ${widget.order.size.displayName}, ${widget.order.size.formattedPrice}',
                        child: _buildOrderItem(
                          icon: Icons.straighten,
                          label: '사이즈',
                          value: widget.order.size.displayName,
                        ),
                      ),

                      const SizedBox(height: AccessibleTheme.cardSpacing),

                      // 가격 정보
                      Semantics(
                        label: '가격: ${widget.order.size.formattedPrice}',
                        child: _buildOrderItem(
                          icon: Icons.attach_money,
                          label: '가격',
                          value: widget.order.size.formattedPrice,
                        ),
                      ),

                      const Spacer(),

                      // 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AccessibleTheme.borderRadius,
                        ),
                        child: Image.network(
                          widget.order.flavor.imageUrl,
                          height: 150,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.icecream,
                              size: 100,
                              color: AccessibleTheme.primaryColor,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AccessibleTheme.cardSpacing * 2),

              // 확정 버튼
              AccessibleButton(
                text: '확정하기',
                icon: Icons.check_circle,
                onPressed: _confirmOrder,
                semanticLabel: '주문 확정하기',
              ),

              const SizedBox(height: AccessibleTheme.cardSpacing),

              // 수정 버튼
              AccessibleButton(
                text: '수정하기',
                icon: Icons.edit,
                onPressed: _modifyOrder,
                isPrimary: false,
                semanticLabel: '주문 수정하기 - 메뉴 선택으로 돌아가기',
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildOrderItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AccessibleTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 36,
            color: AccessibleTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AccessibleTheme.labelStyle.copyWith(
                  color: AccessibleTheme.textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AccessibleTheme.subtitleStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
