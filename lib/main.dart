import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/accessible_theme.dart';
import 'screens/menu_selection_screen.dart';
import 'screens/qr_entry_screen.dart';
import 'services/tts_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 모드 고정 (접근성 향상)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // TTS 서비스 초기화
    TtsService().init();
  }

  @override
  void dispose() {
    TtsService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '배스킨라빈스 접근성 메뉴',
      debugShowCheckedModeBanner: false,
      theme: AccessibleTheme.themeData,
      // 접근성 설정
      builder: (context, child) {
        return MediaQuery(
          // 시스템 텍스트 크기 설정을 적절히 제한
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 1.5),
            ),
          ),
          child: child!,
        );
      },
      home: const AppEntryPoint(),
    );
  }
}

/// 앱 진입점
/// 로그인 후 메뉴 선택으로 이동하거나 바로 메뉴 선택으로 시작
class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    // 로그인 기능을 사용하려면 LoginPage()로 변경
    // QR 우선 진입: QrEntryScreen
    return const QrEntryScreen();
  }
}

// ============================================
// 기존 로그인 페이지 (필요시 사용)
// ============================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TtsService _ttsService = TtsService();

  String _idError = '';
  String _passwordError = '';

  final String _demoId = 'a';
  final String _demoPassword = '1234';

  @override
  void initState() {
    super.initState();
    _announceScreen();
  }

  Future<void> _announceScreen() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _ttsService.speak('로그인 화면입니다. 아이디와 비밀번호를 입력해주세요.');
  }

  void _login() {
    setState(() {
      _idError = '';
      _passwordError = '';

      String inputId = _idController.text;
      String inputPassword = _passwordController.text;

      bool hasError = false;

      if (inputId != _demoId) {
        _idError = '오류: 아이디가 올바르지 않습니다. 다시 확인해 주세요.';
        _ttsService.speak(_idError);
        hasError = true;
      }

      if (inputPassword != _demoPassword) {
        _passwordError = '오류: 비밀번호가 올바르지 않습니다.';
        _ttsService.speak(_passwordError);
        hasError = true;
      }

      if (!hasError) {
        _ttsService.speak('로그인 성공. 메뉴 선택 화면으로 이동합니다.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuSelectionScreen()),
        );
      }
    });
  }

  Future<void> _loginWithGoogle() async {
    _ttsService.speak('구글 로그인 진행 중입니다. 잠시만 기다려주세요.');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Semantics(
        label: '로그인 진행 중',
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      _ttsService.speak('로그인 성공. 메뉴 선택 화면으로 이동합니다.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text("로그인"),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AccessibleTheme.basePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Semantics(
              label: '아이디 입력 필드',
              child: const Text(
                "아이디 입력:",
                style: AccessibleTheme.subtitleStyle,
              ),
            ),
            const SizedBox(height: 10),
            Semantics(
              textField: true,
              label: '아이디',
              hint: '아이디를 입력하세요',
              child: TextField(
                controller: _idController,
                style: AccessibleTheme.bodyStyle,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(width: AccessibleTheme.borderWidth),
                  ),
                  hintText: '아이디 입력',
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            if (_idError.isNotEmpty)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _idError,
                    style: AccessibleTheme.bodyStyle.copyWith(
                      color: AccessibleTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 40),
            Semantics(
              label: '비밀번호 입력 필드',
              child: const Text(
                "비밀번호 입력:",
                style: AccessibleTheme.subtitleStyle,
              ),
            ),
            const SizedBox(height: 10),
            Semantics(
              textField: true,
              label: '비밀번호',
              hint: '비밀번호를 입력하세요',
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: AccessibleTheme.bodyStyle,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(width: AccessibleTheme.borderWidth),
                  ),
                  hintText: '비밀번호 입력',
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            if (_passwordError.isNotEmpty)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _passwordError,
                    style: AccessibleTheme.bodyStyle.copyWith(
                      color: AccessibleTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 60),

            Semantics(
              button: true,
              label: '로그인 하기',
              child: SizedBox(
                height: AccessibleTheme.buttonHeight,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text(
                    "로그인 하기",
                    style: AccessibleTheme.buttonStyle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Semantics(
              button: true,
              label: '구글 계정으로 로그인',
              child: SizedBox(
                height: AccessibleTheme.buttonHeight,
                child: OutlinedButton(
                  onPressed: _loginWithGoogle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/google_icon.png",
                        width: 40,
                        height: 40,
                        semanticLabel: '구글 아이콘',
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Google 로그인",
                        style: AccessibleTheme.buttonStyle.copyWith(
                          color: AccessibleTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
