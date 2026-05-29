import 'dart:math';
import 'dart:typed_data';

class ToneGenerator {
  // generates a pure sine wave tone as WAV bytes
  // frequencyHz — the pitch (500, 1000, 2000, 4000)
  // durationSeconds — how long to play
  // sampleRate — standard audio sample rate
  static Uint8List generateTone({
    required int frequencyHz,
    required int durationSeconds,
    int sampleRate = 44100,
    double amplitude = 0.5, // 0.0 to 1.0 — controls volume
  }) {
    final numSamples = sampleRate * durationSeconds;
    final samples = Int16List(numSamples);

    // generate sine wave samples
    for (int i = 0; i < numSamples; i++) {
      // sine wave formula: amplitude × sin(2π × frequency × time)
      final t = i / sampleRate;
      final value =
          (amplitude * 32767 * sin(2 * pi * frequencyHz * t))
              .round();
      samples[i] = value.clamp(-32768, 32767);
    }

    // wrap samples in WAV file format
    return _buildWav(samples, sampleRate);
  }

  // builds a valid WAV file from raw PCM samples
  static Uint8List _buildWav(Int16List samples, int sampleRate) {
    const numChannels = 1;        // mono
    const bitsPerSample = 16;
    final byteRate =
        sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = samples.length * blockAlign;
    final chunkSize = 36 + dataSize;

    final buffer = ByteData(44 + dataSize);
    var offset = 0;

    // RIFF header
    _writeString(buffer, offset, 'RIFF'); offset += 4;
    buffer.setInt32(offset, chunkSize, Endian.little); offset += 4;
    _writeString(buffer, offset, 'WAVE'); offset += 4;

    // fmt chunk
    _writeString(buffer, offset, 'fmt '); offset += 4;
    buffer.setInt32(offset, 16, Endian.little); offset += 4;
    buffer.setInt16(offset, 1, Endian.little); offset += 2; // PCM
    buffer.setInt16(offset, numChannels, Endian.little); offset += 2;
    buffer.setInt32(offset, sampleRate, Endian.little); offset += 4;
    buffer.setInt32(offset, byteRate, Endian.little); offset += 4;
    buffer.setInt16(offset, blockAlign, Endian.little); offset += 2;
    buffer.setInt16(offset, bitsPerSample, Endian.little); offset += 2;

    // data chunk
    _writeString(buffer, offset, 'data'); offset += 4;
    buffer.setInt32(offset, dataSize, Endian.little); offset += 4;

    // write samples
    for (int i = 0; i < samples.length; i++) {
      buffer.setInt16(offset, samples[i], Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  static void _writeString(ByteData buffer, int offset, String str) {
    for (int i = 0; i < str.length; i++) {
      buffer.setUint8(offset + i, str.codeUnitAt(i));
    }
  }
}