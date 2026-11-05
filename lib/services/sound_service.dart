import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Som opcional; inicia desligado (usabilidade).
class SoundService {
  SoundService();

  final AudioPlayer _player = AudioPlayer();
  bool enabled = false;

  Future<void> playSuccess() => _play(_tone(freq: 880, ms: 90));

  Future<void> playFail() => _play(_tone(freq: 220, ms: 160));

  Future<void> _play(Uint8List wav) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(BytesSource(wav));
    } catch (_) {}
  }

  Future<void> dispose() => _player.dispose();
}

Uint8List _tone({required double freq, required int ms}) {
  const rate = 22050;
  final n = rate * ms ~/ 1000;
  final pcm = BytesBuilder();
  for (var i = 0; i < n; i++) {
    final env = i < 200 ? i / 200 : (n - i) / 400;
    final amp = env.clamp(0.0, 1.0);
    final sample = (math.sin(2 * math.pi * freq * i / rate) * amp * 28000).round();
    pcm.addByte(sample & 0xff);
    pcm.addByte((sample >> 8) & 0xff);
  }
  final data = pcm.toBytes();
  final header = BytesBuilder();
  void u16(int v) {
    header.addByte(v & 0xff);
    header.addByte((v >> 8) & 0xff);
  }

  void u32(int v) {
    header.addByte(v & 0xff);
    header.addByte((v >> 8) & 0xff);
    header.addByte((v >> 16) & 0xff);
    header.addByte((v >> 24) & 0xff);
  }

  header.add('RIFF'.codeUnits);
  u32(36 + data.length);
  header.add('WAVE'.codeUnits);
  header.add('fmt '.codeUnits);
  u32(16);
  u16(1);
  u16(1);
  u32(rate);
  u32(rate * 2);
  u16(2);
  u16(16);
  header.add('data'.codeUnits);
  u32(data.length);
  return Uint8List.fromList([...header.toBytes(), ...data]);
}
