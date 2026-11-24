import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    } catch (e) {
      debugPrint('SoundService init error: $e');
    }
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _soundEnabled);
    } catch (e) {
      debugPrint('Sound toggle save error: $e');
    }
  }

  Future<void> playDiceRoll() async {
    if (!_soundEnabled) return;
    _playSound('dice_roll.mp3');
  }

  Future<void> playTokenMove() async {
    if (!_soundEnabled) return;
    _playSound('token_step.mp3');
  }

  Future<void> playCapture() async {
    if (!_soundEnabled) return;
    _playSound('token_cut.mp3');
  }

  Future<void> playVictory() async {
    if (!_soundEnabled) return;
    _playSound('victory_fanfare.mp3');
  }

  Future<void> playSnakeBite() async {
    if (!_soundEnabled) return;
    _playSound('snake_hiss.mp3');
  }

  Future<void> playLadderClimb() async {
    if (!_soundEnabled) return;
    _playSound('ladder_climb.mp3');
  }

  Future<void> playClick() async {
    if (!_soundEnabled) return;
    _playSound('tap_click.mp3');
  }

  void _playSound(String assetName) {
    if (kIsWeb) return;
    try {
      _player.stop();
      _player.play(AssetSource('sounds/$assetName')).catchError((err) {
        // Safe fallback if audio asset not downloaded
        debugPrint('Audio asset fallback: $err');
      });
    } catch (_) {}
  }
}
