import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Efeitos sonoros opcionais. Começa em silêncio (volume 0).
class SoundService {
  SoundService() {
    _sfx.setPlayerMode(PlayerMode.lowLatency);
  }

  final AudioPlayer _sfx = AudioPlayer();
  bool enabled = false;
  double volume = 0;

  Future<void> apply({required bool enabled, required double volume}) async {
    this.volume = volume.clamp(0.0, 1.0);
    this.enabled = enabled && this.volume > 0.001;
    try {
      await _sfx.setVolume(this.enabled ? this.volume : 0);
    } catch (_) {}
  }

  Future<void> playSuccess() => _playSfx(_risingSuccess());

  Future<void> playFail() => _playSfx(_tone(freq: 196, ms: 220, gain: 0.65));

  Future<void> playPlace() => _playSfx(_tone(freq: 360, ms: 70, gain: 0.75));

  Future<void> _playSfx(Uint8List wav) async {
    if (!enabled || volume <= 0.001) return;
    try {
      await _sfx.setVolume(volume);
      await _sfx.stop();
      await _sfx.play(BytesSource(wav, mimeType: 'audio/wav'));
    } catch (_) {}
  }

  Future<void> dispose() => _sfx.dispose();
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final s = SoundService();
  ref.onDispose(s.dispose);
  return s;
});

/// Acerto: começa grave e sobe (~0,75 s).
Uint8List _risingSuccess() {
  const notes = [196.0, 247.0, 311.0, 392.0]; // G3 → B3 → D#4 → G4
  const noteMs = 190;
  const gapMs = 20;
  const rate = 22050;
  final samples = <double>[];
  for (var n = 0; n < notes.length; n++) {
    final note = _render(noteMs, (t, i, len) {
      final env = _envelope(i, len, attack: 80, release: 900);
      final fundamental = math.sin(2 * math.pi * notes[n] * t);
      final overtone = math.sin(2 * math.pi * notes[n] * 2 * t) * 0.22;
      return (fundamental + overtone) * env * 0.7;
    });
    samples.addAll(note);
    if (n < notes.length - 1) {
      samples.addAll(List.filled(rate * gapMs ~/ 1000, 0));
    }
  }
  return _pcmToWav(samples);
}

Uint8List _tone({required double freq, required int ms, double gain = 0.5}) {
  return _pcmToWav(_render(ms, (t, i, n) {
    final env = _envelope(i, n, attack: 60, release: 400);
    return math.sin(2 * math.pi * freq * t) * env * gain;
  }));
}

double _envelope(int i, int n, {required int attack, required int release}) {
  final a = i < attack ? i / attack : 1.0;
  final r = i > n - release ? (n - i) / release : 1.0;
  return (a * r).clamp(0.0, 1.0);
}

List<double> _render(int ms, double Function(double t, int i, int n) sampleAt) {
  const rate = 22050;
  final n = rate * ms ~/ 1000;
  return [
    for (var i = 0; i < n; i++) sampleAt(i / rate, i, n),
  ];
}

Uint8List _pcmToWav(List<double> samples) {
  final pcm = BytesBuilder(copy: false);
  for (final s in samples) {
    final sample = (s.clamp(-1.0, 1.0) * 30000).round();
    pcm.addByte(sample & 0xff);
    pcm.addByte((sample >> 8) & 0xff);
  }
  final data = pcm.toBytes();
  final header = BytesBuilder(copy: false);
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

  const rate = 22050;
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
