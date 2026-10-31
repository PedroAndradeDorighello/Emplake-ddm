import 'package:audioplayers/audioplayers.dart';

/// Som opcional; inicia desligado (usabilidade).
class SoundService {
  SoundService();

  final AudioPlayer _player = AudioPlayer();
  bool enabled = false;

  Future<void> playSuccess() async {
    if (!enabled) return;
    try {
      await _player.play(AssetSource('sounds/success.wav'));
    } catch (_) {
      // asset opcional
    }
  }

  Future<void> playFail() async {
    if (!enabled) return;
    try {
      await _player.play(AssetSource('sounds/fail.wav'));
    } catch (_) {}
  }

  Future<void> dispose() => _player.dispose();
}
