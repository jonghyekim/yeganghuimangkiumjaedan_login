import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시각 장애인 접근성 데모',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamilyFallback: const ["Noto Sans KR", "Malgun Gothic"],
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _idError = '';
  String _passwordError = '';

  final String _demoId = 'a';
  final String _demoPassword = '1234';

  void _login() {
    setState(() {
      _idError = '';
      _passwordError = '';

      String inputId = _idController.text;
      String inputPassword = _passwordController.text;

      bool hasError = false;

      if (inputId != _demoId) {
        _idError = '오류: 아이디가 올바르지 않습니다. 다시 확인해 주세요.';
        hasError = true;
      }

      if (inputPassword != _demoPassword) {
        _passwordError = '오류: 비밀번호가 올바르지 않습니다.';
        hasError = true;
      }

      if (!hasError) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인", style: TextStyle(fontSize: 30)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Text(
              "아이디 입력:",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _idController,
              style: const TextStyle(fontSize: 30),
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(width: 3.0)),
                hintText: '아이디 입력',
                contentPadding: EdgeInsets.all(20),
              ),
            ),
            if (_idError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _idError,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 40),
            const Text(
              "비밀번호 입력:",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(fontSize: 30),
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(width: 3.0)),
                hintText: '비밀번호 입력',
                contentPadding: EdgeInsets.all(20),
              ),
            ),
            if (_passwordError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _passwordError,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 60),

            SizedBox(
              height: 80,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "로그인 하기",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("환영합니다")),
      body: const Center(
        child: Text(
          "로그인 성공!",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
