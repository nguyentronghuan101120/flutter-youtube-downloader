import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import '../result/result.dart';

class AudioConversionService {
  /// Convert video to MP3 audio
  Future<Result<String>> convertToMp3({
    required String inputPath,
    required String outputFileName,
    int? bitrate,
  }) async {
    try {
      final outputDir = await _getOutputDirectory();
      final outputPath = '${outputDir.path}/$outputFileName.mp3';

      // FFmpeg command for MP3 conversion
      final command = _buildMp3Command(
        inputPath: inputPath,
        outputPath: outputPath,
        bitrate: bitrate ?? 128,
      );

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return Result.success(outputPath);
      } else {
        final logs = await session.getLogsAsString();
        return Result.failure('FFmpeg conversion failed: $logs');
      }
    } catch (e) {
      return Result.failure('Audio conversion error: $e');
    }
  }

  /// Convert video to AAC audio
  Future<Result<String>> convertToAac({
    required String inputPath,
    required String outputFileName,
    int? bitrate,
  }) async {
    try {
      final outputDir = await _getOutputDirectory();
      final outputPath = '${outputDir.path}/$outputFileName.m4a';

      // FFmpeg command for AAC conversion
      final command = _buildAacCommand(
        inputPath: inputPath,
        outputPath: outputPath,
        bitrate: bitrate ?? 128,
      );

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return Result.success(outputPath);
      } else {
        final logs = await session.getLogsAsString();
        return Result.failure('FFmpeg conversion failed: $logs');
      }
    } catch (e) {
      return Result.failure('Audio conversion error: $e');
    }
  }

  /// Extract audio from video file
  Future<Result<String>> extractAudio({
    required String inputPath,
    required String outputFileName,
    required String format,
    int? bitrate,
  }) async {
    try {
      final outputDir = await _getOutputDirectory();
      final outputPath = '${outputDir.path}/$outputFileName.$format';

      // FFmpeg command for audio extraction
      final command = _buildExtractCommand(
        inputPath: inputPath,
        outputPath: outputPath,
        format: format,
        bitrate: bitrate ?? 128,
      );

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return Result.success(outputPath);
      } else {
        final logs = await session.getLogsAsString();
        return Result.failure('Audio extraction failed: $logs');
      }
    } catch (e) {
      return Result.failure('Audio extraction error: $e');
    }
  }

  /// Get available audio formats
  List<String> getAvailableFormats() {
    return ['mp3', 'aac', 'ogg', 'wav', 'flac'];
  }

  /// Get recommended bitrates
  List<int> getRecommendedBitrates() {
    return [64, 128, 192, 256, 320];
  }

  String _buildMp3Command({
    required String inputPath,
    required String outputPath,
    required int bitrate,
  }) {
    return '-i "$inputPath" -vn -acodec libmp3lame -ab ${bitrate}k "$outputPath"';
  }

  String _buildAacCommand({
    required String inputPath,
    required String outputPath,
    required int bitrate,
  }) {
    return '-i "$inputPath" -vn -acodec aac -ab ${bitrate}k "$outputPath"';
  }

  String _buildExtractCommand({
    required String inputPath,
    required String outputPath,
    required String format,
    required int bitrate,
  }) {
    switch (format.toLowerCase()) {
      case 'mp3':
        return _buildMp3Command(
          inputPath: inputPath,
          outputPath: outputPath,
          bitrate: bitrate,
        );
      case 'aac':
        return _buildAacCommand(
          inputPath: inputPath,
          outputPath: outputPath,
          bitrate: bitrate,
        );
      case 'ogg':
        return '-i "$inputPath" -vn -acodec libvorbis -ab ${bitrate}k "$outputPath"';
      case 'wav':
        return '-i "$inputPath" -vn -acodec pcm_s16le "$outputPath"';
      case 'flac':
        return '-i "$inputPath" -vn -acodec flac "$outputPath"';
      default:
        return _buildMp3Command(
          inputPath: inputPath,
          outputPath: outputPath,
          bitrate: bitrate,
        );
    }
  }

  Future<Directory> _getOutputDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audio');

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    return audioDir;
  }
}
