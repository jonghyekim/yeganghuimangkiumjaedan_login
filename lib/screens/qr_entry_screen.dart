import 'package:flutter/material.dart';

import '../models/flavor_model.dart';
import '../screens/flavor_detail_screen.dart';
import '../screens/menu_selection_screen.dart';
import '../services/flavor_service.dart';
import '../services/tts_service.dart';
import '../theme/accessible_theme.dart';
import 'qr_scanner_screen.dart';

/// 앱 진입용 QR 스캔 화면
/// 스캔 결과에 따라 메뉴/맛 상세로 라우팅
class QrEntryScreen extends StatefulWidget {
  const QrEntryScreen({super.key});

  @override
  State<QrEntryScreen> createState() => _QrEntryScreenState();
}

class _QrEntryScreenState extends State<QrEntryScreen> {
  final FlavorService _flavorService = FlavorService();
  final TtsService _ttsService = TtsService();

  List<FlavorModel> _flavors = [];
  bool _isLoadingFlavors = false;

  @override
  void initState() {
    super.initState();
    _ttsService.speak('QR 코드를 비추면 해당 화면으로 이동합니다.');
  }

  Future<void> _ensureFlavorsLoaded() async {
    if (_flavors.isNotEmpty || _isLoadingFlavors) return;
    setState(() => _isLoadingFlavors = true);
    try {
      _flavors = await _flavorService.loadFlavors();
    } finally {
      if (mounted) {
        setState(() => _isLoadingFlavors = false);
      }
    }
  }

  Future<void> _handleScan(String raw) async {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) {
      await _showError('유효하지 않은 QR 코드입니다.');
      return;
    }

    final section = _extractSection(uri);
    final id = _extractId(uri);

    switch (section) {
      case 'menu':
        await _ttsService.stopAndSpeak('메뉴 화면으로 이동합니다.');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuSelectionScreen()),
        );
        break;
      case 'flavor':
        await _goToFlavorById(id);
        break;
      default:
        await _showError('지원하지 않는 QR 링크입니다.');
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
      await _showError('QR 코드에 메뉴 정보가 없습니다.');
      return;
    }

    await _ensureFlavorsLoaded();
    if (_flavors.isEmpty) {
      await _showError('메뉴 데이터를 불러오지 못했습니다.');
      return;
    }

    FlavorModel? flavor;
    try {
      flavor = _flavors.firstWhere((f) => f.id == id);
    } catch (_) {
      flavor = null;
    }

    if (flavor == null) {
      await _showError('해당 메뉴를 찾을 수 없습니다.');
      return;
    }

    await _ttsService.stopAndSpeak('${flavor.name} 상세 화면으로 이동합니다.');
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FlavorDetailScreen(flavor: flavor!),
      ),
    );
  }

  Future<void> _showError(String message) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    await _ttsService.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('QR로 시작'),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AccessibleTheme.primaryColor.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _isLoadingFlavors
                  ? '메뉴 데이터를 불러오는 중입니다...'
                  : 'QR 코드를 비추면 해당 화면으로 이동합니다.',
              style: AccessibleTheme.bodyStyle,
            ),
          ),
          Expanded(
            child: QrScannerScreen(
              onScanned: _handleScan,
              popOnScan: false,
              showScaffold: false,
            ),
          ),
        ],
      ),
    );
  }
}
