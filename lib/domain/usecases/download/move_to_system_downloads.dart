import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../../repositories/download_repository.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class MoveToSystemDownloads implements BaseUseCase<String?, String> {
  final DownloadRepository _downloadRepository;

  MoveToSystemDownloads({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  @override
  Future<String?> execute(String filePath) async {
    try {
      developer.log(
        '[move_to_system_downloads.dart] - Moving file to system downloads: $filePath',
      );
      final result = await _downloadRepository.moveToSystemDownloads(filePath);
      developer.log('[move_to_system_downloads.dart] - Result: $result');
      return result;
    } catch (e) {
      developer.log(
        '[move_to_system_downloads.dart] - Error moving file to system downloads: $e',
      );
      return null;
    }
  }
}
