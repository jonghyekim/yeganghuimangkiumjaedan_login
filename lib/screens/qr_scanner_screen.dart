import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/tts_service.dart';
import '../theme/accessible_theme.dart';

/// QR 코드 스캔 화면
/// mobile_scanner로 스캔하고, 감지된 문자열을 상위 화면으로 반환
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  final TtsService _ttsService = TtsService();

  bool _isHandling = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _announceInstructions();
  }

  Future<void> _announceInstructions() async {
    await _ttsService.speak('QR 코드를 카메라 프레임 안에 맞춰주세요.');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isHandling) return;
    if (capture.barcodes.isEmpty) return;

    final String? rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isHandling = true;
      _message = 'QR 코드가 인식되었습니다.';
    });
    Navigator.pop(context, rawValue);
  }

  void _toggleTorch() {
    _controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: '닫기',
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Semantics(
          header: true,
          child: const Text('QR 스캔'),
        ),
        actions: [
          Semantics(
            button: true,
            label: '손전등 토글',
            child: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, MobileScannerState state, child) {
                final torchState = state.torchState;
                IconData icon;
                switch (torchState) {
                  case TorchState.on:
                    icon = Icons.flash_on;
                    break;
                  case TorchState.auto:
                  case TorchState.off:
                    icon = Icons.flash_off;
                    break;
                  case TorchState.unavailable:
                    icon = Icons.flashlight_off;
                    break;
                }
                return IconButton(
                  icon: Icon(icon),
                  onPressed: torchState == TorchState.unavailable ? null : _toggleTorch,
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInstruction(),
          Expanded(
            child: Stack(
              children: [
                _buildScannerView(),
                _buildScanFrameOverlay(),
              ],
            ),
          ),
          _buildMessageBar(),
        ],
      ),
    );
  }

  Widget _buildInstruction() {
    return Container(
      width: double.infinity,
      color: AccessibleTheme.primaryColor.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          Icon(Icons.qr_code_scanner, color: AccessibleTheme.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'QR 코드를 사각형 프레임 안에 맞추면 자동으로 인식합니다.',
              style: AccessibleTheme.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return MobileScanner(
      controller: _controller,
      fit: BoxFit.cover,
      onDetect: _onDetect,
      errorBuilder: (context, error) {
        return Center(
          child: Text(
            '카메라를 시작할 수 없습니다.\n${error.errorDetails?.message ?? error.errorCode.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        );
      },
    );
  }

  Widget _buildScanFrameOverlay() {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AccessibleTheme.primaryColor,
            width: 4,
          ),
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
    );
  }

  Widget _buildMessageBar() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, MobileScannerState state, child) {
        String displayMessage = _message ??
            (state.hasCameraPermission
                ? '카메라를 움직이지 말고 QR 코드를 비춰주세요.'
                : '카메라 권한을 허용해주세요.');
        return Container(
          width: double.infinity,
          color: Colors.black.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            displayMessage,
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }
}
