import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// จัดการเสียงเอฟเฟกต์ เพลงพื้นหลัง และเสียงอ่านโจทย์ให้กับแอป
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal() {
    _initTts();
  }

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _ttsEnabled = true;

  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;
  bool get isTtsEnabled => _ttsEnabled;

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('th-TH');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('ตั้งค่า TTS ไม่สำเร็จ: $e');
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    if (!enabled) {
      await stopBackgroundMusic();
    } else {
      await playBackgroundMusic();
    }
  }

  void setTtsEnabled(bool enabled) {
    _ttsEnabled = enabled;
  }

  Future<void> playSuccessSound() async {
    if (!_soundEnabled) return;
    await _playSfx('sounds/ting.mp3', 'success');
  }

  Future<void> playWrongSound() async {
    if (!_soundEnabled) return;
    await _playSfx('sounds/ting.mp3', 'wrong');
  }

  Future<void> playButtonSound() async {
    if (!_soundEnabled) return;
    await _playSfx('sounds/ting.mp3', 'button_click');
  }

  Future<void> _playSfx(String assetPath, String label) async {
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('เล่นเสียง $label ไม่สำเร็จ: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      final state = _musicPlayer.state;
      if (state == PlayerState.playing) return;

      await _musicPlayer.setVolume(0.5);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/bgsound.mp3'));
    } catch (e) {
      debugPrint('เล่นเพลงพื้นหลังไม่สำเร็จ: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      final state = _musicPlayer.state;
      if (state == PlayerState.playing || state == PlayerState.paused) {
        await _musicPlayer.stop();
      }
    } catch (e) {
      debugPrint('หยุดเพลงพื้นหลังไม่สำเร็จ: $e');
    }
  }

  Future<void> speakQuestion(String questionText) async {
    if (!_ttsEnabled) return;
    try {
      final textToSpeak = questionText
          .replaceAll('+', 'บวก')
          .replaceAll('-', 'ลบ')
          .replaceAll('×', 'คูณ')
          .replaceAll('÷', 'หาร')
          .replaceAll('=', 'เท่ากับ')
          .replaceAll('?', 'เท่าไหร่');

      await _tts.stop();
      await _tts.speak(textToSpeak);
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการอ่านโจทย์: $e');
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
    _tts.stop();
  }
}
