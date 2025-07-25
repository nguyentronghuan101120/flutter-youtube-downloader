import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../repositories/storage_repository.dart';
import '../../core/usecases/base_usecase.dart';
import '../../core/result/result.dart';

@injectable
class GetSystemDownloadsPath implements BaseUseCaseNoParams<Result<String?>> {
  final StorageRepository _storageRepository;

  GetSystemDownloadsPath({required StorageRepository storageRepository})
    : _storageRepository = storageRepository;

  @override
  Future<Result<String?>> execute() async {
    try {
      developer.log(
        '[get_system_downloads_path.dart] - Getting system downloads path',
      );
      final path = await _storageRepository.getSystemDownloadsPath();
      developer.log(
        '[get_system_downloads_path.dart] - System downloads path: $path',
      );
      return Result.success(path);
    } catch (e) {
      developer.log(
        '[get_system_downloads_path.dart] - Error getting system downloads path: $e',
      );
      return Result.failure('Failed to get system downloads path: $e');
    }
  }
}
