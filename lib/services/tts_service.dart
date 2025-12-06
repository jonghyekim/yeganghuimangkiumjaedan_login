import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS(Text-to-Speech) 서비스
/// 시각 장애인 사용자를 위한 음성 안내 서비스
///
/// 주요 기능:
/// - 음성 큐 관리: 이전 음성이 끝난 후 다음 음성 재생
/// - 음성 중단: 새로운 우선순위 음성 재생 시 기존 음성 즉시 중단
/// - 순차 재생: 여러 메시지를 순서대로 재생
/// - 페이지 전환 시 즉시 중단: 새 페이지 TTS가 바로 시작됨
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  Completer<void>? _speakCompleter;

  // 현재 재생 중인 세션 ID (취소 감지용)
  int _currentSessionId = 0;

  // 마지막 stop() 호출 시간 (중복 stop 방지)
  DateTime? _lastStopTime;

  /// TTS 초기화
  Future<void> init() async {
    if (_isInitialized) return;

    // 한국어 설정
    await _flutterTts.setLanguage('ko-KR');

    // 음성 속도 설정 (0.0 ~ 1.0, 시각 장애인을 위해 약간 느리게)
    await _flutterTts.setSpeechRate(0.45);

    // 음성 높이 설정 (0.5 ~ 2.0)
    await _flutterTts.setPitch(1.0);

    // 음량 설정 (0.0 ~ 1.0)
    await _flutterTts.setVolume(1.0);

    // 완료 핸들러
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _speakCompleter?.complete();
      _speakCompleter = null;
    });

    // 에러 핸들러
    _flutterTts.setErrorHandler((message) {
      _isSpeaking = false;
      _speakCompleter?.complete();
      _speakCompleter = null;
    });

    // 취소 핸들러
    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      _speakCompleter?.complete();
      _speakCompleter = null;
    });

    // 시작 핸들러
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _isInitialized = true;
  }

  /// 텍스트 읽기 (이전 음성 중단 후 새 음성 재생)
  /// 반환값: 음성이 완료되면 완료되는 Future
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    if (text.isEmpty) return;

    // 이전 음성 중지
    await stop();

    // 새 세션 시작
    _currentSessionId++;

    // Completer 생성
    _speakCompleter = Completer<void>();

    // 음성 시작
    await _flutterTts.speak(text);

    // 음성 완료까지 대기
    await _speakCompleter?.future;
  }

  /// 텍스트 읽기 (완료 대기 없이, fire-and-forget)
  /// 이전 음성은 중단됨
  Future<void> speakWithoutWait(String text) async {
    if (!_isInitialized) await init();
    if (text.isEmpty) return;

    // 이전 음성 중지
    await stop();

    // 새 세션 시작
    _currentSessionId++;

    // Completer 생성
    _speakCompleter = Completer<void>();

    // 음성 시작 (완료 대기 없음)
    await _flutterTts.speak(text);
  }

  /// 지연 후 텍스트 읽기 (취소 가능)
  /// [cancelOnNewSpeak]: true면 새 speak 호출 시 이 지연된 음성이 취소됨
  Future<void> speakWithDelay(String text, Duration delay) async {
    final sessionId = ++_currentSessionId;

    await Future.delayed(delay);

    // 지연 중에 다른 음성이 시작되었으면 취소
    if (_currentSessionId != sessionId) return;

    await speak(text);
  }

  /// 여러 텍스트를 순차적으로 읽기
  /// 각 텍스트가 완료된 후 다음 텍스트 재생
  Future<void> speakSequence(
    List<String> texts, {
    Duration gap = const Duration(milliseconds: 300),
  }) async {
    if (!_isInitialized) await init();

    final sessionId = ++_currentSessionId;

    for (int i = 0; i < texts.length; i++) {
      // 세션이 변경되었으면 중단
      if (_currentSessionId != sessionId) return;

      final text = texts[i];
      if (text.isEmpty) continue;

      // Completer 생성
      _speakCompleter = Completer<void>();

      // 음성 시작
      await _flutterTts.speak(text);

      // 음성 완료까지 대기
      await _speakCompleter?.future;

      // 세션이 변경되었으면 중단
      if (_currentSessionId != sessionId) return;

      // 마지막 항목이 아니면 간격 대기
      if (i < texts.length - 1) {
        await Future.delayed(gap);
      }
    }
  }

  /// 현재 음성 완료까지 대기
  Future<void> awaitCompletion() async {
    if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
      await _speakCompleter!.future;
    }
  }

  /// 음성 즉시 중지 (페이지 전환 시 호출)
  /// 진행 중인 모든 TTS를 즉시 중단하고 새 TTS 준비
  Future<void> stop() async {
    _currentSessionId++; // 진행 중인 시퀀스 취소
    _lastStopTime = DateTime.now();

    // 즉시 중지
    await _flutterTts.stop();
    _isSpeaking = false;

    // Completer 정리
    if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
      _speakCompleter!.complete();
    }
    _speakCompleter = null;
  }

  /// 페이지 전환용: 이전 TTS 완전히 중지 후 새 TTS 시작
  /// 반드시 150ms 대기 후 새 음성 시작 (오디오 엔진 완전 정지 보장)
  Future<void> stopAndSpeak(String text) async {
    if (!_isInitialized) await init();

    // 1. 이전 음성 완전 중지
    await stop();

    // 2. 오디오 엔진 정리 대기 (필수)
    await Future.delayed(const Duration(milliseconds: 150));

    // 3. 세션 확인 (대기 중 다른 호출이 있었으면 취소)
    final sessionId = _currentSessionId;

    if (text.isEmpty) return;

    // 4. 새 세션으로 음성 시작
    _currentSessionId++;

    // 세션이 변경되었으면 중단
    if (_currentSessionId != sessionId + 1) return;

    _speakCompleter = Completer<void>();
    await _flutterTts.speak(text);
    await _speakCompleter?.future;
  }

  /// 페이지 전환용: 이전 TTS 완전히 중지 후 여러 문장 순차 재생
  Future<void> stopAndSpeakSequence(List<String> texts) async {
    if (!_isInitialized) await init();

    // 1. 이전 음성 완전 중지
    await stop();

    // 2. 오디오 엔진 정리 대기 (필수)
    await Future.delayed(const Duration(milliseconds: 150));

    // 3. 순차 재생
    final sessionId = ++_currentSessionId;

    for (int i = 0; i < texts.length; i++) {
      if (_currentSessionId != sessionId) return;

      final text = texts[i];
      if (text.isEmpty) continue;

      _speakCompleter = Completer<void>();
      await _flutterTts.speak(text);
      await _speakCompleter?.future;

      if (_currentSessionId != sessionId) return;

      if (i < texts.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  /// 현재 음성 출력 중인지 확인
  bool get isSpeaking => _isSpeaking;

  /// 마지막 중지 시간 (디버깅용)
  DateTime? get lastStopTime => _lastStopTime;

  /// 리소스 해제
  Future<void> dispose() async {
    await stop();
  }
}
