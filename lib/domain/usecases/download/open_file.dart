import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../../repositories/download_repository.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class OpenFile implements BaseUseCase<bool, String> {
  final DownloadRepository _downloadRepository;

  OpenFile({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  @override
  Future<bool> execute(String filePath) async {
    try {
      developer.log('[open_file.dart] - Opening file: $filePath');
      final result = await _downloadRepository.openFile(filePath);
      developer.log('[open_file.dart] - Result: $result');
      return result;
    } catch (e) {
      developer.log('[open_file.dart] - Error opening file: $e');
      return false;
    }
  }
}
