import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../../repositories/download_repository.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class IsInSystemDownloads implements BaseUseCase<bool, String> {
  final DownloadRepository _downloadRepository;

  IsInSystemDownloads({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  @override
  Future<bool> execute(String filePath) async {
    try {
      developer.log(
        '[is_in_system_downloads.dart] - Checking if file is in system downloads: $filePath',
      );
      final result = _downloadRepository.isInSystemDownloads(filePath);
      developer.log('[is_in_system_downloads.dart] - Result: $result');
      return result;
    } catch (e) {
      developer.log(
        '[is_in_system_downloads.dart] - Error checking system downloads: $e',
      );
      return false;
    }
  }
}
