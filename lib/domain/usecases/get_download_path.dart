import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../repositories/storage_repository.dart';
import '../../core/usecases/base_usecase.dart';
import '../../core/result/result.dart';

@injectable
class GetDownloadPath implements BaseUseCaseNoParams<Result<String>> {
  final StorageRepository _storageRepository;

  GetDownloadPath({required StorageRepository storageRepository})
    : _storageRepository = storageRepository;

  @override
  Future<Result<String>> execute() async {
    try {
      developer.log('[get_download_path.dart] - Getting download path');
      final path = await _storageRepository.getDefaultDownloadPath();
      developer.log('[get_download_path.dart] - Download path: $path');
      return Result.success(path);
    } catch (e) {
      developer.log(
        '[get_download_path.dart] - Error getting download path: $e',
      );
      return Result.failure('Failed to get download path: $e');
    }
  }
}
